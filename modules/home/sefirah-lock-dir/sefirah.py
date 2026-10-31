#!/usr/bin/env python3
"""
Sefirah - Dynamic lock screen utilities for Niri + hyprlock
Commands: hour, draw, status, sigil, transmute
"""
import argparse
import base64
import getpass
import hashlib
import html
import json
import math
import os
import shutil
import socket
import struct
import subprocess
import sys
import urllib.parse
import urllib.request
import zlib
from dataclasses import dataclass
from datetime import UTC, date, datetime, time, timedelta, tzinfo
from pathlib import Path

# ==================== CONSTANTS ====================

CHALDEAN = ("Saturn", "Jupiter", "Mars", "Sun", "Venus", "Mercury", "Moon")
DAY_RULER = (6, 2, 5, 1, 4, 0, 3)  # Monday first
SYNODIC_MONTH = 29.530588853
NEW_MOON_EPOCH = datetime(2000, 1, 6, 18, 14, tzinfo=UTC)
ZENITH = 90.833

PHASES = (
    "New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous",
    "Full Moon", "Waning Gibbous", "Last Quarter", "Waning Crescent"
)

# Major Arcana
MAJORS = (
    ("The Fool", 0), ("The Magician", 1), ("The High Priestess", 2),
    ("The Empress", 3), ("The Emperor", 4), ("The Hierophant", 5),
    ("The Lovers", 6), ("The Chariot", 7), ("Strength", 8),
    ("The Hermit", 9), ("Wheel of Fortune", 10), ("Justice", 11),
    ("The Hanged Man", 12), ("Death", 13), ("Temperance", 14),
    ("The Devil", 15), ("The Tower", 16), ("The Star", 17),
    ("The Moon", 18), ("The Sun", 19), ("Judgement", 20), ("The World", 21),
)

MAJOR_FILES = (
    "Fool", "Magician", "High Priestess", "Empress", "Emperor", "Hierophant",
    "Lovers", "Chariot", "Strength", "Hermit", "Wheel of Fortune", "Justice",
    "Hanged Man", "Death", "Temperance", "Devil", "Tower", "Star", "Moon",
    "Sun", "Judgement", "World",
)

# Minor Arcana
SUITS = ("Wands", "Cups", "Swords", "Pentacles")
SUIT_FILES = ("Wands", "Cups", "Swords", "Pents")
RANKS = (
    ("Ace", 1), ("Two", 2), ("Three", 3), ("Four", 4), ("Five", 5),
    ("Six", 6), ("Seven", 7), ("Eight", 8), ("Nine", 9), ("Ten", 10),
    ("Page", 11), ("Knight", 12), ("Queen", 13), ("King", 14),
)

PLANET_TRUMP = {
    "Saturn": 21, "Jupiter": 10, "Mars": 16, "Sun": 19,
    "Venus": 6, "Mercury": 9, "Moon": 18,
}

HOST_KEYS = ("ssh_host_ed25519_key.pub", "ssh_host_ecdsa_key.pub", "ssh_host_rsa_key.pub")
SIGIL_SIZE = 11

POWER = Path("/sys/class/power_supply")
MODULES = Path("/usr/lib/modules")

UMBER = {
    "bg": "#16120e", "fg": "#e3d6b8", "dim": "#8d7d65",
    "active": "#d49a3a", "a1": "#d25f42", "a3": "#7aa08c", "a6": "#8d7d65",
    "paper": "#c9b994",
}

CACHE_DIR = Path.home() / ".cache" / "sefirah"
STATE_DIR = Path.home() / ".local" / "state" / "sefirah"
CONFIG_DIR = Path.home() / ".config" / "sefirah"
LOCK_WALLPAPER = Path("@@LOCK_WALLPAPER@@")

# ==================== DATA CLASSES ====================

@dataclass(frozen=True)
class PlanetaryHour:
    day: date
    ruler: str
    index: int
    planet: str
    start: datetime
    end: datetime
    sunrise: datetime
    sunset: datetime

