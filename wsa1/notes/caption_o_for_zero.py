#!/usr/bin/env python3
"""Read a WSA1 screen caption's digit 0 as the letter O when it stands for one -- for NAMES only.

QUESTION IT ANSWERS
    "This caption word is typed with 0x30 (the digit zero) in the ROM.  Which of its zeros are the
     letter O, so that a label made from the caption spells the word?"

    The SX-WSA1R firmware types many captions with the digit zero for capital O (`DISK L0AD`, `FL0PPY`,
    `F0RMAT`, `FILE SELECTI0N`, `LF01`).  The font cannot show the difference: Font_Svc06_8x14 cell 0x30
    and cell 0x4F are the same fourteen bytes (notes/gen_prom_b_f58000_module.py --selftest checks it).
    The owner decided on 2026-11-06 that label names spell the word with O
    (`scripts/renaming/rename_wsa1_zero_for_o.sed`, `notes/zero-for-o/README.md`).  The ROM's bytes,
    and every comment that quotes them, keep the zero.

    Every generator that builds a label from caption text (gen_prom_b_f067a6_module.py --dl-names, the
    title rules of prom_b_dl_screens_round5.py, prom_a_dl_text_names.py, prom_b_screens_round8.py,
    prom_b_entrypoints_round7.py, prom_a_understanding_round7.py, gen_prom_b_f17559_module.py) passes each
    caption word through o_for_zero() before it CamelCases it, so a re-run emits the spelling the tree has.

THE RULE, per maximal run of letters and zeros in the caption (call it on the WHOLE caption, not on
words split out of it: the character before a run decides)
    a zero is the letter O when the run holds at least one letter, and
      * the run does not follow a digit 1-9 (`720K`, `10k`, `40K`, `\\240es` keep their zeros),
      * the run does not follow a decimal point after a digit (`2.0k`, the DLB frequency tables), and
      * the run is not a single letter plus zeros running into a digit (`P07` keeps its zero).
    So `L0AD` -> `LOAD`, `0PTI0N` -> `OPTION`, `0K` -> `OK`, `N0` -> `NO`, `LF01` -> `LFO1`,
    `R0M1` -> `ROM1`, `C0NTR0LLER` -> `CONTROLLER`.
    ⚠ The bank names "WSA SOUND RAM S0" .. "S3" are a real digit that this rule would read as `SO`.
    They are not display-list captions and no generator names a label from them; the labels that carry
    them (`SoundRam_BankName_S0`) are listed as kept in notes/zero-for-o/kept.tsv.

RUN
    python3 notes/caption_o_for_zero.py --selftest
"""
import re
import sys

_RUN = re.compile(r"[A-Za-z0]+")


def o_for_zero(word):
    """`word` with every zero that stands for the letter O replaced by `O` (see the module docstring)."""
    out, last = [], 0
    for m in _RUN.finditer(word):
        run = m.group()
        letters = sum(ch.isalpha() for ch in run)
        before = word[m.start() - 1] if m.start() else ""
        before2 = word[m.start() - 2] if m.start() > 1 else ""
        after = word[m.end()] if m.end() < len(word) else ""
        keep = (not letters or (before.isdigit() and before != "0")
                or (before in ".," and before2.isdigit())
                or (letters < 2 and after.isdigit()))
        out.append(word[last:m.start()])
        out.append(run if keep else run.replace("0", "O"))
        last = m.end()
    out.append(word[last:])
    return "".join(out)


def camel(text, split=r"[^A-Za-z0-9]+"):
    """CamelCase of a caption read through o_for_zero() first."""
    words = [w for w in re.split(split, o_for_zero(text)) if w]
    return "".join(w[:1].upper() + w[1:].lower() for w in words)


CASES = [
    ("L0AD", "LOAD"), ("FL0PPY", "FLOPPY"), ("F0RMAT", "FORMAT"), ("SELECTI0N", "SELECTION"),
    ("0PTI0N", "OPTION"), ("0K", "OK"), ("N0", "NO"), ("LF01", "LFO1"), ("LF0", "LFO"),
    ("R0M1", "ROM1"), ("C0NTR0LLER", "CONTROLLER"), ("0VERALL", "OVERALL"),
    ("720K", "720K"), ("1440K", "1440K"), ("10k", "10k"), ("40K", "40K"), ("10CH", "10CH"),
    ("P07", "P07"), ("020SOLO", "020SOLO"), ("240es", "240es"), ("2HD", "2HD"), ("100", "100"),
    ("2.0k", "2.0k"), ("1.2k 2.0k", "1.2k 2.0k"), ("YES  N0", "YES  NO"),
]
CAMEL = [
    ("MIDI FILE SAVE : FILE SELECTI0N", "MidiFileSaveFileSelection"),
    ("LF01", "Lfo1"), ("S0NG C0PY", "SongCopy"), ("0VERALL T0UCH SENSITIVITY", "OverallTouchSensitivity"),
    ("Select the F0RMAT type for your disk.", "SelectTheFormatTypeForYourDisk"),
    ("1.2k", "12k"), ("2.0k", "20k"),
]


def selftest():
    bad = 0
    for got, want in [(o_for_zero(a), b) for a, b in CASES] + [(camel(a), b) for a, b in CAMEL]:
        ok = got == want
        bad += not ok
        print("%s  %-34s %s" % ("ok  " if ok else "FAIL", got, "" if ok else "want " + want))
    print("FAILURES: %d" % bad)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(selftest() if "--selftest" in sys.argv else (print(__doc__) or 0))
