#!/usr/bin/env python3
"""Generate exhaustive parity test cases from fizzctl (the project this tool's protocol comes from).

    pip install fizzctl --ignore-requires-python --no-deps     # or: --fizzctl-path <unpacked wheel dir>
    python3 dev/reference/gen_cases.py --out cases.json
    pwsh dev/reference/check-frames.ps1 cases.json

Every effect x speed x brightness x color combination, plus per-key and paint frames, is encoded by
fizzctl and hashed; check-frames.ps1 then builds the same frames with fizz-gui.ps1 and compares.

One deliberate difference: fizzctl only verified the color position of effects 1, 10 and 13 and puts
every other effect's color into effect 10's slot. fizz-gui.ps1 uses the per-effect record
(29 + 21 * (id - 1)) for all effects that the vendor table marks as color-capable. This script patches
fizzctl in memory to the same rule, so any other difference between the two is reported.
"""
import argparse, hashlib, json, random, sys, types

ap = argparse.ArgumentParser()
ap.add_argument("--out", default="cases.json")
ap.add_argument("--fizzctl-path", default=None, help="directory that contains the fizzctl package")
args = ap.parse_args()
if args.fizzctl_path:
    sys.path.insert(0, args.fizzctl_path)
try:
    import hid  # noqa: F401  (real hidapi, if installed)
except ImportError:
    sys.modules["hid"] = types.ModuleType("hid")  # only the transport needs it

import fizzctl.effects as e
import fizzctl.protocol as p
from fizzctl.hid import rgb_sequence

# effect ids whose vendor capability table entry allows a custom color
COLOR_CAPABLE_IDS = {1, 2, 4, 5, 7, 8, 9, 10, 11, 12, 13, 14, 18, 19, 20}
e.EFFECT_ACCEPTS_COLOR = {n for n, eid in e.EFFECT_ID.items() if eid in COLOR_CAPABLE_IDS}
e._color_slot = lambda name: tuple(29 + 21 * (e.EFFECT_ID[name] - 1) + k for k in range(3))


def digest(frames):
    return hashlib.sha256(b"".join(frames)).hexdigest()


cases = []
for name in e.EFFECT_ID:
    for speed in (None, 0, 1, 2, 3, 4, 5, 9):
        for bri in (None, 0, 1, 2, 3, 4, 7):
            for color in (None, (255, 0, 0), (1, 2, 3), (0, 255, 128)):
                cases.append(dict(kind="effect", name=name, speed=speed, bri=bri, color=color,
                                  sha=digest(e.encode_firmware_effect(name, color, speed, bri))))
rnd = random.Random(617)
keys = list(e.PER_KEY_POS)
led_names = list(p.NAME_TO_INDEX)
for _ in range(80):
    sel = rnd.sample(keys, rnd.randint(0, len(keys)))
    cols = [[k, [rnd.randrange(256) for _ in range(3)]] for k in sel]
    cases.append(dict(kind="perkey", colors=cols,
                      sha=digest([e.encode_per_key_frame({k: tuple(c) for k, c in cols})])))
    sel = rnd.sample(led_names, rnd.randint(1, len(led_names)))
    cols = [[k, [rnd.randrange(256) for _ in range(3)]] for k in sel]
    cases.append(dict(kind="paint", colors=cols, sha=digest(rgb_sequence({k: tuple(c) for k, c in cols}))))
json.dump(cases, open(args.out, "w"))
print(f"{len(cases)} cases written to {args.out}")
