"""`hour` command: planetary hour and moon."""
import html
import json
from datetime import datetime

from .common import ordinal
from .sigil import host_digest
from .sky import moon_age, moon_phase, moon_trend, planetary_hour, with_article
from .tarot import card_of_day


def hour_lines(now: datetime) -> dict[str, str]:
    ph = planetary_hour(now)
    day, hour = with_article(ph.ruler), with_article(ph.planet)
    seed, _ = host_digest()
    card = card_of_day(now.date(), seed)
    return {
        "date": f"{now:%A}, the {ordinal(now.day)} of {now:%B}",
        "ruler": f"Day of {day}, hour of {hour}",
        "moon": f"Moon {moon_phase(now).lower()}, {moon_age(now):.0f} days old",
        "card": f"Card of the day: {card.title}",
        "bar": f"{now:%a %-d %b  %H:%M}  Hour of {hour}  Moon: {moon_trend(now)}",
        "sun": f"Hours {ph.sunrise:%H:%M}-{ph.sunset:%H:%M}",
    }


def lock_markup(lines: dict[str, str], colors: str) -> str:
    fg, active, dim = (f"#{c.lstrip('#')}" for c in colors.split(","))
    rows = [("date", fg), ("ruler", active), ("moon", dim), ("card", dim)]
    body = "\n".join(
        f'<span foreground="{c}">{html.escape(lines[k], quote=False)}</span>' for k, c in rows
    )
    return f'<span line_height="1.5">{body}</span>'


def cmd_hour(args) -> None:
    now = datetime.now().astimezone()
    lines = hour_lines(now)
    if args.lock:
        print(lock_markup(lines, args.lock))
    elif args.waybar:
        tip = "\n".join(lines[k] for k in ("ruler", "sun", "moon", "card"))
        print(json.dumps({"text": lines["bar"], "tooltip": tip}))
    else:
        print("\n".join(lines[k] for k in ("date", "ruler", "moon", "card")))
