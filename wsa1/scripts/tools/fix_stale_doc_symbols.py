#!/usr/bin/env python3
"""fix_stale_doc_symbols.py -- respell the stale label names that doc_symbol_check.py finds in WSA1 notes.

QUESTION IT ANSWERS
  scripts/analysis/doc_symbol_check.py lists every `backticked` name in a note that no linked WSA1
  image defines.  Many of those are labels that were RENAMED after the note was written
  (`sub_FA826C` is now `Voice_StageRegs_0040_B`).  This tool answers "what is each such name called
  now, and on what evidence?", and with --apply writes the current name into the note.

EVIDENCE, in the order it is used -- a name is changed only when one of these holds
  1. RENAME HISTORY.  `git log -p -U0` over the WSA1 sources (prom_a..d, kernel, dsp, maincpu) is
     read once; a hunk that removes N label definitions and adds N is a rename hunk, and its i-th
     removed label became its i-th added label.  The chain is followed (old -> mid -> new) until it
     reaches a name the current ELFs define; when one name was renamed differently at different
     times, the LATEST rename is followed.  The chain's commits are printed with --why.
     The pairing is by position only, so for an address-derived old name (`..._XXXXXX`) the chain
     is accepted only when its final name sits AT that address in an image that defined the old
     name: a span split into several labels pairs the old name with whichever new label has the
     same index (`PtrTables_F95C95` -> a label 0x100 bytes on).  SUFFIX_IS_NOT_OWN_ADDRESS lists
     the hand-checked names whose suffix is some other object's address.
  2. SAME ADDRESS, SAME IMAGE.  For an address-derived name (`sub_FA9F19`, `T_F42E0C`, `Data_F28522`,
     `Table_FDFF96`, ... -- any name ending in _<6 hex digits>), when history (1) has no chain: the
     image(s) that ever DEFINED that name are taken from the same git log (prom_a and prom_c share
     0xF80000-0xFFFFFF, so the address alone does not say which); if exactly one such image's current
     ELF has a label AT that address, its best label is used (descriptive beats structural
     `_Skip/_Loop/...`, which beats another address-derived name; an address-derived best label is
     not an improvement and is skipped).

WHAT IS NEVER CHANGED
  * a line that already holds the new name ("Stage_B calls `Dev104_LoadStageBImage` (was
    `sub_FC571A`)");
  * the old-name column of a rename-mapping table -- a table whose header names a now/new/current
    column; its first column (and any column headed here/old/was/before) records what the name
    used to be, on purpose;
  * an old name written as history: preceded by `was`, `formerly`, `renamed from`, `old`, `then`,
    `previously`, or inside a `refused to name ...` clause, or followed by `->` / `→` / `became` / `is now` / `(now` / `now `...`` (on the
    same line, or the next one when the name ends a line);
  * anything inside a ``` fenced block (recorded tool output must stay what the tool printed);
  * a name that is not a candidate of doc_symbol_check.py (it already resolves, or does not look
    like a symbol).
  The tool never invents a name: no evidence, no change.
  A Markdown table with a changed row is re-padded whole (space-padded, aligned columns).  Cells are
  split on '|' outside `code spans` and not escaped as '\\|'; a table whose rows do not all have
  the separator's column count, or that would not read back as the same cells, is left as it is
  (reported on stderr).  `--selftest` checks the reader and the re-padder.

RUN (inside wsa1/, after `make all` so the ELFs are current)
    python3 scripts/tools/fix_stale_doc_symbols.py                 # dry run over every tracked note
    python3 scripts/tools/fix_stale_doc_symbols.py --why notes/FINDINGS-prom_c-dev10c-producers.md
    python3 scripts/tools/fix_stale_doc_symbols.py --apply
    python3 scripts/tools/fix_stale_doc_symbols.py --audit 764bd7124~1   # tables kept, addresses agree
    python3 scripts/analysis/doc_symbol_check.py $(git ls-files '*.md')   # the count it moves
The rename history is cached under $TMPDIR keyed by HEAD, so a second run takes seconds.
"""
import argparse
import collections
import json
import os
import re
import subprocess
import sys
import unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "scripts", "analysis"))
import doc_symbol_check as dsc   # noqa: E402  (same candidate rule, same ELFs)

