#!/usr/bin/env python3
"""bit11_xprod.py -- what happens to each bit-11 (alternate-lo12) word in the OTHER product's copy
of the same program?  NEC uPD6383GF, SX-KN5000 IC311 + SX-WSA1R.  Static, stdlib only.

QUESTION IT ANSWERS
    `bit11-family.md' and `CORPUS-PATTERNS-SPECULATIVE.md' S-11 established, within each corpus,
    that selector `8BC' sits once per image in the first two words, on two carriers (fused into the
    body's first delay read `880.1.30.8BC', or on a bare class-0 word `040/050.0.00.8BC').  Nobody
    had asked the cross-product question: when a KN5000 program and its SX-WSA1R homolog are
    aligned word for word, is each bit-11 word kept, moved to another carrier, or DROPPED?  A word
    one product drops while the rest of the program stays aligned is an operation that program can
    do without -- which is a constraint on what it can mean, obtained without decoding it.

    Second output (`--dram'): the same alignment applied to the lo12 of the delay-DRAM escape
    words (`hi12 & 0x800', class 1), to see whether an ALU route MIGRATES between a DRAM word and
    an adjacent ALU word across the two products -- the shape the 8BC carrier swap has.

METHOD
    Homologs are paired by effect NAME (`prog<NN>_<name>' <-> `eff<NN>_<name>', plus
    rock_rotary <-> rotary_speaker), the kernel/epilogue/struct images excluded.  Each pair is
    aligned with difflib.SequenceMatcher over whole 36-bit words (autojunk off).  A bit-11 word is
      IDENTICAL   inside an `equal' block (the other product has the same word at the aligned slot)
      SWAPPED     inside a non-equal block whose other side holds the same lo12 on a different
                  carrier (hi12 / class4 / addr8 differ)
      DROPPED     the other product's WHOLE image carries no word with that lo12
      DISPLACED   the other image carries the lo12, but not in the aligned block
    For every DROPPED word the length of the identical run that follows it in the alignment is
    printed: a drop followed by a long identical run is a clean insertion, not a rewrite.
    Rule 9: images are de-duplicated before anything is counted (class_twins.images()).

    The CONTROL, printed first: the same classification for every DECODED non-bit-11 word whose
    form (hi12, class4, lo12) occurs once per image -- so a DROPPED rate for 8BC can be read
    against the rate at which an ordinary once-per-image word is dropped.

USAGE
    python3 dsp/tools/bit11_xprod.py            # the bit-11 census + the control
    python3 dsp/tools/bit11_xprod.py --dram     # also the DRAM-escape lo12 migration census
    python3 dsp/tools/bit11_xprod.py --list     # every bit-11 occurrence with its fate

MEASURED 2026-11-02 (lane open6/kn5000-d, sub-lane dsp): see analysis/bit11-xprod-2026-11-02.md.
"""
import collections
import difflib
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import dsp_disasm as D                                                    # noqa: E402
import class_twins as CT                                                  # noqa: E402

ALIAS = {"rock_rotary": "rotary_speaker"}
KN_LOAD, WSA_LOAD = 84, 110          # I-RAM load address of every bit-11-bearing body


def name_of(img):
    return re.sub(r"^(prog|eff)\d+_", "", img)


def fmt(w):
    return "%03X.%X.%02X.%03X%s" % (D.hi12(w), D.class4(w), D.addr8(w), D.lo12(w),
                                   "" if D.decoded(w) else "*")


def is_alt(w):
    return (not D.c_format(w)) and bool(w & 0x800)


def pairs():
    """[(name, kn_words, wsa_words)] -- de-duplicated, homologs by name."""
    seen, kn, wsa = set(), {}, {}
    for label, img, _sl, ws in CT.images():
        k = (label, tuple(ws))
        if k in seen:
            continue
        seen.add(k)
        if img.startswith(("kernel", "epilogue", "struct", "index")):
            continue
        (kn if label == "KN" else wsa)[name_of(img)] = ws
    out = []
    for n in sorted(kn):
        m = ALIAS.get(n, n)
        if m in wsa:
            out.append((n, kn[n], wsa[m]))
    return out


