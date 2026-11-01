"""`transmute` command: write the generated hyprlock config."""
from .common import CONFIG_DIR, UMBER
from .layout import generate_hyprlock_config, screen_size


def cmd_transmute(args) -> None:
    config = generate_hyprlock_config(UMBER, screen_size())
    out_dir = CONFIG_DIR / "current" / "hypr"
    out_dir.mkdir(parents=True, exist_ok=True)
    out = out_dir / "hyprlock.conf"
    tmp = out.with_name(out.name + ".tmp")
    tmp.write_text(config)
    tmp.replace(out)
    print(f"Generated {out}")