@dataclass(frozen=True)
class Card:
    index: int
    name: str
    suit: str | None
    rank: str | None
    numeral: str | None
    commons: str
    upright: str
    reversed: str

    @property
    def title(self) -> str:
        return f"{self.numeral} {self.name}" if self.numeral and self.suit is None else self.name

@dataclass(frozen=True)
class Draw:
    card: Card
    reversed: bool

    @property
    def title(self) -> str:
        return self.card.title + (", reversed" if self.reversed else "")

    @property
    def meaning(self) -> str:
        return self.card.reversed if self.reversed else self.card.upright

@dataclass(frozen=True)
class Battery:
    percent: int
    health: int
    charging: bool

@dataclass(frozen=True)
class Reading:
    workspace: int | None
    disk_free: int
    battery: Battery | None
    cpu: int
    mem: int
    minutes: int
    sick: bool = False

# ==================== DECK BUILD ====================

ROMAN = ["0", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX", "XXI"]

DECK: tuple[Card, ...] = tuple([
    Card(i, name, None, None, ROMAN[i], f"RWS Tarot {i:02d} {MAJOR_FILES[i]}.jpg",
         f"The {name} upright.", f"The {name} reversed.")
    for i, (name, _) in enumerate(MAJORS)
] + [
    Card(22 + si * 14 + ri, f"{rank} of {suit}", suit, rank, ROMAN[ri],
         f"{SUIT_FILES[si]}{ri + 1:02d}.jpg",
         f"{rank} of {suit} upright.", f"{rank} of {suit} reversed.")
    for si, suit in enumerate(SUITS)
    for ri, (rank, _) in enumerate(RANKS)
])

# ==================== UTILITIES ====================

def _read(path: Path) -> str | None:
    try:
        return path.read_text().strip()
    except OSError:
        return None

def ordinal(n: int) -> str:
    suffix = "th" if 10 <= n % 100 <= 20 else {1: "st", 2: "nd", 3: "rd"}.get(n % 10, "th")
    return f"{n}{suffix}"

def ensure_dirs():
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    (CACHE_DIR / "tarot").mkdir(parents=True, exist_ok=True)
    (CACHE_DIR / "wall").mkdir(parents=True, exist_ok=True)
    STATE_DIR.mkdir(parents=True, exist_ok=True)

# ==================== SKY / PLANETARY HOUR ====================

def _sun_event(d: date, lat: float, lon: float, rising: bool) -> datetime | None:
    rad, deg = math.radians, math.degrees
    n = (d - date(2000, 1, 1)).days + (6 if rising else 18) / 24
    M = (357.5291 + 0.98560028 * n) % 360
    L = (M + 1.9148 * math.sin(rad(M)) + 0.0200 * math.sin(rad(2*M)) + 282.9372) % 360
    sinDec = math.sin(rad(L)) * math.sin(rad(23.44))
    cosDec = math.cos(math.asin(sinDec))
    cosH = (math.sin(rad(ZENITH)) - sinDec * math.sin(rad(lat))) / (cosDec * math.cos(rad(lat)))
    if abs(cosH) > 1:
        return None
    H = deg(math.acos(cosH)) if rising else 360 - deg(math.acos(cosH))
    UT = (H + L - 0.06571 * n - 6.622) / 15
    UT = (UT + 24) % 24
    return datetime.combine(d, time(), UTC) + timedelta(hours=UT)

def sun_times(d: date, lat: float, lon: float, tz: tzinfo) -> tuple[datetime, datetime] | None:
    rise, set_ = _sun_event(d, lat, lon, True), _sun_event(d, lat, lon, False)
    if rise is None or set_ is None:
        return None
    def _onto(moment: datetime, d: date) -> datetime:
        local = moment.astimezone(tz).date()
        if local != d:
            moment += timedelta(days=1 if local < d else -1)
        return moment
    return _onto(rise, d), _onto(set_, d)

def _civil(d: date, tz: tzinfo) -> tuple[datetime, datetime]:
    return datetime.combine(d, time(6), tz), datetime.combine(d, time(18), tz)

def _day_bounds(d: date, place: tuple[float, float] | None, tz: tzinfo):
    if place is not None:
        lat, lon = place
        st = sun_times(d, lat, lon, tz)
        if st:
            return st + (False,)
    return _civil(d, tz) + (True,)

def planetary_hour(now: datetime, place: tuple[float, float] | None = None) -> PlanetaryHour:
    tz = now.tzinfo
    d = now.astimezone(tz).date()
    sunrise, sunset, civil = _day_bounds(d, place, tz)
    if civil:
        sunrise, sunset = _civil(d, tz)
    day_len = (sunset - sunrise).total_seconds() / 3600
    night_len = 24 - day_len
    ruler_idx = DAY_RULER[d.weekday()]
    hour_idx = -1
    if now >= sunrise and now < sunset:
        hour_idx = int((now - sunrise).total_seconds() / 3600 / (day_len / 12))
        start = sunrise + timedelta(hours=hour_idx * day_len / 12)
        end = start + timedelta(hours=day_len / 12)
    else:
        night_start = sunset if now >= sunset else sunset - timedelta(days=1)
        hour_idx = int((now - night_start).total_seconds() / 3600 / (night_len / 12)) % 12
        start = night_start + timedelta(hours=hour_idx * night_len / 12)
        end = start + timedelta(hours=night_len / 12)
    planet = CHALDEAN[(ruler_idx + hour_idx) % 7]
    return PlanetaryHour(d, CHALDEAN[ruler_idx], hour_idx, planet,
                         start.astimezone(tz), end.astimezone(tz),
                         sunrise.astimezone(tz), sunset.astimezone(tz))

def moon_age(now: datetime) -> float:
    days = (now - NEW_MOON_EPOCH).total_seconds() / 86400
    return days % SYNODIC_MONTH

def moon_phase(now: datetime) -> str:
    fraction = moon_age(now) / SYNODIC_MONTH
    return PHASES[int(fraction * 8 + 0.5) % 8]

def moon_trend(now: datetime) -> str:
    return "waxing" if moon_age(now) < SYNODIC_MONTH / 2 else "waning"

def with_article(planet: str) -> str:
    return f"the {planet}" if planet in ("Sun", "Moon") else planet

def hour_lines(now: datetime, place: tuple[float, float] | None = None) -> dict[str, str]:
    ph = planetary_hour(now, place)
    day, hour = with_article(ph.ruler), with_article(ph.planet)
    seed, _ = host_digest()
    card = card_of_day(now.date(), seed)
    return {
        "date": f"{now:%A}, the {ordinal(now.day)} of {now:%B}",
        "ruler": f"Day of {day}, hour of {hour}",
        "moon": f"Moon {moon_phase(now).lower()}, {moon_age(now):.0f} days old",
        "card": f"Card of the day: {card.title}",
        "bar": f"{now:%a %-d %b  %H:%M}  Hour of {hour}  Moon: {moon_trend(now)}",
        "sun": f"Sunrise {ph.sunrise:%H:%M}, sunset {ph.sunset:%H:%M}",
    }

def lock_markup(lines: dict[str, str], colors: str) -> str:
    fg, active, dim = (f"#{c.lstrip('#')}" for c in colors.split(","))
    rows = [("date", fg), ("ruler", active), ("moon", dim), ("card", dim)]
    body = "\n".join(
        f'<span foreground="{c}">{html.escape(lines[k], quote=False)}</span>' for k, c in rows
    )
    return f'<span line_height="1.5">{body}</span>'

# ==================== SIGIL ====================

def key_digest(pub_line: str) -> bytes:
    blob = base64.b64decode(pub_line.split()[1])
    return hashlib.sha256(blob).digest()

def fingerprint_text(digest: bytes) -> str:
    return "SHA256:" + base64.b64encode(digest).decode().rstrip("=")

def fingerprint_short(text: str) -> str:
    return text if len(text) <= 23 else text[:22] + "…"

def host_digest(etc: Path = Path("/etc")) -> tuple[bytes, str]:
    for name in HOST_KEYS:
        path = etc / "ssh" / name
        try:
            digest = key_digest(path.read_text())
        except (OSError, IndexError, ValueError):
            continue
        return digest, fingerprint_text(digest)
    try:
        machine = (etc / "machine-id").read_text().strip()
    except OSError:
        machine = "sefirah"
    digest = hashlib.sha256(machine.encode()).digest()
    return digest, "machine-id"

def sigil_grid(digest: bytes) -> list[list[bool]]:
    cells = [[False] * SIGIL_SIZE for _ in range(SIGIL_SIZE)]
    for i in range(SIGIL_SIZE):
        cells[0][i] = cells[SIGIL_SIZE - 1][i] = cells[i][0] = cells[i][SIGIL_SIZE - 1] = True
    bit = 0
    for y in range(2, SIGIL_SIZE - 2):
        for x in range(2, SIGIL_SIZE // 2 + 1):
            on = bool(digest[bit // 8] >> (bit % 8) & 1)
            cells[y][x] = cells[y][SIGIL_SIZE - 1 - x] = on
            bit += 1
    return cells

def sigil_text(cells: list[list[bool]]) -> str:
    return "\n".join("".join("██" if on else "  " for on in row) for row in cells)

def sigil_png(cells: list[list[bool]], color: str, scale: int = 8) -> bytes:
    r, g, b = (int(color.lstrip("#")[i : i + 2], 16) for i in (0, 2, 4))
    on, off = bytes((r, g, b, 255)), bytes(4)
    rows = []
    for row in cells:
        line = b"".join((on if c else off) * scale for c in row)
        rows.extend([b"\x00" + line] * scale)
    side = len(cells) * scale
    def chunk(kind: bytes, data: bytes) -> bytes:
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))
    header = struct.pack(">IIBBBBB", side, side, 8, 6, 0, 0, 0)
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header) + chunk(b"IDAT", zlib.compress(b"".join(rows), 9)) + chunk(b"IEND", b"")

# ==================== TAROT ====================

def card_of_day(day: date, seed: bytes) -> Draw:
    h = hashlib.sha256(day.isoformat().encode() + seed).digest()
    return Draw(DECK[int.from_bytes(h[:4]) % len(DECK)], bool(h[4] & 1))

def art_path(card: Card, art_dir: Path) -> Path:
    return art_dir / card.commons.replace(" ", "_")

API = "https://commons.wikimedia.org/w/api.php"
USER_AGENT = "sefirah/0.1"

def _thumb_urls(titles: list[str], width: int) -> dict[str, str]:
    params = {
        "action": "query",
        "prop": "imageinfo",
        "iiprop": "url",
        "iiurlwidth": str(width),
        "format": "json",
        "titles": "|".join(f"File:{t}" for t in titles),
    }
    req = urllib.request.Request(
        f"{API}?{urllib.parse.urlencode(params)}",
        headers={"User-Agent": USER_AGENT},
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        pages = json.load(r)["query"]["pages"].values()
    urls = {}
    for page in pages:
        info = page.get("imageinfo")
        if info:
            urls[page["title"].removeprefix("File:")] = info[0].get("thumburl") or info[0]["url"]
    return urls

def fetch_art(art_dir: Path, width: int = 320, log=print) -> int:
    art_dir.mkdir(parents=True, exist_ok=True)
    missing = [c for c in DECK if not art_path(c, art_dir).exists()]
    fetched = 0
    for start in range(0, len(missing), 40):
        batch = missing[start : start + 40]
        urls = _thumb_urls([c.commons for c in batch], width)
        for card in batch:
            url = urls.get(card.commons)
            if url is None:
                log(f"no scan of {card.name} on Commons")
                continue
            req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
            with urllib.request.urlopen(req, timeout=60) as r:
                art_path(card, art_dir).write_bytes(r.read())
            fetched += 1
            log(f"fetched {card.name}")
    return fetched

# ==================== STATUS ====================

def battery(root: Path = POWER) -> Battery | None:
    if not root.exists():
        return None
    for bat in root.iterdir():
        cap = _read(bat / "capacity")
        stat = _read(bat / "status")
        if cap is None:
            continue
        percent = int(cap)
        health = 100
        h = _read(bat / "energy_full")
        hd = _read(bat / "energy_full_design")
        if h and hd:
            health = min(100, round(int(h) / int(hd) * 100))
        charging = stat in ("Charging", "Full")
        return Battery(percent, health, charging)
    return None

class Cpu:
    def __init__(self, stat: Path = Path("/proc/stat")):
        self.stat = stat
        self.prev = self._read()
    def _read(self):
        text = _read(self.stat)
        line = text.splitlines()[0] if text else ""
        return list(map(int, line.split()[1:])) if line else [0] * 8
    def usage(self) -> int:
        cur = self._read()
        prev = self.prev
        self.prev = cur
        busy = sum(cur[i] - prev[i] for i in (0,1,2,3,6,7))
        total = sum(cur[i] - prev[i] for i in range(8))
        return max(0, min(100, round(busy * 100 / total))) if total else 0

def mem_used(meminfo: Path = Path("/proc/meminfo")) -> int:
    values = {}
    for line in (_read(meminfo) or "").splitlines():
        k, v = line.split(":", 1)
        values[k] = int(v.strip().split()[0])
    return values.get("MemTotal", 0) - values.get("MemAvailable", 0)

def uptime_minutes(uptime: Path = Path("/proc/uptime")) -> int:
    t = _read(uptime)
    return int(float(t.split()[0]) // 60) if t else 0

def sick(modules: Path = MODULES, release: str | None = None) -> bool:
    release = release or os.uname().release
    return modules.is_dir() and not (modules / release).is_dir()

def read_status(cpu: Cpu) -> Reading:
    return Reading(
        workspace=None,
        disk_free=0,
        battery=battery(),
        cpu=cpu.usage(),
        mem=mem_used(),
        minutes=uptime_minutes(),
        sick=sick(),
    )

def hp(b: Battery | None) -> str:
    if b is None:
        return "Hp:AC"
    return f"Hp:{b.percent}({b.health}){'+' if b.charging else ''}"

def short(r: Reading) -> str:
    return f"{hp(r.battery)}  T:{r.minutes}"

# ==================== TRANSMUTE ====================

CARD_ASPECT = 0.58
MARGIN = 72
TEXT_COLUMN = 345
GAP = 46

def lock_layout(size: tuple[int, int], panel_x: int, scale: int) -> dict[str, int]:
    w, h = size
    tall = int((h - 2 * MARGIN) * CARD_ASPECT)
    card_w = max(0, min(320, tall))
    card_w -= card_w % scale
    lock_x = w - MARGIN - card_w - GAP - TEXT_COLUMN
    lock_x = max(lock_x, panel_x + MARGIN)
    return {"lock_x": lock_x, "card_w": card_w}


def screen_size() -> tuple[int, int]:
    niri = shutil.which("niri")
    if niri:
        try:
            out = subprocess.run(
                [niri, "msg", "-j", "outputs"],
                capture_output=True,
                text=True,
                check=True,
            ).stdout
            sizes = [
                (int(o["logical"]["width"]), int(o["logical"]["height"]))
                for o in json.loads(out).values()
                if o.get("logical")
            ]
            if sizes:
                return max(sizes, key=lambda s: s[0] * s[1])
        except (OSError, subprocess.SubprocessError, KeyError, TypeError, ValueError):
            pass
    return (1920, 1080)

def card_image(
    src: Path,
    scheme: dict,
    reversed_: bool,
    out: Path,
    *,
    width: int,
    scale: int = 2,
) -> Path:
    geometry = f"{width // scale}x"
    ink, paper = scheme["bg"], scheme["paper"]
    args = [
        "magick", str(src),
        "-colorspace", "HSL", "-channel", "B", "-separate", "+channel",
        "-resize", geometry, "-gamma", "1.4",
        "-dither", "FloydSteinberg", "-monochrome",
        "+level-colors", f"{ink},{paper}",
    ]
    if reversed_:
        args += ["-rotate", "180"]
    args += ["-filter", "point", "-resize", f"{scale * 100}%"]
    out.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run([*args, str(out)], check=True)
    return out

def card_of_day_png(scheme: dict, layout: dict[str, int] | None = None) -> Path | None:
    ensure_dirs()
    if layout is None:
        try:
            layout = json.loads((STATE_DIR / "lock.json").read_text())
        except (OSError, json.JSONDecodeError):
            layout = {"card_w": 320, "scale": 2}
    width, scale = layout["card_w"], layout.get("scale", 2)
    if width <= 0:
        return None
    seed, _ = host_digest()
    today = date.today()
    draw = card_of_day(today, seed)
    src = art_path(draw.card, CACHE_DIR / "tarot")
    if not src.exists():
        return None
    out = CACHE_DIR / "tarot-day.png"
    stamp = CACHE_DIR / "tarot-day.stamp"
    key = f"{today} {draw.card.name} {'reversed' if draw.reversed else 'upright'} {width}@{scale}"
    try:
        current = stamp.read_text()
    except OSError:
        current = ""
    if current != key or not out.exists():
        card_image(src, scheme, draw.reversed, out, width=width, scale=scale)
        stamp.write_text(key)
    return out

def generate_hyprlock_config(scheme: dict, size: tuple[int, int]) -> str:
    ensure_dirs()
    layout = lock_layout(size, 0, 2)
    (STATE_DIR / "lock.json").write_text(json.dumps(layout))
    
    wall_source = (
        LOCK_WALLPAPER
        if LOCK_WALLPAPER.is_file()
        else CACHE_DIR / "wall" / f"lock-umber-{size[0]}x{size[1]}@2.png"
    )
    sigil_path = CACHE_DIR / "sigil-umber.png"
    card_png = CACHE_DIR / "tarot-day.png"
    bin_path = shutil.which("sefirah") or "sefirah"
    
    # Generate sigil
    digest, _ = host_digest()
    cells = sigil_grid(digest)
    sigil_path.write_bytes(sigil_png(cells, scheme["fg"]))
    
    # Generate tarot card
    card_of_day_png(scheme, layout)
    
    beside_x = layout["lock_x"] + 104
    text_w = TEXT_COLUMN
    _, fingerprint = host_digest()
    fingerprint = fingerprint_short(fingerprint)
    
    template = f'''# Generated by sefirah transmute (Umber). Edits are overwritten.

general {{
    hide_cursor = true
    immediate_render = true
}}

animations {{
    enabled = false
}}

background {{
    monitor =
    path = {wall_source}
    color = rgb({scheme["bg"].lstrip("#")})
}}

image {{
    monitor =
    path = {sigil_path}
    size = 88
    rounding = 0
    border_size = 0
    position = {layout["lock_x"]}, -72
    halign = left
    valign = top
}}

label {{
    monitor =
    text = {socket.gethostname()}
    color = rgb({scheme["fg"].lstrip("#")})
    font_family = PxPlus IBM VGA 8x16
    font_size = 13
    position = {beside_x}, -92
    halign = left
    valign = top
}}

label {{
    monitor =
    text = {fingerprint}
    color = rgb({scheme["dim"].lstrip("#")})
    font_family = PxPlus IBM VGA 8x16
    font_size = 13
    position = {beside_x}, -116
    halign = left
    valign = top
}}

label {{
    monitor =
    text = $TIME
    color = rgb({scheme["fg"].lstrip("#")})
    font_family = Jacquard 24,
    font_size = 161
    position = {layout["lock_x"]}, -210
    halign = left
    valign = top
}}

label {{
    monitor =
    text = cmd[update:60000] {bin_path} hour --lock {scheme["fg"].lstrip("#")},{scheme["active"].lstrip("#")},{scheme["dim"].lstrip("#")}
    color = rgb({scheme["fg"].lstrip("#")})
    font_family = PxPlus IBM VGA 8x16
    font_size = 13
    position = {layout["lock_x"]}, -460
    halign = left
    valign = top
}}

image {{
    monitor =
    path = {card_png}
    reload_cmd = {bin_path} draw --png
    reload_time = 600
    size = {layout["card_w"]}
    rounding = 0
    border_size = 0
    position = -72, 0
    halign = right
    valign = center
}}

label {{
    monitor =
    text = @ {getpass.getuser()}, speak the word:
    color = rgb({scheme["fg"].lstrip("#")})
    font_family = PxPlus IBM VGA 8x16
    font_size = 13
    position = {layout["lock_x"]}, 168
    halign = left
    valign = bottom
}}

input-field {{
    monitor =
    size = {text_w}, 48
    outline_thickness = 2
    rounding = 0
    outer_color = rgb({scheme["active"].lstrip("#")})
    inner_color = rgb({scheme["bg"].lstrip("#")})
    font_color = rgb({scheme["fg"].lstrip("#")})
    font_family = PxPlus IBM VGA 8x16
    check_color = rgb({scheme["a3"].lstrip("#")})
    fail_color = rgb({scheme["a1"].lstrip("#")})
    capslock_color = rgb({scheme["active"].lstrip("#")})
    fail_text = The word is wrong. ($ATTEMPTS)
    placeholder_text =
    fade_on_empty = false
    dots_size = 0.2
    dots_spacing = 0.4
    dots_rounding = 0
    position = {layout["lock_x"]}, 108
    halign = left
    valign = bottom
}}

label {{
    monitor =
    text = cmd[update:5000] {bin_path} status --short
    color = rgb({scheme["dim"].lstrip("#")})
    font_family = PxPlus IBM VGA 8x16
    font_size = 13
    position = {layout["lock_x"]}, 64
    halign = left
    valign = bottom
}}
'''
    return template

def cmd_transmute(args) -> None:
    scheme = UMBER
    size = screen_size()
    config = generate_hyprlock_config(scheme, size)
    out_dir = CONFIG_DIR / "current" / "hypr"
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "hyprlock.conf").write_text(config)
    print(f"Generated {out_dir / 'hyprlock.conf'}")

# ==================== COMMANDS ====================

def cmd_hour(args) -> None:
    place = None
    if args.lat is not None and args.lon is not None:
        place = (args.lat, args.lon)
    now = datetime.now().astimezone()
    lines = hour_lines(now, place)
    if args.lock:
        print(lock_markup(lines, args.lock))
    elif args.waybar:
        tip = "\n".join(lines[k] for k in ("ruler", "sun", "moon", "card"))
        print(json.dumps({"text": lines["bar"], "tooltip": tip}))
    else:
        print("\n".join(lines[k] for k in ("date", "ruler", "moon", "card")))

def cmd_draw(args) -> None:
    seed, _ = host_digest()
    today = date.today()
    draw = card_of_day(today, seed)
    if args.png:
        card_of_day_png(UMBER)
        out = CACHE_DIR / "tarot-day.png"
        if out.exists():
            print(out)
        else:
            print("Tarot art not found. Run: sefirah cards fetch", file=sys.stderr)
            sys.exit(1)
        return
    if args.day:
        print(f"{draw.card.name} {'reversed' if draw.reversed else 'upright'}")
    elif args.card:
        for name in args.card:
            card = next((c for c in DECK if c.name.lower() == name.lower()), None)
            if card:
                print(f"{card.name} {'reversed' if args.reversed else 'upright'}")
            else:
                print(f"Unknown card: {name}", file=sys.stderr)

def cmd_status(args) -> None:
    cpu = Cpu()
    r = read_status(cpu)
    if args.short:
        print(short(r))
    elif args.waybar:
        print(json.dumps({"text": short(r), "tooltip": f"CPU: {r.cpu}% | Mem: {r.mem//1024//1024}MiB | Up: {r.minutes}m"}))
    else:
        fields = [hp(r.battery), f"Str:{r.cpu}%", f"Mem:{r.mem//1024//1024}M", f"T:{r.minutes}m"]
        if r.sick:
            fields.append("Kernel mismatch!")
        print("  ".join(fields))

def cmd_sigil(args) -> None:
    digest, fptype = host_digest()
    cells = sigil_grid(digest)
    if args.fingerprint:
        print(fingerprint_short(fingerprint_text(digest)))
        return
    if args.png:
        color = args.color or UMBER["fg"]
        png_data = sigil_png(cells, color, args.scale)
        out = Path(args.output) if args.output else CACHE_DIR / "sigil.png"
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_bytes(png_data)
        print(out)
    else:
        print(f"Type: {fptype}")
        print(f"Fingerprint: {fingerprint_text(digest)}")
        print()
        print(sigil_text(cells))

def cmd_cards(args) -> None:
    art_dir = CACHE_DIR / "tarot"
    if args.fetch or args.action == "fetch":
        fetched = fetch_art(art_dir)
        have = sum(art_path(c, art_dir).exists() for c in DECK)
        head = f"Fetched {fetched}. " if fetched else ""
        print(f"{head}{have} cards in {art_dir}.")
    else:
        for c in DECK:
            print(c.title)

# ==================== MAIN ====================

def main() -> None:
    p = argparse.ArgumentParser(prog="sefirah", description="Sefirah lock screen utilities")
    sub = p.add_subparsers(dest="cmd", required=True)

    ph = sub.add_parser("hour", help="Planetary hour")
    ph.add_argument("--lat", type=float)
    ph.add_argument("--lon", type=float)
    ph.add_argument("--lock", help="Pango markup for hyprlock: FG,ACTIVE,DIM")
    ph.add_argument("--waybar", action="store_true")
    ph.add_argument("--follow", action="store_true")

    dr = sub.add_parser("draw", help="Draw tarot cards")
    dr.add_argument("--day", action="store_true")
    dr.add_argument("--card", action="append")
    dr.add_argument("--png", action="store_true")
    dr.add_argument("--reversed", action="store_true")

    st = sub.add_parser("status", help="System status")
    st.add_argument("--short", action="store_true")
    st.add_argument("--waybar", action="store_true")

    sg = sub.add_parser("sigil", help="Machine sigil")
    sg.add_argument("--png", action="store_true")
    sg.add_argument("--fingerprint", action="store_true")
    sg.add_argument("--color", default=UMBER["fg"])
    sg.add_argument("--scale", type=int, default=8)
    sg.add_argument("--output")

    ca = sub.add_parser("cards", help="Tarot deck")
    ca.add_argument("action", nargs="?", choices=("list", "fetch"), default="list")
    ca.add_argument("--fetch", action="store_true")

    tr = sub.add_parser("transmute", help="Generate hyprlock config")

    args = p.parse_args()

    if args.cmd == "hour":
        cmd_hour(args)
    elif args.cmd == "draw":
        cmd_draw(args)
    elif args.cmd == "status":
        cmd_status(args)
    elif args.cmd == "sigil":
        cmd_sigil(args)
    elif args.cmd == "cards":
        cmd_cards(args)
    elif args.cmd == "transmute":
        cmd_transmute(args)

if __name__ == "__main__":
    main()
