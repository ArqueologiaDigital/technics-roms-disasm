#!/usr/bin/env python3
"""label_cross_image_targets.py -- give the prom_b addresses prom_a still spells as numbers a label.

QUESTION IT ANSWERS / JOB IT DOES
  notes/proma-2026-09-25/symbolize_prom_a_addresses.py respells a prom_a operand that names a prom_b
  address only when prom_b already has a LABEL there.  On 2026-10-24 it left 293 operands over 175
  prom_b addresses numeric for want of one ("no_label_ld_b 134, lda_b 81, long_b 66, add_b 12").
  Most are pointers INTO prom_b's display lists: `ld XIY,0x00f0d6af` / `ld XIX,0x00f0d77f` handed to
  the display-list interpreter as a [start, end) pair, or one record handed to an interpreter-B
  handler.  This tool places a label at such an address -- and ONLY on evidence -- so that the
  symboliser can then write the name:

  1. TEXT.  When the address is the first byte of a display-list RECORD (a `.byte op, len ; op ..`
     line) and the records from there to the next label or section rule carry `.ascii` text, the
     label is DL_<CamelCase of that text>, by exactly the rule notes/gen_prom_b_f067a6_module.py
     --dl-names named prom_b's other lists with (accumulate CamelCase of the literals until 24
     characters, cut at 40): the name says what the interpreter DRAWS from there, nothing more.  A
     name another label already has, in either image, is not used.
  2. BY HAND, in NAMED below: addresses whose meaning is established by the code that reads them,
     each with the evidence written beside it and copied into the header it gets.
  Anything else is left numeric and listed: no evidence, no label.  So is an address that only an
  older build's or dead copy of a table points at (*Stale*, OldCopy_*, *DeadCopy*, OldBuild_*).

  The label goes on its own line directly above the record, under a header giving the evidence and
  the prom_a routines that reference it (with the operand kind: ld, lda, long, add), in the module
  file that holds the record (asm_source.write_own_lines).
  A label emits no bytes; `make gate-wsa1` still checks that nothing moved.

RUN (inside wsa1/; it runs `make all` first, because the label set it checks names against
     comes from the linked ELFs)
    python3 scripts/tools/label_cross_image_targets.py            # what it would label, and why
    python3 scripts/tools/label_cross_image_targets.py --apply
    python3 ../notes/proma-2026-09-25/symbolize_prom_a_addresses.py --apply   # respell the operands
    make gate-wsa1
"""
import collections
import importlib.util
import os
import re
import sys

WSA1 = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REPO = os.path.dirname(WSA1)
sys.path.insert(0, os.path.join(WSA1, "notes"))
sys.path.insert(0, os.path.join(REPO, "notes", "proma-2026-09-25"))
import asm_source                                   # noqa: E402
import symbolize_prom_a_addresses as SA            # noqa: E402  (its operand FORMS and ELF reader)

_spec = importlib.util.spec_from_file_location("split", os.path.join(WSA1, "scripts", "tools",
                                                                     "split_cpu1_images.py"))
SPLIT = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(SPLIT)

SLUG_MIN, SLUG_MAX = 24, 40          # notes/gen_prom_b_f067a6_module.py's --dl-names rule
RECORD = re.compile(r'^\s*\.byte\s+0x[0-9A-Fa-f]{2}\s*,\s*0x[0-9A-Fa-f]{2}\s*;[^;]*\bop\s+[0-9A-Fa-f]{2}\b')
ASCII = re.compile(r'\.ascii\s+"([^"]*)"')
LABEL = re.compile(r'^([A-Za-z_.$][\w.$@]*):')

