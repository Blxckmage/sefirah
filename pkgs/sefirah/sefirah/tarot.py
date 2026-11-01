"""Tarot deck, daily draw and card artwork."""
import hashlib
import json
import subprocess
import urllib.parse
import urllib.request
from dataclasses import dataclass
from datetime import date
from pathlib import Path

from .common import CACHE_DIR, STATE_DIR, ensure_dirs
from .sigil import host_digest

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

SUITS = ("Wands", "Cups", "Swords", "Pentacles")
SUIT_FILES = ("Wands", "Cups", "Swords", "Pents")
RANKS = (
    ("Ace", 1), ("Two", 2), ("Three", 3), ("Four", 4), ("Five", 5),
    ("Six", 6), ("Seven", 7), ("Eight", 8), ("Nine", 9), ("Ten", 10),
    ("Page", 11), ("Knight", 12), ("Queen", 13), ("King", 14),
)

ROMAN = ["0", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX", "XXI"]

API = "https://commons.wikimedia.org/w/api.php"
USER_AGENT = "sefirah/0.1"


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

def card_of_day(day: date, seed: bytes) -> Draw:
    h = hashlib.sha256(day.isoformat().encode() + seed).digest()
    return Draw(DECK[int.from_bytes(h[:4]) % len(DECK)], bool(h[4] & 1))


def art_path(card: Card, art_dir: Path) -> Path:
    return art_dir / card.commons.replace(" ", "_")


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
                target = art_path(card, art_dir)
                tmp = target.with_suffix(".part")
                tmp.write_bytes(r.read())
                tmp.replace(target)
            fetched += 1
            log(f"fetched {card.name}")
    return fetched


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
    tmp = out.with_name(out.name + ".tmp" + out.suffix)
    subprocess.run([*args, str(tmp)], check=True)
    tmp.replace(out)
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
