from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}


def test_echo_ok():
    r = client.post("/api/echo", json={"text": " hello "})
    assert r.status_code == 200
    assert r.json() == {"text": "hello", "length": 5}


def test_echo_empty_is_400():
    r = client.post("/api/echo", json={"text": "   "})
    assert r.status_code == 400


def test_index_served():
    r = client.get("/")
    assert r.status_code == 200
    assert "<h1>" in r.text