def fates(a, b, select):
    """Yield (side, index, word, fate, detail) for every selected word of a (side 0) and b (1)."""
    sm = difflib.SequenceMatcher(None, a, b, autojunk=False)
    ops = sm.get_opcodes()
    for side, (mine, other) in enumerate(((a, b), (b, a))):
        for oi, (op, i1, i2, j1, j2) in enumerate(ops):
            lo, hi = (i1, i2) if side == 0 else (j1, j2)
            olo, ohi = (j1, j2) if side == 0 else (i1, i2)
            for i in range(lo, hi):
                w = mine[i]
                if not select(w):
                    continue
                if op == "equal":
                    yield side, i, w, "IDENTICAL", ""
                    continue
                same = [x for x in other[olo:ohi] if D.lo12(x) == D.lo12(w) and select(x)]
                if same:
                    yield side, i, w, "SWAPPED", "other: " + " ".join(fmt(x) for x in same)
                elif not any(D.lo12(x) == D.lo12(w) and select(x) for x in other):
                    nxt = ops[oi + 1] if oi + 1 < len(ops) else None
                    run = (nxt[2] - nxt[1]) if nxt and nxt[0] == "equal" else 0
                    yield side, i, w, "DROPPED", "identical run after: %d words" % run
                else:
                    yield side, i, w, "DISPLACED", ""


def census(P, select, label):
    tally = collections.Counter()
    rows = []
    for n, a, b in P:
        for side, i, w, fate, det in fates(a, b, select):
            tally[(D.lo12(w), fate)] += 1
            rows.append((n, ("KN", "WSA")[side], i, w, fate, det))
    return tally, rows


