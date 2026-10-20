#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# find_dspw.py -- does DSPTONE's run-time search (dsptone.s DspFind) find every routine it calls, in every KN7000
# program build we have? It is ../cnv_romdump/find_dsp.py's search (the handshake wait, the 2x16 register write
# and read, the index write, the guarded data read) plus the one DSPTONE adds, the guarded data-port WRITE that
# its uploads stream through:
#   the register write's second call (entry + 0x17: the DM-word writer, 941 0x4840511A) -> that routine's call at
#   its body + 0x11 -> the guarded write (941 0x48404EF8), which must be preceded by the "add -frame, sp" its
#   call allocates and begin "movhu d1, (0x1c, sp); movhu d0, (0x18, sp); movbu (dead), d0" with the same dead
#   flag the handshake wait sets.
#   python3 -I find_dspw.py          # the images under ~/compartilhado/technics_romsets and the disassembly's baserom
# Prints, per build, every address and "ok" when all of it holds (what DSPTONE needs before it touches the DSP).
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'cnv_romdump'))
import find_dsp as F  # noqa: E402

HEAD = bytes([0xf8, 0x97, 0x1c, 0xf8, 0x93, 0x18, 0xfc, 0xa8])   # dsptone.s WriteHead


def find_write(img, f):
    """the guarded data write's `calls` entry, or the reason it is not found"""
    t, fr = F.call_target(img, f['regwr'] + 0x17)
    if not t or not F.entry(img, t, fr):
        return None, 'the register write has no DM-word writer call at +0x17'
    t2, fr2 = F.call_target(img, t + 0x11)
    if not t2:
        return None, 'the DM-word writer has no call at body + 0x11'
    e = F.entry(img, t2, fr2)
    o = t2 - F.BASE
    if not e or bytes(img[o:o + 8]) != HEAD or F.u32(img, o + 8) != f['dead']:
        return None, 'the guarded write does not start as expected'
    return e, (t, t2)


def main():
    bad = 0
    for k, img in F.images().items():
        f = F.find(img)
        if isinstance(f, str):
            print(f'{k:22} not found: {f}')
            continue
        e, why = find_write(img, f)
        ok = f['ok'] and e is not None
        bad += 0 if ok else 1
        extra = f'datawr {e:#010x} (DM-word writer {why[0]:#010x}, body {why[1]:#010x})' if e else why
        print(f'{k:22} regrd {f["regrd"]:#010x} regwr {f["regwr"]:#010x} idxwr {f["idxwr"]:#010x} datard '
              f'{f["datard"]:#010x} {extra}; dead {f["dead"]:#010x} downloaded {f["downloaded"]:#010x}: '
              f'{"ok" if ok else "NOT ok"}')
    return bad


if __name__ == '__main__':
    sys.exit(1 if main() else 0)
