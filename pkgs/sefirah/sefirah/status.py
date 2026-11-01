"""Battery, CPU, memory and uptime status."""
import json
import os
from dataclasses import dataclass
from pathlib import Path
from time import sleep

from .common import MODULES, POWER, _read


@dataclass(frozen=True)
class Battery:
    percent: int
    health: int
    charging: bool


@dataclass(frozen=True)
class Reading:
    battery: Battery | None
    cpu: int
    mem: int
    minutes: int
    sick: bool = False


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
        sleep(0.1)
        cur = self._read()
        prev = self.prev
        self.prev = cur
        busy = sum(cur[i] - prev[i] for i in (0, 1, 2, 5, 6, 7))
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


def cmd_status(args) -> None:
    cpu = Cpu()
    r = read_status(cpu)
    if args.short:
        print(short(r))
    elif args.waybar:
        print(json.dumps({"text": short(r), "tooltip": f"CPU: {r.cpu}% | Mem: {r.mem // 1024}MiB | Up: {r.minutes}m"}))
    else:
        fields = [hp(r.battery), f"Str:{r.cpu}%", f"Mem:{r.mem // 1024}M", f"T:{r.minutes}m"]
        if r.sick:
            fields.append("Kernel mismatch!")
        print("  ".join(fields))