def main():
    P = pairs()
    print("=" * 96)
    print("  bit11_xprod -- the bit-11 words across the KN5000 / SX-WSA1R homolog pairs")
    print("=" * 96)
    print("\n  %d homolog pairs aligned (by effect name, rule 9 de-duplicated)\n" % len(P))

    # --- the CONTROL: decoded, non-bit-11 forms that occur exactly once in their image ---------
    def once_decoded(ws):
        c = collections.Counter((D.hi12(w), D.class4(w), D.lo12(w)) for w in ws)
        return {w for w in ws if D.decoded(w) and not is_alt(w)
                and c[(D.hi12(w), D.class4(w), D.lo12(w))] == 1}
    ctl = collections.Counter()
    for n, a, b in P:
        sa, sb = once_decoded(a), once_decoded(b)
        for side, i, w, fate, _d in fates(a, b, lambda w, s=sa | sb: w in s):
            ctl[fate] += 1
    tot = sum(ctl.values())
    print("  CONTROL -- decoded, non-bit-11 words whose form is once-per-image (n = %d):" % tot)
    for f in ("IDENTICAL", "SWAPPED", "DISPLACED", "DROPPED"):
        print("     %-10s %5d   %5.1f %%" % (f, ctl[f], 100.0 * ctl[f] / tot if tot else 0))

    tally, rows = census(P, is_alt, "bit-11")
    los = sorted({lo for lo, _f in tally})
    print("\n  THE BIT-11 WORDS (lo12 bit 11 set, C-format excluded), by lo12 and fate:\n")
    print("     lo12   IDENTICAL  SWAPPED  DISPLACED  DROPPED")
    for lo in los:
        print("     %03X    %9d  %7d  %9d  %7d" % (lo, tally[(lo, "IDENTICAL")], tally[(lo, "SWAPPED")],
                                                 tally[(lo, "DISPLACED")], tally[(lo, "DROPPED")]))

    print("\n  8BC -- position of every occurrence (pooled, de-duplicated, all images):")
    pos = collections.Counter()
    seen = set()
    for label, img, _sl, ws in CT.images():
        k = (label, tuple(ws))
        if k in seen:
            continue
        seen.add(k)
        for i, w in enumerate(ws):
            if is_alt(w) and D.lo12(w) == 0x8BC:
                pos[(label, i)] += 1
    for (label, i), n in sorted(pos.items()):
        print("     %-3s w%-3d  x%d" % (label, i, n))

    print("\n  the DROPPED and SWAPPED bit-11 words:")
    for n, side, i, w, fate, det in rows:
        if fate in ("DROPPED", "SWAPPED"):
            print("     %-18s %-3s w%-3d %-15s %-9s %s" % (n, side, i, fmt(w), fate, det))

    # --- THE RELOCATION TEST, applied to the alternate encoding ---------------------------------
    #  Every KN5000 bit-11 image loads at I-RAM 84 and every SX-WSA1R one at 110 (the .dsm headers;
    #  `wsa1/dsp/README.md').  A field that is an ABSOLUTE I-RAM address must shift by
    #  (110 + j) - (84 + i) between aligned copies; one that is BODY-RELATIVE by j - i.  A field that
    #  is data shifts by neither.  Only IDENTICAL alignments are scored (both copies byte-equal), so
    #  the question is: were they byte-equal although the word itself had moved?
    print("\n  THE RELOCATION TEST on the bit-11 words (IDENTICAL alignments only):")
    print("     KN bodies load at I-RAM %d, SX-WSA1R bodies at %d" % (KN_LOAD, WSA_LOAD))
    rel = collections.defaultdict(lambda: [0, 0, 0])
    for n, a, b in P:
        sm = difflib.SequenceMatcher(None, a, b, autojunk=False)
        for blk in sm.get_matching_blocks():
            for t in range(blk.size):
                i, j = blk.a + t, blk.b + t
                w = a[i]
                if not is_alt(w):
                    continue
                r = rel[D.lo12(w)]
                r[0] += 1
                r[1] += (WSA_LOAD + j) != (KN_LOAD + i)
                r[2] += j != i
    print("     lo12   aligned-identical   moved in I-RAM   moved within the body")
    for lo in sorted(rel):
        r = rel[lo]
        print("     %03X    %17d   %14d   %21d" % (lo, r[0], r[1], r[2]))
    print("     -> a word byte-identical in both copies although it MOVED cannot hold an address of")
    print("        the kind that moved with it.")

    if "--list" in sys.argv:
        print("\n  every bit-11 occurrence:")
        for n, side, i, w, fate, det in rows:
            print("     %-18s %-3s w%-3d %-15s %-9s %s" % (n, side, i, fmt(w), fate, det))

    if "--dram" in sys.argv:
        print("\n" + "=" * 96)
        print("  --dram: the lo12 of the delay-DRAM escape words, across the same pairs")
        print("=" * 96)
        dram = lambda w: D.is_dram(w) and not is_alt(w)          # noqa: E731
        moved = collections.Counter()
        for n, a, b in P:
            sm = difflib.SequenceMatcher(None, a, b, autojunk=False)
            for op, i1, i2, j1, j2 in sm.get_opcodes():
                if op != "replace":
                    continue
                A, B = a[i1:i2], b[j1:j2]
                for X, Y, sx in ((A, B, "KN"), (B, A, "WSA")):
                    for x in X:
                        if not dram(x):
                            continue
                        # the same DRAM carrier (hi12, class4, addr8) on the other side, other lo12
                        for y in Y:
                            if dram(y) and (D.hi12(y), D.class4(y), D.addr8(y)) == \
                               (D.hi12(x), D.class4(x), D.addr8(x)) and D.lo12(y) != D.lo12(x):
                                # does x's lo12 ride on an adjacent NON-DRAM word on y's side?
                                k = Y.index(y)
                                nb = [z for z in Y[max(0, k - 2):k + 3]
                                      if not D.is_dram(z) and D.lo12(z) == D.lo12(x)]
                                key = ("%03X" % D.lo12(x), "%03X" % D.lo12(y), bool(nb))
                                moved[key] += 1
                                if len(A) <= 6 and len(B) <= 6:
                                        print("     %-18s %-3s %-15s <-> %-15s  lo12 %03X on a neighbour: %s"
                                          % (n, sx, fmt(x), fmt(y), D.lo12(x),
                                             " ".join(fmt(z) for z in nb) or "no"))
        print("\n     (only replace blocks of <= 6 words a side are listed; the tally counts all)")
        print("     (lo12 here, lo12 there, migrated to a neighbour) -> count")
        for k, v in sorted(moved.items()):
            print("       %s  %d" % (k, v))
    return 0


if __name__ == "__main__":
    sys.exit(main())
