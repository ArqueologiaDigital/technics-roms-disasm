#!/usr/bin/env python3
r"""naka_frame_c_by_asm_slices.py -- give the NAKA C blobs' anonymous field_XXXX words the boundaries and names
of the documented assembler slices that already cut the same bytes.

QUESTION ANSWERED
-----------------
"Which field_XXXX members of a NAKA C blob are parts of an object the assembler already names and explains?"
Each blob <tree>/maincpu/ui_widgets/<blob>.c compiles to includes/generated/<blob>.bin, which the .s files take
in labelled slices (`Label: .incbin "includes/generated/<blob>.bin", off, len`).  Many slices carry a header
comment that cites their reader (`; PanelButton_SoundGroupCodes_RightSeg1: Sound-group map of right-panel
segment 1 ... Basis: readers + bytes`), while the C still cuts the same bytes as `uint16_t field_3570` words
that straddle the objects (scripts/analysis/naka_gui_census.py counts them as field_XX).

For every field_XXXX member this takes the slices it overlaps and grows the region until slices and members
end together.  It retypes the region as one member per slice, named after the slice label (`uint8_t
<Label>[len]`; `uint16_t <Label>[len / 2]` when the header says u16 / 16-bit; one scalar for a 1-byte
slice, or for a 2- / 4-byte one whose description starts "Number" / "Count" / "Size" / "Length"; a string
literal for printable text + NUL, ALIGNED_STRING when a 0xFF pad follows), with the header's description (up to its
"Basis:") as its comment, when
  * the slices tile the region with no gap,
  * every slice has a header comment (the documented evidence; an undocumented slice such as
    FileIO_BytecodeData_Data_12 is left alone),
  * no slice header says the slice holds pointers, and no member in it has a symbolic initializer.
The values are the bytes the tree's current C compiles to (naka_gui_symbolize.compile_c, before any
C-divergence patch), and --apply refuses a file whose compiled bytes change.

RUN (repository root, built tree)
    python3 scripts/converters/naka_frame_c_by_asm_slices.py --tree v10 [--apply] [blob ...]
"""
import argparse
import glob
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import nakarest_c_model as M          # noqa: E402
import naka_gui_symbolize as S        # noqa: E402

FIELD = re.compile(r'^field_[0-9a-fA-F]+$')


def read(p):
    return open(p, 'rb').read().decode('latin-1')


def slices(tree, blob):
    """off -> (label, len, header lines, file) of every labelled slice of blob in the tree's .s files."""
    out = {}
    pat = re.compile(r'^([A-Za-z_]\w*):\s*\.incbin\s+"includes/generated/%s\.bin",\s*(0x[0-9A-Fa-f]+|\d+),\s*'
                     r'(0x[0-9A-Fa-f]+|\d+)' % re.escape(blob))
    for p in glob.glob(os.path.join(ROOT, tree, 'maincpu', '**', '*.s'), recursive=True):
        L = read(p).split('\n')
        for i, l in enumerate(L):
            m = pat.match(l)
            if not m:
                continue
            j = i
            while j > 0 and L[j - 1].startswith(';') and not L[j - 1].startswith('; [nakarest]'):
                j -= 1
            hdr = [x[1:].strip() for x in L[j:i]]
            out[int(m.group(2), 0)] = (m.group(1), int(m.group(3), 0), hdr, os.path.relpath(p, ROOT))
    return out


def plan(cb, sl):
    """[(start, end, [slice offsets])] regions to retype, and {reason: count} for the field_XX left."""
    offs = sorted(sl)
    regions, why, done = [], {}, set()
    for mb in cb.members:
        if not FIELD.match(mb.name) or mb.offset in done:
            continue
        a, b = mb.offset, mb.offset + mb.size
        while True:
            ss = [o for o in offs if o < b and o + sl[o][1] > a]
            if not ss:
                break
            na, nb = min([a] + ss), max([b] + [o + sl[o][1] for o in ss])
            ms = [m for m in cb.members if m.offset < nb and m.offset + m.size > na]
            na, nb = min([na] + [m.offset for m in ms]), max([nb] + [m.offset + m.size for m in ms])
            if (na, nb) == (a, b):
                break
            a, b = na, nb
        ss = [o for o in offs if o < b and o + sl[o][1] > a]
        k = 'no slice'
        if ss:
            k = None
            at = a
            for o in ss:
                if o != at:
                    k = 'slices leave a gap'
                    break
                at = o + sl[o][1]
            if k is None and at != b:
                k = 'slices leave a gap'
            if k is None and any(not sl[o][2] for o in ss):
                k = 'a slice has no header'
            if k is None and any(re.search(r'pointer|\bu32\b|32-bit', ' '.join(sl[o][2]), re.I) for o in ss):
                k = 'a slice holds pointers'
            if k is None:
                ms = [m for m in cb.members if a <= m.offset < b]
                if any(M.SYMBOLIC_RE.search(cb.entries[cb.by_name[m.name]].expr) for m in ms):
                    k = 'a symbolic initializer'
        ms = [m for m in cb.members if a <= m.offset < b and FIELD.match(m.name)]
        for m in ms:
            done.add(m.offset)
        if k:
            why[k] = why.get(k, 0) + len(ms)
        else:
            regions.append((a, b, ss))
    return regions, why