NM = dsc.NM
SRC_DIRS = ["prom_a", "prom_b", "prom_c", "prom_d", "kernel", "dsp", "maincpu"]
LAB = re.compile(r'^([-+])([A-Za-z_.$][A-Za-z0-9_.$]*):')
ADDR_NAME = re.compile(r'_([0-9A-Fa-f]{6})$')
STRUCT = re.compile(r'_(Skip|Join|Loop|Sub|Return|Epilogue|Entry|Helper|Done|Ret)\d*$|__')
HISTORY_WORDS = re.compile(r'(\bwas|\bformerly|\brenamed from|\bold|\bthen|\bpreviously|\bto name|\bnamed|\bnaming)\s*[:(]?\s*$', re.I)
# A list of names quoted from an older round's refusal ("Round 7 refused to name `sub_FF4ACB` and
# `sub_FF4D5D`") records what they were called then: every name in that clause is history.
HISTORY_CLAUSE = re.compile(r'\brefused to name\b[^.:]*$', re.I)
IMAGE_OF_DIR = {"prom_a": "a", "prom_b": "b", "prom_c": "c", "prom_d": "d"}


def git(*args):
    return subprocess.run(["git", "-C", ROOT] + list(args), check=True, capture_output=True,
                          text=True).stdout


def history():
    """(renames: old -> [(date, new, commit)], defined_in: name -> {image letters})."""
    head = git("rev-parse", "HEAD").strip()
    scratch = os.environ.get("TMPDIR") or os.path.expanduser("~/compartilhado/tmp")
    cache = os.path.join(scratch, "wsa1-label-history-%s.json" % head[:12])
    if os.path.exists(cache):
        d = json.load(open(cache))
        return d["renames"], {k: set(v) for k, v in d["defined_in"].items()}
    prefix = git("rev-parse", "--show-prefix").strip()
    p = subprocess.Popen(["git", "-C", ROOT, "log", "-p", "-U0", "--no-renames", "--format=@@@COMMIT %H %ad",
                          "--date=short", "--"] + [":(top)" + prefix + d for d in SRC_DIRS],
                         stdout=subprocess.PIPE)
    renames = collections.defaultdict(list)
    defined_in = collections.defaultdict(set)
    commit = date = img = None
    cur = []

    def flush():
        rem = [n for s, n in cur if s == "-"]
        add = [n for s, n in cur if s == "+"]
        if rem and len(rem) == len(add):
            for o, n in zip(rem, add):
                if o != n:
                    renames[o].append((date, n, commit))

    for raw in p.stdout:
        ln = raw.decode("utf-8", "replace").rstrip("\n")
        if ln.startswith("@@@COMMIT"):
            flush()
            cur = []
            _, commit, date = ln.split()
        elif ln.startswith("+++ ") or ln.startswith("--- "):
            flush()
            cur = []
            path = ln[4:]
            if path != "/dev/null":
                parts = path.split("/")
                img = next((IMAGE_OF_DIR[x] for x in parts if x in IMAGE_OF_DIR), None)
        elif ln.startswith("@@ "):
            flush()
            cur = []
        else:
            m = LAB.match(ln)
            if m:
                cur.append((m.group(1), m.group(2)))
                if m.group(1) == "+" and img:
                    defined_in[m.group(2)].add(img)
    flush()
    p.wait()
    json.dump(dict(renames=renames, defined_in={k: sorted(v) for k, v in defined_in.items()}),
              open(cache, "w"))
    return renames, defined_in


def current_labels():
    """names: every defined name; at[img][addr] = [label names] for .text labels."""
    names = set()
    at = {}
    for k in "abcd":
        path = os.path.join(ROOT, "rebuilt_ROMs", "wsa1_prom_%s.llvm.elf" % k)
        if not os.path.exists(path):
            sys.exit("missing %s: run `make all` first" % path)
        at[k] = collections.defaultdict(list)
        for ln in subprocess.run([NM, "--defined-only", path], check=True, capture_output=True,
                                 text=True).stdout.splitlines():
            p = ln.split()
            if len(p) >= 3:
                names.add(p[2])
                if p[1] in "tT" and not p[2].startswith(".L"):
                    at[k][int(p[0], 16)].append(p[2])
    return names, at


# Old names whose _XXXXXX suffix is NOT the label's own address, checked by hand: the suffix names the
# dispatch table the label is an entry of (`Dispatch_FF3900` slots [11] and [12], see
# notes/FINDINGS-prom_a-ui-screen-blocks.md), so the same-address check above does not apply to them.
SUFFIX_IS_NOT_OWN_ADDRESS = {"LcdKeyRow4_FF3900", "LcdKeyRow5_FF3900"}


def rank(name):
    if ADDR_NAME.search(name):
        return 2
    if STRUCT.search(name):
        return 1
    return 0


