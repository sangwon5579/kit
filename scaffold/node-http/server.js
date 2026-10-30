// 최소 웹 앱 스캐폴드 (Node 내장 http, 의존성 0 — npm install 없이 바로 뜬다).
// 실행: bash run.sh            (0.0.0.0, PORT 기본 3000)
// 테스트: bash scripts/check.sh  (npm test → node --test)
//
// 라우팅이 복잡해지면 express로 바꿔도 된다 (AGENTS.md: 새 의존성은 먼저 알리고 승인 후).
const http = require("http");
const fs = require("fs");
const path = require("path");

const PUBLIC_DIR = path.join(__dirname, "public");
const MIME = { ".html": "text/html; charset=utf-8", ".js": "text/javascript", ".css": "text/css", ".json": "application/json" };

function sendJson(res, status, body) {
  res.writeHead(status, { "Content-Type": "application/json; charset=utf-8" });
  res.end(JSON.stringify(body));
}

function readJson(req) {
  return new Promise((resolve, reject) => {
    let data = "";
    req.on("data", (chunk) => {
      data += chunk;
      if (data.length > 1e6) { req.destroy(); reject(new Error("too large")); }
    });
    req.on("end", () => {
      try { resolve(data ? JSON.parse(data) : {}); } catch { reject(new Error("bad json")); }
    });
    req.on("error", reject);
  });
}

function serveStatic(req, res, urlPath) {
  const rel = urlPath === "/" ? "/index.html" : urlPath;
  const file = path.normalize(path.join(PUBLIC_DIR, rel));
  if (!file.startsWith(PUBLIC_DIR)) return sendJson(res, 400, { error: "잘못된 경로" }); // 경로 탈출 방지
  fs.readFile(file, (err, buf) => {
    if (err) return sendJson(res, 404, { error: "not found" });
    res.writeHead(200, { "Content-Type": MIME[path.extname(file)] || "application/octet-stream" });
    res.end(buf);
  });
}

// --- API 라우트는 여기에 추가 -----------------------------------------------
async function handleApi(req, res, url) {
  if (req.method === "GET" && url.pathname === "/health") {
    return sendJson(res, 200, { status: "ok" });
  }
  if (req.method === "POST" && url.pathname === "/api/echo") {
    let body;
    try { body = await readJson(req); } catch { return sendJson(res, 400, { error: "잘못된 JSON" }); }
    const text = typeof body.text === "string" ? body.text.trim() : "";
    if (!text) return sendJson(res, 400, { error: "text는 비어 있을 수 없습니다" });
    return sendJson(res, 200, { text, length: text.length });
  }
  return null; // API가 아니면 정적 파일로
}
// ---------------------------------------------------------------------------

function createServer() {
  return http.createServer(async (req, res) => {
    const url = new URL(req.url, "http://localhost");
    try {
      const handled = await handleApi(req, res, url);
      if (handled === null) {
        if (req.method !== "GET") return sendJson(res, 404, { error: "not found" });
        serveStatic(req, res, url.pathname);
      }
    } catch (err) {
      console.error(err);
      sendJson(res, 500, { error: "서버 오류" }); // 스택은 노출하지 않는다
    }
  });
}

if (require.main === module) {
  const port = Number(process.env.PORT || 3000);
  createServer().listen(port, "0.0.0.0", () => {
    console.log(`http://0.0.0.0:${port}  (Browser 탭의 PORT에 ${port} 입력)`);
  });
}

module.exports = { createServer };
