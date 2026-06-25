"""90_Engine/vault_sync.py — 데몬이 구동하는 git 동기화 헬퍼(이벤트 구동).

git은 서브프로세스 + 하드 타임아웃으로 격리하고, 요청 서빙 경로를 절대 블록하지 않게
호출부(vault_daemon)에서 스케줄한다. 충돌은 자동으로 해결하지 않고(rebase --abort) 상태로
표면화한다 — 사용자 데이터라 파괴적 자동 조치 금지. See docs/DAEMON_DESIGN.md §5.

각 함수는 (changed_or_pushed: bool, status: str, detail: str)를 반환한다.
status ∈ {"ok","conflict","rejected","error","skipped"}.
"""
import subprocess
from pathlib import Path


def _git(vault_root, args, timeout):
    return subprocess.run(
        ["git", "-C", str(vault_root), *args],
        capture_output=True, text=True, timeout=timeout,
    )


def is_git_repo(vault_root, timeout=10) -> bool:
    try:
        r = _git(vault_root, ["rev-parse", "--is-inside-work-tree"], timeout)
        return r.returncode == 0 and r.stdout.strip() == "true"
    except Exception:
        return False


def _head(vault_root, timeout):
    r = _git(vault_root, ["rev-parse", "HEAD"], timeout)
    return r.stdout.strip() if r.returncode == 0 else None


def pull(vault_root, timeout=60):
    """fetch + rebase(+autostash). HEAD가 바뀌면 changed=True. 충돌이면 rebase --abort로
    원복하고 ("conflict")로 표면화한다."""
    try:
        before = _head(vault_root, timeout)
        r = _git(vault_root, ["pull", "--rebase", "--autostash"], timeout)
        if r.returncode != 0:
            out = (r.stdout + r.stderr)
            low = out.lower()
            if any(s in low for s in ("conflict", "could not apply", "rebasing")):
                _git(vault_root, ["rebase", "--abort"], timeout)
                return (False, "conflict", out.strip()[-600:])
            return (False, "error", out.strip()[-600:])
        after = _head(vault_root, timeout)
        return (before != after, "ok", "")
    except subprocess.TimeoutExpired:
        return (False, "error", f"git pull timeout ({timeout}s)")
    except Exception as e:  # noqa: BLE001
        return (False, "error", repr(e))


def commit_push(vault_root, message, timeout=60):
    """add -A → commit(변경 없으면 스킵) → push. push가 non-fast-forward로 거부되면
    ("rejected")로 표면화(호출부가 pull 후 재시도 판단)."""
    try:
        _git(vault_root, ["add", "-A"], timeout)
        c = _git(vault_root, ["commit", "-m", message], timeout)
        if c.returncode != 0 and "nothing to commit" not in (c.stdout + c.stderr).lower():
            return (False, "error", (c.stdout + c.stderr).strip()[-600:])
        p = _git(vault_root, ["push"], timeout)
        if p.returncode != 0:
            out = (p.stdout + p.stderr)
            low = out.lower()
            if "rejected" in low or "non-fast-forward" in low or "fetch first" in low:
                return (False, "rejected", out.strip()[-600:])
            return (False, "error", out.strip()[-600:])
        return (True, "ok", "")
    except subprocess.TimeoutExpired:
        return (False, "error", f"git push timeout ({timeout}s)")
    except Exception as e:  # noqa: BLE001
        return (False, "error", repr(e))