# address -> (name, [evidence lines]).  Each is read off the code named in its evidence.
NAMED = {
    0xF0D77F: ("DL_SysexBulkDump_SequencerRow", [
        "The SYSEX BULK DUMP menu's last row: the records from here to DL_Sending draw \" SEQUENCER\"",
        "(LCD 0x1E7B) and its row rectangle.  prom_a Paint_SysexBulkDump runs the menu list from",
        "DL_SysexBulkDumpMidiTotalKeyboard and ends it at DL_Sending, or HERE when (Variant_Flag) == 2",
        "(`cp (0xC4),0x02 / jr nz` at 0xF99A32), so model variant 2 shows no SEQUENCER row."]),
    0xF0D9A4: ("DLB_SysexBulkDump_FillSelectedRow", [
        "One interpreter-B record, op 03: entry [(0x2720), UI_ScreenItem] of the five 8-byte rectangles",
        "that follow it (0xF0D9AF), passed to SWI7 service 0x05 (fill a rectangle) -- DLB_Handler_Array8",
        "reads the index field at +2, the service at +6 (0x05) and the array pointer at +7.  prom_a",
        "Paint_SysexBulkDump runs it through T_DLB_Handler_Array8, and LcdKeyRow1_SysexBulkDump runs it",
        "after storing the new row in (0x2720).  The five rectangles are the menu's five rows."]),
    0xF0D9D7: ("DLB_SysexBulkDump_EraseSelectedRow", [
        "The twin of DLB_SysexBulkDump_FillSelectedRow: the same index field (0x2720) and the same",
        "rectangle array 0xF0D9AF, with SWI7 service 0x1B (erase) at +6.  LcdKeyRow1_SysexBulkDump runs",
        "it BEFORE it stores the new row, so it clears the old row's rectangle."]),
    0xF0DB2C: ("PTR_F0DB18_ButtonStarts", [
        "Entries [5..9] of PTR_F0DB18, one per language (English, German, French, Spanish, Italian),",
        "indexed by (0x7FC1) x 4.  prom_a Paint_GeneralMidiMode reads them as the END of the dialog box",
        "list it runs from PTR_F0DB18[language] -- each is where that language's button list starts."]),
    0xF0DB40: ("PTR_F0DB18_ButtonStarts2", [
        "Entries [10..14] of PTR_F0DB18: the same five button-list starts again.  prom_a",
        "Paint_GeneralMidiMode reads them as the START of the interpreter-B run (T_DisplayListB_Run)."]),
    0xF0DB54: ("PTR_F0DB18_TextStarts", [
        "Entries [15..19] of PTR_F0DB18: the five message-text starts, read by prom_a",
        "Paint_GeneralMidiMode as the END of that interpreter-B run."]),
}


def camel(s):
    return "".join(w[0].upper() + w[1:].lower() for w in re.split(r"[^A-Za-z0-9]+", s) if w)


def targets():
    """{prom_b address: [(prom_a routine, operand kind, line text)]} -- numeric, unlabelled."""
    lines, _origin = asm_source.own_lines(WSA1, "prom_a/wsa1_prom_a.s")
    b_lab, _ = SA.elf_labels(os.path.join(WSA1, "rebuilt_ROMs", "wsa1_prom_b.llvm.elf"))
    blk = SA.block_of(lines)
    out = collections.defaultdict(list)
    routine = None
    for li, t in enumerate(lines):
        m = LABEL.match(t)
        if m and not m.group(1).startswith(".") and not SA.STRUCT.search(m.group(1)):
            routine = m.group(1)
        if blk and blk[0] <= li <= blk[1]:
            continue
        lead, code, tail = SA.split_code(t)
        if not code:
            continue
        for kind, rx in SA.FORMS:
            m2 = rx.match(code)
            if m2:
                v = int(m2.group("num"), 0)
                if 0xF00000 <= v < 0xF80000 and not b_lab.get(v):
                    out[v].append((routine, kind, code.strip()))
                break
    return out


def taken_names():
    names = set()
    for img in ("prom_a", "prom_b"):
        _lab, n = SA.elf_labels(os.path.join(WSA1, "rebuilt_ROMs", "wsa1_%s.llvm.elf" % img))
        names |= n
    return names


