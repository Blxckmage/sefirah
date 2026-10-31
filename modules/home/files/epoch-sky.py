import argparse
import json
import time
from dataclasses import dataclass
from datetime import UTC, date, datetime, time as dtime, timedelta

CHALDEAN = ("Saturn", "Jupiter", "Mars", "Sun", "Venus", "Mercury", "Moon")
DAY_RULER = (6, 2, 5, 1, 4, 0, 3)
SYNODIC_MONTH = 29.530588853
NEW_MOON_EPOCH = datetime(2000, 1, 6, 18, 14, tzinfo=UTC)
PHASES = (
    "new",
    "waxing crescent",
    "first quarter",
    "waxing gibbous",
    "full",
    "waning gibbous",
    "last quarter",
    "waning crescent",
)


@dataclass(frozen=True)
class Hour:
    day: date
    day_ruler: str
    planet: str
    index: int
    is_day: bool
    sunrise: datetime
    sunset: datetime


def with_article(planet):
    return f"the {planet}" if planet in ("Sun", "Moon") else planet


def moon_age(now):
    days = (now - NEW_MOON_EPOCH).total_seconds() / 86400
    return days % SYNODIC_MONTH


def moon_phase(now):
    fraction = moon_age(now) / SYNODIC_MONTH
    return PHASES[int(fraction * 8 + 0.5) % 8]


def moon_trend(now):
    phase = moon_phase(now)
    if phase in ("new", "full"):
        return phase
    return "waxing" if moon_age(now) < SYNODIC_MONTH / 2 else "waning"


def civil_bounds(day, tz):
    return datetime.combine(day, dtime(6), tz), datetime.combine(day, dtime(18), tz)


def planetary_hour(now):
    tz = now.tzinfo
    today = now.date()
    rise, set_ = civil_bounds(today, tz)

    if now < rise:
        day = today - timedelta(days=1)
        prev_rise, prev_set = civil_bounds(day, tz)
        start, end, offset, is_day = prev_set, rise, 12, False
        rise, set_ = prev_rise, prev_set
    elif now < set_:
        day, start, end, offset, is_day = today, rise, set_, 0, True
    else:
        day = today
        next_rise, _ = civil_bounds(today + timedelta(days=1), tz)
        start, end, offset, is_day = set_, next_rise, 12, False

    span = (end - start) / 12
    index = offset + min(11, int((now - start) / span))
    ruler = DAY_RULER[day.weekday()]
    return Hour(
        day=day,
        day_ruler=CHALDEAN[ruler],
        planet=CHALDEAN[(ruler + index) % 7],
        index=index,
        is_day=is_day,
        sunrise=rise,
        sunset=set_,
    )


def render(now):
    hour = planetary_hour(now)
    day_name = with_article(hour.day_ruler)
    hour_name = with_article(hour.planet)
    text = f"Hour of {hour_name}~  Moon: {moon_trend(now)}"
    tooltip = "\n".join(
        [
            f"Day of {day_name}, hour of {hour_name}~",
            f"Sunrise {hour.sunrise:%H:%M}, sunset {hour.sunset:%H:%M} (civil hours)",
            f"Moon {moon_phase(now)}, {moon_age(now):.0f} days old",
        ]
    )
    return text, tooltip


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--waybar", action="store_true")
    parser.add_argument("--follow", action="store_true")
    args = parser.parse_args()

    while True:
        now = datetime.now().astimezone()
        text, tooltip = render(now)
        if args.waybar:
            print(json.dumps({"text": text, "tooltip": tooltip, "class": []}), flush=True)
        else:
            print(text)
            print(tooltip)
        if not args.follow:
            return
        time.sleep(60.5 - time.time() % 60)


if __name__ == "__main__":
    main()
