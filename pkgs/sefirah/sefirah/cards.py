"""`cards` command: list or fetch tarot artwork."""
from .common import CACHE_DIR
from .tarot import DECK, art_path, fetch_art


def cmd_cards(args) -> None:
    art_dir = CACHE_DIR / "tarot"
    if args.action == "fetch":
        fetched = fetch_art(art_dir)
        have = sum(art_path(c, art_dir).exists() for c in DECK)
        head = f"Fetched {fetched}. " if fetched else ""
        print(f"{head}{have} cards in {art_dir}.")
    else:
        for c in DECK:
            print(c.title)
