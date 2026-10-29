"""Shared helpers for the IC14 probes: image loading, the event grammar, track walking."""
import hashlib
import os
import subprocess
import sys

REPO = subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True,
                      cwd=os.path.dirname(os.path.abspath(__file__))).stdout.strip()
IC14 = os.path.join(REPO, "original_ROMs/kn5000_rhythm_data_rom.ic14")      # `make` copies it (git-ignored)
V10 = os.path.join(REPO, "original_ROMs/kn5000_v10_program.rom")
SHA1 = "fef7f1927935d8fdada2afbdbfac29aac56e1c3c"
EV_LEN = {0x81: 1, 0x90: 6, 0x91: 8, 0xd1: 3, 0xd2: 3, 0xd3: 3, 0xd4: 3, 0xd5: 3}
BPB = [2, 4, 6, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8]   # AccTone_LookupByProgram_Table (v10 0xE46B8A)
LOCATORS = 0xE45142                                                  # RhythmROM_BankProgramLocators (v5..v10: see probe)
HALVES = range(0, 0x65000, 0x400)


def load(path=None):
    path = path or (sys.argv[1] if len(sys.argv) > 1 else IC14)
    d = open(path, "rb").read()
    if hashlib.sha1(d).hexdigest() != SHA1:
        sys.exit("%s is not the descrambled IC14 image (SHA-1 %s)" % (path, SHA1))
    return d


def u16(d, o):
    return d[o] | (d[o + 1] << 8)


def walk(d, t):
    """Events of the track at t (header 80 FF FF FF FF 87 checked); returns (events, end offset)."""
    assert d[t:t + 6] == bytes.fromhex("80ffffffff87"), hex(t)
    p, ev = t + 6, []
    while d[p] != 0x83:
        ev.append(d[p:p + EV_LEN[d[p]]])
        p += EV_LEN[d[p]]
    assert d[p + 1] == 0x87
    return ev, p + 2


def slot_targets(d, h):
    """[(part, slot, track offset)] of the half at h: bank = byte +0x3D1, word = offset in the bank."""
    bank = d[h + 0x3d1]
    return [(lane, s, bank * 0x10000 + u16(d, h + 0x118 + 0x26 * lane + 2 * s))
            for lane in range(6) for s in range(19)]
