#!/usr/bin/env python3
"""gen_waveform_ic307_s.py -- one-shot generator of the KN5000 waveform ROM IC307 source tree, waveform/.

WHAT IT DOES
  Reads the IC307 reference image and the tracked table-data image, and writes
    waveform/kn5000_waveform_ic307.s   root file: format header, the four page includes
    waveform/waveform_macros.inc       WaveDirEntry / WaveRecHead / WaveSplit / WaveSeq
    waveform/ic307_page<N>.s           per page: directory, parameter records, the PCM waves, the 0xFF tail
  The directory and the parameter records become typed rows with symbolic pointers.  Each distinct PCM wave
  is one labelled `.incbin` of the git-ignored reference image, marked `census: opaque -- pcm`, with a comment
  giving its length, the directory entries that start on it, and the wave sources, tones, drum instruments,
  multisample SETs and drawbar zone records whose recording selector (class << 12) + entry reaches those
  entries (notes/waveform-ic307-2026-10-29/probes/tonedb_selector_users.py walks that chain).

  Like kn7000's gen_picture_s.py, this is a ONE-SHOT generator: after the first run the waveform/ sources are
  the authoritative, hand-editable source.  Re-running it overwrites them (it refuses unless --force), so keep
  it only to show how the tree was made, or to regenerate before any hand edits exist.

USAGE
  python3 scripts/generators/gen_waveform_ic307_s.py [--ic307 PATH] [--force]
"""
import argparse
import importlib.util
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
PROBES = ROOT / "notes" / "waveform-ic307-2026-10-29" / "probes"
OUT = ROOT / "waveform"
REF = "kn5000_waveform_rom.ic307"   # found through -I original_ROMs
PAGE = 0x100000


def load(name):
    spec = importlib.util.spec_from_file_location(name, PROBES / (name + ".py"))
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def ident(name):
    s = name.replace("'", "ft").replace("&", " And ").replace("+", " Plus ")
    words = re.findall(r"[A-Za-z0-9]+", s)
    return "".join(w[:1].upper() + w[1:] for w in words)


def short_list(names, k=6):
    names = sorted(names)
    s = ", ".join(names[:k])
    if len(names) > k:
        s += " +%d more" % (len(names) - k)
    return s


def s8(v):
    return v - 256 if v >= 0x80 else v


def word_line(v, f, split):
    end, mark = f >> 7, (f >> 6) & 1
    extra = (", mark=1" if mark else "") + (", end=1" if end else "")
    if split(v, f):
        return "\tWaveSplit\t%d%s" % (v, extra)
    return "\tWaveSeq\t%d, %d, %d%s" % (s8(v), (f >> 3) & 7, f & 7, extra)


def users_text(u, sel):
    x = u.get(sel)
    if x is None or not (x["src"] or x["drawbar"]):
        return "no SET zone record or drawbar zone record selects it"
    parts = []
    if x["src"]:
        parts.append("source " + ", ".join('"%s"' % s for s in sorted(x["src"])))
    if x["tone"]:
        parts.append("tones " + short_list(x["tone"]))
    if x["perc"]:
        parts.append("drums " + short_list(x["perc"]))
    if x["set"]:
        parts.append("SET " + ", ".join("%03d" % s for s in sorted(x["set"])))
    if x["drawbar"]:
        db = sorted(x["drawbar"])
        parts.append("drawbar " + ", ".join("EnvData_%d #%d" % d for d in db[:4])
                     + (" +%d more" % (len(db) - 4) if len(db) > 4 else ""))
    return "; ".join(parts)