def resolve(old, names, renames, defined_in, at):
    """-> (new, evidence) or (None, reason)."""
    cur, chain, seen = old, [], set()
    while cur not in names and cur in renames and cur not in seen:
        seen.add(cur)
        date, new, commit = sorted(renames[cur])[-1]
        chain.append("%s -> %s (%s %s)" % (cur, new, date, commit[:10]))
        cur = new
    m = ADDR_NAME.search(old)
    if cur in names and cur != old:
        # ★ AN ADDRESS-DERIVED OLD NAME IS A CLAIM ABOUT AN ADDRESS.  A rename hunk pairs removed and
        #   added labels by position only, so a span that was SPLIT into several labels (PtrTables_F95C95
        #   -> three tables, the last of them 0x100 bytes further on) pairs the old name with whichever
        #   new label happens to sit at the same index.  Accept the chain only when its final name is AT
        #   the old name's address in an image that defined the old name.
        if not m or old in SUFFIX_IS_NOT_OWN_ADDRESS:
            return cur, "history: " + "; ".join(chain)
        addr = int(m.group(1), 16)
        if any(cur in at[i].get(addr, ()) for i in defined_in.get(old, ())):
            return cur, "history (same address 0x%06X): " % addr + "; ".join(chain)
        return None, "history renames %s to %s, which is not at 0x%06X: %s" % (
            old, cur, addr, "; ".join(chain))
    if not m:
        return None, "no rename in history"
    addr = int(m.group(1), 16)
    imgs = [i for i in sorted(defined_in.get(old, ())) if at[i].get(addr)]
    if len(imgs) != 1:
        return None, "address 0x%06X: %d image(s) that defined it hold a label there now" % (addr, len(imgs))
    best = sorted(at[imgs[0]][addr], key=lambda n: (rank(n), n))[0]
    if rank(best) == 2:
        return None, "address 0x%06X in prom_%s is still only address-labelled (%s)" % (addr, imgs[0], best)
    return best, "address: %s was defined in prom_%s, whose label at 0x%06X is now %s" % (
        old, imgs[0], addr, best)


AFTER_WORDS = re.compile(r'^[\s`*]*(->|→|became\b|is now\b|was renamed\b|renamed to\b|\(now\b|now\s+`)', re.I)
OLD_COLS = {"here", "old", "was", "before", "old name", "previous", "from", "then"}
NEW_COLS = {"now", "new", "current", "new name", "current name", "renamed to", "today", "to"}


def is_history_context(line, start, end, prev_line, next_line):
    before = line[:start]
    if not before.strip():
        before = prev_line + " "
    after = line[end:]
    if not after.strip():
        after = " " + next_line
    return (bool(HISTORY_WORDS.search(before)) or bool(HISTORY_CLAUSE.search(line[:start]))
            or AFTER_WORDS.match(after) is not None)


def cell_bars(line):
    """Offsets of the '|' characters that SEPARATE cells: not an escaped '\\|', and not a '|' inside a
    `code span` (the notes write `(class << 12) \\| entry` and `7.9375 x |depth|` in cells, and a
    re-padder that split those would change the table's column count and garble the text)."""
    bars, i, n = [], 0, len(line)
    while i < n:
        ch = line[i]
        if ch == "\\":
            i += 2
            continue
        if ch == "`":
            run = len(line[i:]) - len(line[i:].lstrip("`"))
            close = line.find("`" * run, i + run)
            while close != -1 and close + run < n and line[close + run] == "`":
                close = line.find("`" * run, close + run + 1)
            if close != -1:
                i = close + run
                continue
            i += run
            continue
        if ch == "|":
            bars.append(i)
        i += 1
    return bars


def table_cells(line):
    """[(start, end, text)] of a Markdown table row's cells, or None."""
    s = line.strip()
    if not (s.startswith("|") and s.endswith("|")):
        return None
    bars = cell_bars(line)
    if len(bars) < 2 or bars[0] != line.index("|") or bars[-1] != line.rindex("|"):
        return None
    return [(a + 1, b, line[a + 1:b]) for a, b in zip(bars, bars[1:])]


def history_columns(lines, n):
    """Column indices of the table that line n (0-based) is in that hold OLD names on purpose:
    a rename-mapping table is one whose header names a NOW/NEW column; its first column, and any
    column headed here/old/was/..., is the record of what the name used to be."""
    if table_cells(lines[n]) is None:
        return set()
    h = n
    while h > 0 and table_cells(lines[h - 1]) is not None:
        h -= 1
    hdr = [c[2].strip().strip("`*").lower() for c in table_cells(lines[h])]
    if not any(c in NEW_COLS for c in hdr):
        return set()
    return {0} | {i for i, c in enumerate(hdr) if c in OLD_COLS}


