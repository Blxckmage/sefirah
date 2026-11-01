"""Machine sigil and fingerprint."""
import base64
import hashlib
import struct
import zlib
from pathlib import Path

from .common import CACHE_DIR, UMBER

HOST_KEYS = ("ssh_host_ed25519_key.pub", "ssh_host_ecdsa_key.pub", "ssh_host_rsa_key.pub")
SIGIL_SIZE = 11


def key_digest(pub_line: str) -> bytes:
    blob = base64.b64decode(pub_line.split()[1])
    return hashlib.sha256(blob).digest()


def fingerprint_text(digest: bytes) -> str:
    return "SHA256:" + base64.b64encode(digest).decode().rstrip("=")


def fingerprint_short(text: str) -> str:
    return text if len(text) <= 23 else text[:20] + "..."


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