def first_sentence(hdr, label):
    t = ' '.join(hdr)
    t = re.sub(r'^%s\s*(--|:)\s*' % re.escape(label), '', t)
    s = re.split(r'\s*\bBasis:', t, maxsplit=1)[0].strip()      # the description, without its evidence line
    return s.replace('*/', '* /')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', default='v10')
    ap.add_argument('--apply', action='store_true')
    ap.add_argument('blobs', nargs='*')
    a = ap.parse_args()
    files = sorted(glob.glob(os.path.join(ROOT, a.tree, 'maincpu', 'ui_widgets', 'naka_*.c')))
    for h in ('naka_types.h', 'naka_classes.h'):       # the record and class typedefs the C files use
        hp = os.path.join(ROOT, a.tree, 'maincpu', 'ui_widgets', h)
        if os.path.exists(hp):
            M.register_local_types(read(hp))
    total, left = 0, {}
    for c in files:
        blob = os.path.basename(c)[:-2]
        if a.blobs and blob not in a.blobs:
            continue
        try:
            cb = M.CBlob(c)
        except (KeyError, SystemExit) as e:
            print('%-32s not read by nakarest_c_model (%s); skipped' % (os.path.basename(c), e))
            continue
        if not any(FIELD.match(m.name) for m in cb.members):
            continue
        sl = slices(a.tree, blob)
        regions, why = plan(cb, sl)
        for k, v in why.items():
            left[k] = left.get(k, 0) + v
        if not regions:
            continue
        b, ld = S.bin_rule(a.tree, c)
        old_text = read(c)
        old = S.compile_c(c, ld, old_text)
        n = 0
        for start, end, ss in sorted(regions, reverse=True):
            new = []
            for o in ss:
                lab, ln, hdr, sfile = sl[o]
                data = old[o:o + ln]
                pre = ['    /* %s: %s (%s) */' % (lab, first_sentence(hdr, lab), sfile)]
                desc = first_sentence(hdr, lab)
                txt = re.fullmatch(rb'([\x20-\x7e]+)\x00(\xff?)', data)
                if txt and txt.group(2):
                    # text with the 0xFF that aligns its end (naka_types.h ALIGNED_STRING)
                    new.append(M.NewMember('char', lab, '[%d]' % ln, ln,
                                           'ALIGNED_STRING(%s)' % M.c_string(txt.group(1)), pre))
                elif txt:
                    new.append(M.string_member(lab, data, pre))
                elif ln in (1, 2, 4) and (ln == 1 or re.match(r'(the )?(number|count|size|length)\b', desc, re.I)):
                    # one value: a byte, or a count the header names as such (SingleLoadSrc_PanelMemEntryCount)
                    new.append(M.NewMember({1: 'uint8_t', 2: 'uint16_t', 4: 'uint32_t'}[ln], lab, '', ln,
                                           '%d' % int.from_bytes(data, 'little'), pre))
                elif re.search(r'\bu16\b|16-bit', ' '.join(hdr), re.I) and ln % 2 == 0:
                    vals = [int.from_bytes(data[i:i + 2], 'little') for i in range(0, ln, 2)]
                    body = ['        ' + ', '.join('0x%04X' % v for v in vals[i:i + 8]) + ','
                            for i in range(0, len(vals), 8)]
                    new.append(M.NewMember('uint16_t', lab, '[%d]' % (ln // 2), ln,
                                           '{\n' + '\n'.join(body) + '\n    }', pre))
                else:
                    new.append(M.bytes_member(lab, data, pre))
            n += len([m for m in cb.members if start <= m.offset < end and FIELD.match(m.name)])
            cb.retype(start, end, new, old)
        text = cb.render()
        got = S.compile_c(c, ld, text)
        same = got == old
        print('%-32s %d field_XX in %d regions -> %s' % (os.path.basename(c), n, len(regions),
                                                          'IDENTICAL' if same else 'DIFFERS'))
        if not same:
            continue
        total += n
        if a.apply:
            open(c, 'wb').write(text.encode('latin-1'))
    print('%s: %d field_XX members retyped by documented slices; left: %s' % (a.tree, total, left))


if __name__ == '__main__':
    main()
