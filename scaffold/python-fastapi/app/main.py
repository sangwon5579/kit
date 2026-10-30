"""최소 웹 앱 스캐폴드 (FastAPI).

실행: bash run.sh            (0.0.0.0, PORT 기본 8000)
테스트: bash scripts/check.sh

주의: 정적 파일 마운트("/")는 모든 API 라우트보다 **뒤에** 둔다. 앞에 두면 API가 가려진다.
"""
import os
from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

app = FastAPI(title="app")

STATIC_DIR = Path(__file__).parent / "static"


@app.get("/health")
def health():
    return {"status": "ok"}


# --- API 라우트는 여기에 추가 ---------------------------------------------
class EchoIn(BaseModel):
    text: str


@app.post("/api/echo")
def echo(body: EchoIn):
    text = body.text.strip()
    if not text:
        raise HTTPException(status_code=400, detail="text는 비어 있을 수 없습니다")
    return {"text": text, "length": len(text)}
# ---------------------------------------------------------------------------


# 정적 파일은 항상 마지막에 마운트
app.mount("/", StaticFiles(directory=str(STATIC_DIR), html=True), name="static")


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("app.main:app", host="0.0.0.0", port=int(os.environ.get("PORT", "8000")))
