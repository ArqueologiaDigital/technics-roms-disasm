#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# endsig.py -- which program builds the menu can end without the firmware's "ERROR!" on (README.md "Ending").
# It does what FindEnd (menu.s) does, with the signatures of menu_data.s (sig_reqloop, sig_rq4, sig_prolog) and
# the offsets of menu.inc (EG_*), on each build's program flash, and prints per build: the hits of sig_reqloop
# (FindEnd wants exactly one), the request-4 dispatch found at EG_RQ4 or not, ChangeTitle from its two calls,
# ChangeMode and its prologue, the state byte V_RQSTATE, and ED99 (the byte 0xFE sets, which makes
# STYLCNVCONT open message 0x4A, "ERROR!"). A build prints "ok" when FindEnd would find everything.
#   python3 -I test/endsig.py [ROMDIR]     (ROMDIR: the emulator's roms/kn7000, default ~/compartilhado/kn7000-emulator/roms/kn7000)
import os
import re
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
MENU = os.path.dirname(HERE)
ROMS = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/compartilhado/kn7000-emulator/roms/kn7000")
BUILDS = ["v1.3_b893", "v1.4_b929_upper", "v1.5_b935", "v1.6_b941", "sp7001_b942"]
BASE = 0x48400000


def sigs():
    out, cur = {}, None
    for line in open(os.path.join(MENU, "menu_data.s")):
        m = re.match(r"(sig_\w+):", line)
        if m:
            cur = m.group(1)
            out[cur] = []
            continue
        m = re.match(r"\s*\.word\s+([^#]+)", line)
        if cur and m:
            out[cur] += [int(t, 0) for t in m.group(1).split(",")]
            if out[cur][-1] == 0xFFFF:
                out[cur].pop()
                cur = None
        elif cur and line.strip() and not line.strip().startswith("#"):
            cur = None
    return {k: re.compile(b"".join(b"." if e == 0x100 else re.escape(bytes([e])) for e in v), re.S) for k, v in out.items()}


def consts():
    c = {}
    for line in open(os.path.join(MENU, "menu.inc")):
        m = re.match(r"\s*\.equ\s+(EG_\w+)\s*,\s*(\w+)", line)
        if m:
            c[m.group(1)] = int(m.group(2), 0)
    return c


def flash(b):
    e = open(os.path.join(ROMS, f"kn7000_program_even_{b}.ic17"), "rb").read()
    o = open(os.path.join(ROMS, f"kn7000_program_odd_{b}.ic16"), "rb").read()
    img = bytearray(len(e) * 2)
    img[0::4], img[1::4], img[2::4], img[3::4] = e[0::2], e[1::2], o[0::2], o[1::2]
    return bytes(img)


S, C = sigs(), consts()
for b in BUILDS:
    try:
        img = flash(b)
    except OSError as ex:
        print(f"{b}: no image ({ex.strerror})")
        continue
    hits = [m.start() for m in S["sig_reqloop"].finditer(img)]
    if len(hits) != 1:
        print(f"{b}: sig_reqloop {len(hits)} hits: FindEnd finds nothing, the menu ends with 0xFE")
        continue
    h = hits[0]

    def target(off):
        return (BASE + h + off + struct.unpack_from("<I", img, h + off + 1)[0]) & 0xFFFFFFFF
    rq4 = S["sig_rq4"].match(img, h + C["EG_RQ4"]) is not None
    t49, t4c, cm = target(C["EG_TITLE49"]), target(C["EG_TITLE4C"]), target(C["EG_CHGMODE"])
    pro = S["sig_prolog"].match(img, cm - 5 - BASE) is not None
    state = struct.unpack_from("<I", img, h + C["EG_RQ4"] + 2)[0] if rq4 else 0
    ed99 = struct.unpack_from("<I", img, h + 0x34 + 11)[0]
    ok = rq4 and t49 == t4c and cm != t49 and pro and 0x50000000 <= state <= 0x503FFF00
    print(f"{b}: head {BASE + h:#010x}, request-4 dispatch at +{C['EG_RQ4']:#x} {'yes' if rq4 else 'NO'}, "
          f"ChangeTitle entry {t49:#010x}/{t4c:#010x}, ChangeMode {cm - 5:#010x} (prologue {'yes' if pro else 'NO'}), "
          f"state byte {state:#010x}, ED99 {ed99:#010x}: {'ok' if ok else 'NOT ok'}")