def table_start(lines, n):
    """First line of the GFM table that line n is in (header + separator), or None."""
    if table_cells(lines[n]) is None:
        return None
    h = n
    while h > 0 and table_cells(lines[h - 1]) is not None:
        h -= 1
    if h + 1 >= len(lines) or not re.match(r'^\s*\|(\s*:?-+:?\s*\|)+\s*$', lines[h + 1]):
        return None
    return h


def _width(s):
    return sum(2 if unicodedata.east_asian_width(ch) in "WF" else 1 for ch in s)


def repad_table(rows):
    """Pad every column to its widest cell, one space each side; the separator's dashes span it.
    Returns None -- and the caller leaves the table as it is -- when the rows do not all have the
    separator's column count, or when the padded rows would not read back as the same cells."""
    split = [[c[2].strip() for c in table_cells(r)] for r in rows]
    ncol = len(split[1])
    if any(len(r) != ncol for r in split):
        return None
    split = [r + [""] * (ncol - len(r)) for r in split]
    indent = rows[0][:len(rows[0]) - len(rows[0].lstrip())]
    sep = split[1]
    widths = [max(max((_width(r[i]) for k, r in enumerate(split) if k != 1), default=0), 3)
              for i in range(ncol)]
    out = []
    for k, r in enumerate(split):
        if k == 1:
            cells = []
            for i, c in enumerate(sep):
                left, right = c.startswith(":"), c.endswith(":") and len(c) > 1
                dash = "-" * (widths[i] + 2 - left - right)
                cells.append((":" if left else "") + dash + (":" if right else ""))
            out.append(indent + "|" + "|".join(cells) + "|")
        else:
            out.append(indent + "|" + "|".join(" " + c + " " * (widths[i] - _width(c)) + " "
                                               for i, c in enumerate(r)) + "|")
    back = [[c[2].strip() for c in table_cells(r)] for r in out]
    if [r for k, r in enumerate(back) if k != 1] != [r for k, r in enumerate(split) if k != 1]:
        return None
    return out


def process(md, names, renames, defined_in, at, apply, why):
    text = open(md, encoding="utf-8").read()
    lines = text.split("\n")
    fenced = False
    changes, skipped = [], collections.Counter()
    out = []
    cache = {}
    for n, line in enumerate(lines, 1):
        if line.lstrip().startswith("```"):
            fenced = not fenced
            out.append(line)
            continue
        if fenced:
            out.append(line)
            continue
        new_line = line
        hcols = history_columns(lines, n - 1)
        cells = table_cells(line) if hcols else None
        for m in reversed(list(dsc.TICK.finditer(line))):
            w = m.group(1)
            if w in names or not dsc.looks_like_symbol(w):
                continue
            if w not in cache:
                cache[w] = resolve(w, names, renames, defined_in, at)
            new, ev = cache[w]
            if not new:
                skipped["unresolved"] += 1
                continue
            if "`%s`" % new in line:
                skipped["line already names the new label"] += 1
                continue
            if cells and any(a <= m.start() < b and i in hcols for i, (a, b, _x) in enumerate(cells)):
                skipped["old-name column of a rename table"] += 1
                continue
            if is_history_context(line, m.start(), m.end(), lines[n - 2] if n > 1 else "",
                                  lines[n] if n < len(lines) else ""):
                skipped["written as history"] += 1
                continue
            new_line = new_line[:m.start(1)] + new + new_line[m.end(1):]
            changes.append((n, w, new, ev))
        out.append(new_line)
    if apply and changes:
        # ★ A TABLE ROW THAT CHANGED WIDTH IS RE-PADDED, WHOLE TABLE AT ONCE (the owner's STRICT rule:
        #   Markdown tables are space-padded and aligned, and a cell edit realigns every row).
        for start in sorted({table_start(out, n - 1) for n, _w, _new, _ev in changes} - {None}, reverse=True):
            end = start
            while end < len(out) and table_cells(out[end]) is not None:
                end += 1
            padded = repad_table(out[start:end])
            if padded is None:
                print("%s:%d: table NOT re-padded: its rows do not all have the separator's column count"
                      % (md, start + 1), file=sys.stderr)
                continue
            out[start:end] = padded
        open(md, "w", encoding="utf-8").write("\n".join(out))
    for n, w, new, ev in changes:
        print("%s:%d: `%s` -> `%s`%s" % (md, n, w, new, ("   [" + ev + "]") if why else ""))
    return len(changes), skipped