MACROS = r"""; waveform_macros.inc -- one macro per IC307 record kind.  Layout and evidence: kn5000_waveform_ic307.s.
;
; A directory entry: the parameter record's offset from the page base, and the wave's start in 16-byte
; granules from the page base.
.macro WaveDirEntry base, rec, wave
	.short	\rec - \base, (\wave - \base) / 16
.endm
;
; A parameter record's head word repeats its entry's wave offset (1495 of 1495 records do).
.macro WaveRecHead base, wave
	.short	(\wave - \base) / 16
.endm
;
; Key-split word: flag bits 5..0 clear, value a multiple of 8 up to 0x80.  Values within a record descend;
; against the tone database's zone tables the earlier measurement is key = 1.5 x (value - 0x28), i.e. one
; unit = 1/8 octave (waveform-rom-format.md; measured there, not re-derived here).  mark = flag bit 6,
; end = flag bit 7 (only ever on a record's last word).
.macro WaveSplit value, mark=0, end=0
	.byte	\value, (\end << 7) | (\mark << 6)
.endm
;
; Sequence word: an s8 value (negative in 6494 of 6526) and two 3-bit fields a = flag bits 5..3,
; b = flag bits 2..0, each 0..5 and |a - b| <= 1 in 6128 of 6526.  What the tone generator does with them is
; not known: no CPU reads this ROM.  mark / end as for WaveSplit.
.macro WaveSeq value, a, b, mark=0, end=0
	.byte	(\value) & 0xff, (\end << 7) | (\mark << 6) | (\a << 3) | \b
.endm
"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ic307")
    ap.add_argument("--force", action="store_true")
    a = ap.parse_args()
    if (OUT / "kn5000_waveform_ic307.s").exists() and not a.force:
        sys.exit("waveform/ already exists and is the authoritative source; pass --force to overwrite it")
    lay = load("ic307_layout")
    tus = load("tonedb_selector_users")
    path = pathlib.Path(a.ic307) if a.ic307 else lay.default_path()
    data = path.read_bytes()
    pages = lay.parse(data)
    u, _sets = tus.users()
    OUT.mkdir(exist_ok=True)
    (OUT / "waveform_macros.inc").write_text(MACROS)

    for p, pg in enumerate(pages):
        base = "IC307_Page%d" % p
        cls = 4 + p
        waves = pg["waves"]
        widx = {o: k for k, (o, _s) in enumerate(waves)}
        wentries = {}
        for i, (_pp, wu) in enumerate(pg["entries"]):
            wentries.setdefault(wu * 16, []).append(i)
        # wave labels
        wlab = {}
        for o, _s in waves:
            src, db = set(), False
            for i in wentries[o]:
                x = u.get((cls << 12) + i)
                if x:
                    src |= x["src"]
                    db = db or bool(x["drawbar"])
            nm = ""
            if len(src) == 1:
                nm = "_" + ident(next(iter(src)))
            elif not src and db:
                nm = "_Drawbar"
            wlab[o] = "P%d_W%04d%s" % (p, widx[o], nm)
        L = []
        L.append("; IC307 page %d: file offset 0x%06x, %d directory entries = recording selectors 0x%x000-0x%x%03x"
                 % (p, p * PAGE, pg["n"], cls, cls, pg["n"] - 1))
        L.append("; (class %d; the class-to-page match is argued in kn5000_waveform_ic307.s), %d distinct waves."
                 % (cls, len(waves)))
        L.append("")
        L.append("; ---- directory: {parameter record, wave start / 16}; entry 0's record follows the table ----")
        L.append("%s:" % base)
        for i, (_pp, wu) in enumerate(pg["entries"]):
            L.append("\tWaveDirEntry\t%s, P%d_Rec%04d, %s\t; %d, selector 0x%04x" % (base, p, i, wlab[wu * 16], i, (cls << 12) + i))
        L.append("")
        L.append("; ---- parameter records: head word, then [flags:8][value:8] words (macros in waveform_macros.inc) ----")
        for i, (pp, end, words) in enumerate(pg["records"]):
            sel = (cls << 12) + i
            L.append("; entry %d, selector 0x%04x: %s" % (i, sel, users_text(u, sel)))
            L.append("P%d_Rec%04d:\tWaveRecHead\t%s, %s" % (p, i, base, wlab[pg["entries"][i][1] * 16]))
            for v, f in words:
                L.append(word_line(v, f, lay.is_split))
        L.append("; the first wave starts on a 16-byte granule (wave offsets count granules): zero fill")
        L.append("\t.balign\t16, 0")
        L.append("")
        L.append("; ---- PCM: signed 16-bit little-endian samples, one item per distinct wave start ----")
        L.append("; A wave's length here is the distance to the next wave start (or to the 0xFF tail); where a")
        L.append("; sequence record runs on past that point, the entry plays on into the next item (see the notes).")
        for o, sz in waves:
            ents = wentries[o]
            srcs, tones, percs = set(), set(), set()
            for i in ents:
                x = u.get((cls << 12) + i)
                if x:
                    srcs |= x["src"]
                    tones |= x["tone"]
                    percs |= x["perc"]
            desc = "wave %d: %s samples (%s B); entr%s %s" % (
                widx[o], format(sz // 2, ","), format(sz, ","), "y" if len(ents) == 1 else "ies",
                ", ".join(str(i) for i in ents))
            L.append("; " + desc)
            if srcs:
                L.append(";   source %s" % ", ".join('"%s"' % s for s in sorted(srcs)))
            if tones:
                L.append(";   tones %s" % short_list(tones, 8))
            if percs:
                L.append(";   drums %s" % short_list(percs, 8))
            L.append('%s:\t.incbin\t"%s", 0x%06x, %d\t; census: opaque -- pcm: signed 16-bit LE samples, no CPU reads them'
                     % (wlab[o], REF, p * PAGE + o, sz))
        L.append("")
        L.append("; ---- page tail: %d bytes of 0xFF after the last wave ----" % pg["tail"])
        L.append("IC307_Page%d_TailFill:\t.fill\t%d, 1, 0xff" % (p, pg["tail"]))
        L.append("\t.org\t0x%06x" % ((p + 1) * PAGE))
        (OUT / ("ic307_page%d.s" % p)).write_text("\n".join(L) + "\n")
    root = ["; kn5000_waveform_ic307.s -- KN5000 waveform ROM IC307 (generated by scripts/generators/gen_waveform_ic307_s.py;",
            "; hand-edited since: this file is the authoritative source).", "", "\t.text", "",
            '\t.include\t"waveform_macros.inc"', ""]
    root += ['\t.include\t"ic307_page%d.s"' % p for p in range(4)]
    (OUT / "kn5000_waveform_ic307.s").write_text("\n".join(root) + "\n")
    print("wrote", ", ".join(sorted(x.name for x in OUT.iterdir())))


if __name__ == "__main__":
    main()
