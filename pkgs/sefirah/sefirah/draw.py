"""`draw` command: daily tarot draw."""
import sys
from datetime import date

from .common import CACHE_DIR, UMBER
from .sigil import host_digest
from .tarot import DECK, card_of_day, card_of_day_png


def cmd_draw(args) -> None:
    seed, _ = host_digest()
    draw = card_of_day(date.today(), seed)
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
