"""Planetary hours and moon phase."""
from dataclasses import dataclass
from datetime import UTC, date, datetime, time, timedelta, tzinfo

CHALDEAN = ("Saturn", "Jupiter", "Mars", "Sun", "Venus", "Mercury", "Moon")
DAY_RULER = (6, 2, 5, 1, 4, 0, 3)  # Monday first
SYNODIC_MONTH = 29.530588853
NEW_MOON_EPOCH = datetime(2000, 1, 6, 18, 14, tzinfo=UTC)

PHASES = (
    "New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous",
    "Full Moon", "Waning Gibbous", "Last Quarter", "Waning Crescent",
)


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


def _civil(d: date, tz: tzinfo) -> tuple[datetime, datetime]:
    return datetime.combine(d, time(6), tz), datetime.combine(d, time(18), tz)


def planetary_hour(now: datetime) -> PlanetaryHour:
    # shortcut: days run 06:00-18:00 until a location is configured; wire real
    # sun times back in (with a test) if `hour` must track the actual sun.
    tz = now.tzinfo
    d = now.astimezone(tz).date()
    sunrise, sunset = _civil(d, tz)
    day_len = (sunset - sunrise).total_seconds() / 3600
    night_len = 24 - day_len
    ruler_idx = DAY_RULER[d.weekday()]
    if sunrise <= now < sunset:
        index = int((now - sunrise).total_seconds() / 3600 / (day_len / 12))
        start = sunrise + timedelta(hours=index * day_len / 12)
        end = start + timedelta(hours=day_len / 12)
    else:
        night_start = sunset if now >= sunset else sunset - timedelta(days=1)
        index = 12 + int((now - night_start).total_seconds() / 3600 / (night_len / 12))
        start = night_start + timedelta(hours=(index - 12) * night_len / 12)
        end = start + timedelta(hours=night_len / 12)
    planet = CHALDEAN[(ruler_idx + index) % 7]
    return PlanetaryHour(d, CHALDEAN[ruler_idx], index, planet,
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
