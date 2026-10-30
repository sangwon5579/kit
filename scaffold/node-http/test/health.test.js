// node:test 사용 (Node 18+). 실제 서버를 임시 포트에 띄워 확인한다.
const { test, before, after } = require("node:test");
const assert = require("node:assert/strict");
const { createServer } = require("../server");

let server;
let base;

before(async () => {
  await new Promise((resolve) => {
    server = createServer().listen(0, "127.0.0.1", resolve);
  });
  base = `http://127.0.0.1:${server.address().port}`;
});

after(() => server.close());

test("GET /health", async () => {
  const r = await fetch(`${base}/health`);
  assert.equal(r.status, 200);
  assert.deepEqual(await r.json(), { status: "ok" });
});

test("POST /api/echo ok", async () => {
  const r = await fetch(`${base}/api/echo`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ text: " hello " }),
  });
  assert.equal(r.status, 200);
  assert.deepEqual(await r.json(), { text: "hello", length: 5 });
});

test("POST /api/echo empty -> 400", async () => {
  const r = await fetch(`${base}/api/echo`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ text: "   " }),
  });
  assert.equal(r.status, 400);
});

test("GET / serves index", async () => {
  const r = await fetch(`${base}/`);
  assert.equal(r.status, 200);
  assert.match(await r.text(), /<h1>/);
});