def plan():
    tg = targets()
    lines, origin = asm_source.own_lines(WSA1, "prom_b/wsa1_prom_b.s")
    addr = SPLIT.line_addresses("prom_b", lines)
    at = {}
    for i, a in sorted(addr.items()):
        at.setdefault(a, i)                     # the FIRST statement line at that address
    taken = taken_names()
    props, left = {}, []
    for v in sorted(tg):
        # ⚠ a pointer held only by an OLDER BUILD's or dead copy of a table (labels named
        #   *Stale*, OldCopy_*, *DeadCopy*, OldBuild_*) says where THAT build's object was; a label
        #   here would assert a relationship nobody has shown (census.py's STALE rule)
        if all(re.search(r'Stale|OldCopy|DeadCopy|OldBuild', r or "") for r, _k, _c in tg[v]):
            left.append((v, "referenced only from a stale or dead copy (%s)" % tg[v][0][0]))
            continue
        li = at.get(v)
        if li is None or addr[li] != v:
            left.append((v, "no statement starts there (inside a line)"))
            continue
        if v in NAMED:
            name, ev = NAMED[v]
            props[v] = (li, name, ev)
            continue
        if not RECORD.match(lines[li]):
            left.append((v, "not a display-list record line: %s" % lines[li].strip()[:50]))
            continue
        lit = []
        for j in range(li, len(lines)):
            if j > li and (LABEL.match(lines[j]) or lines[j].startswith("; ---") or lines[j].startswith("; ===")):
                break
            lit += [x.strip() for x in ASCII.findall(lines[j]) if re.search(r"[A-Za-z]{2}", x)]
        if not lit:
            left.append((v, "no text record before the next label"))
            continue
        s = ""
        for x in lit:
            s += camel(x)
            if len(s) >= SLUG_MIN:
                break
        name = "DL_" + s[:SLUG_MAX]
        ev = ["Display-list records that prom_a names by number; from this record to the next label",
              "their own text records read: %s." % "; ".join('"%s"' % x for x in lit[:6])
              + (" +%d more" % (len(lit) - 6) if len(lit) > 6 else ""),
              "The name is CamelCase of that text (notes/gen_prom_b_f067a6_module.py --dl-names's rule)",
              "and says what the interpreter draws from here, nothing more."]
        props[v] = (li, name, ev)
    # a name proposed twice, or already defined anywhere, is dropped: an address stays a number
    count = collections.Counter(n for _li, n, _e in props.values())
    for v in list(props):
        li, n, ev = props[v]
        if count[n] > 1 or n in taken:
            left.append((v, "name %s is %s" % (n, "proposed twice" if count[n] > 1 else "already defined")))
            del props[v]
    return tg, lines, origin, props, left


def wrap(prefix, text, width=96):
    out, cur = [], prefix
    for w in text.split():
        if len(cur) + len(w) + 1 > width and cur.strip(";").strip():
            out.append(cur.rstrip())
            cur = ";   "
        cur += w + " "
    out.append(cur.rstrip())
    return out


def main():
    apply = "--apply" in sys.argv
    import subprocess
    subprocess.run(["make", "-C", WSA1, "all"], check=True, capture_output=True)   # the ELFs must be current
    tg, lines, origin, props, left = plan()
    ins = {}
    for v, (li, name, ev) in sorted(props.items()):
        kinds = collections.defaultdict(set)
        for r, k, _c in tg[v]:
            kinds[r or "?"].add(k)
        refs = sorted("%s (%s)" % (r, "/".join(sorted(ks))) for r, ks in kinds.items())
        hdr = ["; " + e for e in ev]
        hdr += wrap("; Referenced by prom_a: ", "; ".join(refs[:6]) + (" +%d more" % (len(refs) - 6)
                                                                        if len(refs) > 6 else "") + ".")
        hdr += ["; (Labelled by wsa1/scripts/tools/label_cross_image_targets.py so the prom_a operands",
                ";  can be written symbolically.)", "%s:" % name]
        ins[li] = hdr
        print("LABEL  0x%06X  %-44s %d prom_a operand(s)" % (v, name, len(tg[v])))
    for v, why in left:
        print("left   0x%06X  %s" % (v, why))
    print("%d label(s) %s, %d address(es) left numeric" % (len(props), "placed" if apply else "proposed", len(left)))
    if apply and ins:
        written = asm_source.write_own_lines(WSA1, origin, inserts=ins)
        print("wrote", ", ".join(written))


if __name__ == "__main__":
    main()
