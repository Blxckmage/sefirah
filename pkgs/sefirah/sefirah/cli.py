"""Command line parser and dispatch."""
import argparse

from .cards import cmd_cards
from .draw import cmd_draw
from .hour import cmd_hour
from .sigil import cmd_sigil
from .status import cmd_status
from .transmute import cmd_transmute


def main() -> None:
    p = argparse.ArgumentParser(prog="sefirah", description="Sefirah command line tools")
    sub = p.add_subparsers(dest="cmd", required=True)

    ph = sub.add_parser("hour", help="Planetary hour")
    ph.add_argument("--lock", help="Pango markup for hyprlock: FG,ACTIVE,DIM")
    ph.add_argument("--waybar", action="store_true")

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
    sg.add_argument("--color", default="#e3d6b8")
    sg.add_argument("--scale", type=int, default=8)
    sg.add_argument("--output")

    ca = sub.add_parser("cards", help="Tarot deck")
    ca.add_argument("action", nargs="?", choices=("list", "fetch"), default="list")

    sub.add_parser("transmute", help="Generate hyprlock config")

    args = p.parse_args()
    {
        "hour": cmd_hour,
        "draw": cmd_draw,
        "status": cmd_status,
        "sigil": cmd_sigil,
        "cards": cmd_cards,
        "transmute": cmd_transmute,
    }[args.cmd](args)