def selftest():
    """Rows taken from the notes the first version of this tool damaged (5 tables, 764bd7124)."""
    fails = 0
    cases = [
        ("| a | `7.9375 x |depth|` | c |", ["a", "`7.9375 x |depth|`", "c"]),
        ("| 0x14 | `(class << 12) \\| entry` | x |", ["0x14", "`(class << 12) \\| entry`", "x"]),
        ("| 1 | (level << 8) \\| rate | y |", ["1", "(level << 8) \\| rate", "y"]),
        ("| note\\|0x80 | z |", ["note\\|0x80", "z"]),
        ("| ``a | b`` | `x \\| y` | q |", ["``a | b``", "`x \\| y`", "q"]),
        ("| unclosed ` tick | r |", ["unclosed ` tick", "r"]),
    ]
    for row, want in cases:
        got = [c[2].strip() for c in table_cells(row)]
        if got != want:
            print("FAIL table_cells(%r) = %r, want %r" % (row, got, want))
            fails += 1
    table = ["| h1 | h2 |", "|---|---|", "| `a | b` | c |", "| d \\| e | f |"]
    out = repad_table(table)
    if out is None or [len(table_cells(r)) for r in out] != [2, 2, 2, 2]:
        print("FAIL repad_table kept the column count: %r" % (out,))
        fails += 1
    if repad_table(["| h1 | h2 |", "|---|---|", "| a | b | c |"]) is not None:
        print("FAIL repad_table must refuse a row whose column count differs from the separator's")
        fails += 1
    print("selftest FAILURES: %d" % fails)
    return 1 if fails else 0


def audit(rev, notes, names, at):
    """Check the notes against their text at REV: (1) every table keeps its column counts; (2) every
    backticked name changed between REV and now whose OLD spelling is address-derived names an object
    AT that address (SUFFIX_IS_NOT_OWN_ADDRESS excepted).  Prints each failure and the totals."""
    import difflib
    addr_of = collections.defaultdict(set)
    for k in at:
        for a, ls in at[k].items():
            for n in ls:
                addr_of[n].add(a)
    tick = re.compile(r'`([^`]+)`')
    tbl_bad = checked = addr_bad = 0
    for md in notes:
        try:
            old = git("show", "%s:./%s" % (rev, os.path.relpath(os.path.abspath(md), ROOT)))
        except subprocess.CalledProcessError:
            continue
        new = open(md, encoding="utf-8").read()
        oc = [len(c) for c in map(table_cells, old.split("\n")) if c]
        nc = [len(c) for c in map(table_cells, new.split("\n")) if c]
        if oc != nc:
            tbl_bad += 1
            print("%s: table column counts differ from %s" % (md, rev))
        ol, nl = old.split("\n"), new.split("\n")
        for op, i1, i2, j1, j2 in difflib.SequenceMatcher(None, ol, nl, autojunk=False).get_opcodes():
            if op != "replace":
                continue
            for a_line, b_line in zip(ol[i1:i2], nl[j1:j2]):
                for o, n in zip(tick.findall(a_line), tick.findall(b_line)):
                    m = ADDR_NAME.search(o)
                    if o == n or not m or n not in names:
                        continue
                    checked += 1
                    if o not in SUFFIX_IS_NOT_OWN_ADDRESS and int(m.group(1), 16) not in addr_of[n]:
                        addr_bad += 1
                        print("%s: `%s` -> `%s`, which is not at 0x%s" % (md, o, n, m.group(1).upper()))
    print("audit against %s: %d note(s), %d with changed table column counts; %d address-derived "
          "respell(s), %d naming another address" % (rev, len(notes), tbl_bad, checked, addr_bad))
    return 1 if tbl_bad or addr_bad else 0


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("notes", nargs="*", help="Markdown files (default: every tracked .md under wsa1/)")
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--why", action="store_true", help="print the evidence for every change")
    ap.add_argument("--selftest", action="store_true", help="check the table reader and re-padder, then exit")
    ap.add_argument("--audit", metavar="REV", help="check the notes' tables and address-derived respells "
                    "against their text at REV, then exit")
    a = ap.parse_args()
    if a.selftest:
        sys.exit(selftest())
    os.chdir(ROOT)
    notes = a.notes or [p for p in git("ls-files", "*.md").split("\n") if p]
    if a.audit:
        names, at = current_labels()
        sys.exit(audit(a.audit, notes, names, at))
    renames, defined_in = history()
    names, at = current_labels()
    total, sk = 0, collections.Counter()
    for md in notes:
        c, s = process(md, names, renames, defined_in, at, a.apply, a.why)
        total += c
        sk.update(s)
    print("%d occurrence(s) %s; left alone: %s" % (total, "rewritten" if a.apply else "would be rewritten",
                                                   dict(sk)))


if __name__ == "__main__":
    main()
