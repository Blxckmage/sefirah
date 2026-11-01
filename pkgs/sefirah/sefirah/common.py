"""Shared constants, paths and small helpers."""
import os
from pathlib import Path

UMBER = {
    "bg": "#16120e", "fg": "#e3d6b8", "dim": "#8d7d65",
    "active": "#d49a3a", "a1": "#d25f42", "a3": "#7aa08c", "a6": "#8d7d65",
    "paper": "#c9b994",
}

CACHE_DIR = Path.home() / ".cache" / "sefirah"
STATE_DIR = Path.home() / ".local" / "state" / "sefirah"
CONFIG_DIR = Path.home() / ".config" / "sefirah"
_wallpaper = os.environ.get("SEFIRAH_WALLPAPER")
LOCK_WALLPAPER = Path(_wallpaper) if _wallpaper else None

POWER = Path("/sys/class/power_supply")
MODULES = Path("/usr/lib/modules")


def _read(path: Path) -> str | None:
    try:
        return path.read_text().strip()
    except OSError:
        return None


def ordinal(n: int) -> str:
    suffix = "th" if 10 <= n % 100 <= 20 else {1: "st", 2: "nd", 3: "rd"}.get(n % 10, "th")
    return f"{n}{suffix}"


def ensure_dirs() -> None:
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    (CACHE_DIR / "tarot").mkdir(parents=True, exist_ok=True)
    (CACHE_DIR / "wall").mkdir(parents=True, exist_ok=True)
    STATE_DIR.mkdir(parents=True, exist_ok=True)
