#!/usr/bin/env python3
r"""Carry v10's routine headers (and in-body comments) to v9 / v7 where the code is the same.

QUESTION ANSWERED / JOB IT DOES
    CLAUDE.md's multi-version sync policy wants an edit made in one KN5000 maincpu tree to reach
    every tree holding the same code.  Documentation passes have mostly worked in v10, so many
    v10 routines carry a `;` header block that the same label in v9/maincpu or v7/maincpu lacks.
    `--count` answers "how many v10 labels with a header block have one in v9 / v7 too?".
    The default run decides, per label, whether v10's comments may be copied, and `--apply`
    copies them.

    The comment is copied only when the code it sits on is proved the same (over the label's
    span -- see the SPAN CAVEAT below) and its text holds for the target:
      * BODY.  The source from the label to the next column-0 label that does not extend the
        label's name (`Foo` runs through `Foo_Skip3`, `Foo_Return`, ...) must be textually equal
        in both trees after dropping comments, writing every number in decimal, lower-casing
        register names and dropping insignificant whitespace (norm_code).  A `.set NAME,
        VALUE` line is compared by NAME only: the value is a version-specific position, and
        spelling it in a `.set` is what keeps the code lines symbolic.  A raw number that
        differs in an instruction is NOT tolerated.
      * BYTES.  The ROM bytes of that span, located through each tree's linked ELF, must be
        equal except where a 3-byte run is a ROM address (0xE00000-0xFFFFFF) in both images
        (the same `same_code` rule as scripts/renaming/harmonize_version_labels.py).  Equal
        text over an `.incbin` does not prove equal data; this does.
      * HEADER TEXT.  The header must not quote a maincpu ROM address (0xE00000-0xFFFFFF, which
        moves between builds) that translate_addr cannot place, must not mention a firmware
        version (v7/v9/v10), and every symbol it names that the source tree defines must be
        defined in the target too.  An inline address note after a symbol (`Foo (0xEF97B6)`)
        is dropped.  For v7, whose RAM moved, every RAM number goes through RamMap.decide
        (rewritten to v7's value when v7's code is shown to use it, else kept only as a
        constant or a number the compared body spells, else refused: `quotes-ram-address`).
        A header that only restates its label (restates_label) is not copied.
      * NO DUPLICATES.  A target label that already has a header keeps it.  When the target's
        header is a subsequence of v10's (v10 extended it), it is replaced by v10's -- an
        insertion-only change.  A longer header line that already occurs elsewhere in the
        target file sends the label to review instead of being written a second time.
    BODY may also be proved by bytes alone when the two trees SPELL the same span differently
    (`.incbin` vs record macros, `.long Sym` vs `.byte`, `pushw 0xff` vs `pushw 255`): the
    spans must have the same length and the same bytes, and every 3-byte ROM address that
    differs must be the target's translation of v10's (pointers_correspond).  Only the header
    travels then, and only when it does not talk about the source text (`.byte`, `.incbin`,
    "spelled", "below", ...), which is exactly what differs; in-body lines do not pair up
    across different spellings.

    RAM-REMAP TIER (remapped_header).  v7 keeps many variables at other RAM addresses (a
    region sits 156 bytes lower).  A body whose lines pair up and differ only in RAM operands
    -- literal numbers below 0x40000 less than 0x400 apart, moved `.equ` values, or call targets
    that are the same routine under another name -- and whose bytes differ only there (and in
    relocated pointers), gets v10's header with each such RAM number rewritten to the target's.
    Any other 3-5-digit hex number in the header must be spelled in the body (a constant),
    or the header is refused.  Only targets without a header take this tier; each port is listed
    in the review list as `ported-ram-remap` with its mapping.

    Labels failing any test go to the review list (analysis/header-propagation/review-<date>.tsv)
    with the reason.  Rows whose `handport` column is filled in (a hand port, or a decision not
    to port) are kept verbatim when the list is regenerated.

    In-body comments travel under the same proof.  For a span that passed BODY and BYTES, a
    v10 trailing comment is appended to the same code line in the target when that line has
    none, and a run of comment-only lines in front of a code line is inserted when the target
    has no comment lines there.  In-body comments never get address translation: one quoting a
    ROM address stays behind, and so does a trailing `; was ...` note (the source tree's own
    edit history).  scripts/tools/carry_trailing_comments.py does not cover this:
    it re-attaches comments within one tree after a re-frame, by address, not across versions.

    SPAN CAVEAT.  Tree.span stops at the first label that does not extend the name, so a
    routine whose `_Loop`/`_Join` labels are spelled otherwise is compared on its entry
    fragment only.  RAM numbers are checked against the whole tree's code, so they are safe;
    other statements about the code past the span are not proved.  `--extent-report BASE`
    lists the headers whose routine's real extent (extent()) differs between the trees.

    Comments assemble to nothing, so `make gate` must stay green, and `--verify HEAD` must
    pass: every code line unchanged, every old comment kept in order.  (It does the job of
    scripts/analysis/assert_comments_preserved.py with an exact subsequence test; that script's
    difflib alignment reports some runs of repeated comments as lost when a new comment lands
    between them.)

RUN
    make all                                                   # the ELFs are read for BYTES
    python3 scripts/tools/propagate_v10_headers.py --count     # before/after measurement
    python3 scripts/tools/propagate_v10_headers.py             # dry run: stats + review list
    python3 scripts/tools/propagate_v10_headers.py --apply     # write v9 + v7, then the list
    make -j3 gate
    python3 scripts/tools/propagate_v10_headers.py --verify HEAD   # code unchanged, comments
                                                                   # only added
    python3 scripts/tools/propagate_v10_headers.py --check-ram BASE      # v10 RAM numbers left in
                                                                         # v7 comments since BASE
    python3 scripts/tools/propagate_v10_headers.py --audit BASE [--apply]  # re-run the current
                     # rules over the comments written since BASE (then --apply rewrites the list)
    python3 scripts/tools/propagate_v10_headers.py --extent-report BASE [--report FILE]
"""
import argparse
import bisect
import collections
import csv
import datetime
import difflib
import glob
import os
import re
import subprocess
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NM = os.path.expanduser("~/compartilhado/llvm-project/build/bin/llvm-nm")
LABEL = re.compile(r'^([A-Za-z_][\w.$]*):')
HEX = re.compile(r'\b0[xX][0-9A-Fa-f]+\b')
ROM_ADDR = re.compile(r'\b0[xX](?:00)?[eEfF][0-9A-Fa-f]{5}\b|\b(?=[A-Fa-f]*\d)[eEfF][0-9A-Fa-f]{5}\b')
VERSION = re.compile(r'\bv(?:7|9|10)\b|_v(?:7|9|10)_|\bversion', re.I)
SPELLING = re.compile(r'\.(?:byte|incbin|long|short|hword|word|ascii|asciz)\b|spell|\bbelow\b|'
                      r'\babove\b|\bline', re.I)   # talks about the source text, not the bytes
DUMP = re.compile(r'^\s*;\s*\|.*\|\s*$', re.M)      # `; |..I.3.e.|` byte dumps
WAS = re.compile(r'^;\s*was\b')                      # `; was .ascii "..."`: that tree's history
LINEREF = re.compile(r'\b((?:[\w.-]+/)*[\w.-]+\.s):(\d+)\b')
IDENT = re.compile(r'\b[A-Za-z_][A-Za-z0-9_]{3,}\b')
TRANSLATE = True       # --no-translate: calibration run, every ROM address QUOTED in a comment
                       # is refused (pointers_correspond still translates the bytes)
REVIEW_COLS = ["target", "label", "reason", "detail", "src_line", "dst_line", "ndiff",
               "nlines", "handport"]


def split_comment(line):
    """-> (code, comment); the comment starts at the first ';' outside a "string"."""
    q = False
    for i, ch in enumerate(line):
        if ch == '"':
            q = not q
        elif ch == ";" and not q:
            return line[:i], line[i:]
    return line, ""


def is_comment_line(line):
    return line.lstrip().startswith(";")


REG = re.compile(r'\b(?:Q?X?(?:WA|BC|DE|HL|IX|IY|IZ|SP)|Q?[AWBCDEHL]|SR)\b', re.I)
NUM = re.compile(r'\b0[xX][0-9A-Fa-f]+\b|\b\d+\b')
CODE_LABEL = re.compile(r'^([A-Za-z_.][\w.$]*):')


def norm_code(code):
    """Comparable form of one code line (comment already removed); '' for nothing.  Outside
    "strings": numbers become decimal (0x04 = 4 = 0x0004), register names lower case, and
    whitespace goes (around , + - * ( ) entirely, elsewhere it collapses to one space), and
    an explicit always-true condition (`jr t, X`) is dropped.
    Symbol names keep their case: the trees hold case twins that are different symbols."""
    s = code.strip()
    if not s:
        return ""
    m = re.match(r'^\.set\s+([^,\s]+)\s*,', s)
    if m:
        return ".set " + m.group(1)
    parts = s.split('"')
    for n in range(0, len(parts), 2):          # even pieces are outside quotes
        t = NUM.sub(lambda h: str(int(h.group(0), 0)), parts[n])
        t = REG.sub(lambda h: h.group(0).lower(), t)
        t = re.sub(r'\s*([,+\-*()])\s*', r'\1', t)
        parts[n] = re.sub(r'\s+', ' ', t)
    s = '"'.join(parts)
    return re.sub(r'^(jrl?|jp|call|calr) t,', r'\1 ', s)    # `t` (always) is the default


class Tree:
    def __init__(self, ver):
        self.ver = ver
        self.files = {}     # rel path -> list of lines
        self.labels = {}    # name -> (rel, line index)
        self.dups = set()
        for path in sorted(glob.glob(os.path.join(REPO, ver, "maincpu", "**", "*.s"),
                                     recursive=True)):
            rel = os.path.relpath(path, REPO)
            lines = open(path, "rb").read().decode("latin-1").split("\n")
            self.files[rel] = lines
            for i, line in enumerate(lines):
                m = LABEL.match(line)
                if m:
                    n = m.group(1)
                    if n in self.labels:
                        self.dups.add(n)
                    self.labels[n] = (rel, i)
        self.addr = None
        self.symbols = None
        self.ram = None     # RamMap for a target whose RAM moved (v7), set by main()
        # E/F-range numbers the code spells as literals: constants (object handles, view
        # ids), never ROM addresses -- the sources spell those symbolically
        self.literals = set()
        for lines in self.files.values():
            for line in lines:
                code = split_comment(line)[0]
                for m in ROM_ADDR.finditer(code):
                    t = m.group(0)
                    if t[:2] in ("0x", "0X"):
                        self.literals.add(int(t[2:], 16))

    def load_elf(self):
        elf = os.path.join(REPO, "rebuilt_ROMs", "kn5000_%s_program.llvm.elf" % self.ver)
        out = subprocess.run([NM, "--defined-only", elf], capture_output=True, text=True,
                             check=True).stdout
        self.addr, self.symbols, self.value = {}, set(), {}
        for line in out.splitlines():
            parts = line.split()
            if len(parts) != 3:
                continue
            self.symbols.add(parts[2])
            self.value[parts[2]] = int(parts[0], 16)
            if parts[1].lower() == "t":
                self.addr[parts[2]] = int(parts[0], 16)
        self.names_at = collections.defaultdict(set)
        for n, a in self.addr.items():
            self.names_at[a].add(n)
        self.sorted_addr = sorted((a, n) for n, a in self.addr.items())
        self.sorted_keys = [a for a, _ in self.sorted_addr]
        self.rom = open(os.path.join(REPO, "original_ROMs",
                                     "kn5000_%s_program.rom" % self.ver), "rb").read()

    def header(self, rel, i):
        """Index of the first line of the comment block directly above line i (== i: none)."""
        lines = self.files[rel]
        j = i
        while j > 0 and is_comment_line(lines[j - 1]):
            j -= 1
        return j

    def span(self, name):
        """(rel, label line, end line, end label) of the body of `name`."""
        rel, i = self.labels[name]
        lines = self.files[rel]
        k = i + 1
        while k < len(lines):
            m = LABEL.match(lines[k])
            if m and not m.group(1).startswith(name + "_"):
                break
            k += 1
        end_label = None
        if k < len(lines):
            end_label = LABEL.match(lines[k]).group(1)
            # comment lines right above the terminating label are ITS header, not our body
            k = self.header(rel, k)
        return rel, i, k, end_label

    def body(self, name):
        """[(line index, normalized code, comment, code text)] over the label's span, plus the
        comment-only line runs keyed by the index of the code entry they precede."""
        rel, i, k, end_label = self.span(name)
        lines = self.files[rel]
        code, before, pending = [], {}, []
        for j in range(i, k):
            text = lines[j]
            if is_comment_line(text):
                pending.append(j)
                continue
            c, com = split_comment(text)
            entries = []
            m = CODE_LABEL.match(c)
            if m:                     # `Label:` and `Label: .byte 1` compare alike
                rest = c[m.end():]
                if norm_code(rest):
                    entries = [(j, m.group(0), "", ""), (j, norm_code(rest), com, c)]
                else:
                    entries = [(j, m.group(0), com, c)]
            elif norm_code(c):
                entries = [(j, norm_code(c), com, c)]
            if not entries:
                pending = []          # a blank line ends a comment run
                continue
            if pending:
                before[len(code)] = pending
                pending = []
            code.extend(entries)
        return code, before, end_label


def same_code(a, b):
    """Equal, except where a byte run is a 24-bit little-endian ROM address in BOTH."""
    if len(a) != len(b):
        return False
    i = 0
    while i < len(a):
        if a[i] == b[i]:
            i += 1
            continue
        for j in (i - 2, i - 1, i):
            if 0 <= j and j + 3 <= len(a):
                x, y = int.from_bytes(a[j:j + 3], "little"), int.from_bytes(b[j:j + 3], "little")
                if 0xE00000 <= x <= 0xFFFFFF and 0xE00000 <= y <= 0xFFFFFF:
                    i = j + 3
                    break
        else:
            return False
    return True


def same_target(x, y, src, dst):
    """Do v10 ROM address x and target ROM address y name the same thing?  Yes when one label
    sits at both under the same name (the trees' own correspondence), or when translate_addr
    maps x onto y."""
    return bool(src.names_at.get(x, set()) & dst.names_at.get(y, set())) or \
        translate_addr(x, src, dst) == y


def pointers_correspond(a, b, src, dst):
    """Same bytes, except 3-byte ROM addresses that name the same thing (same_target): the
    proof for a body the two trees spell differently (`.incbin` vs records, `.long Sym` vs
    `.byte`, `0xff` vs `255`).  Stricter than same_code, which accepts any two addresses."""
    if len(a) != len(b):
        return False
    i = 0
    while i < len(a):
        if a[i] == b[i]:
            i += 1
            continue
        for j in (i - 2, i - 1, i):
            if 0 <= j and j + 3 <= len(a):
                x, y = int.from_bytes(a[j:j + 3], "little"), int.from_bytes(b[j:j + 3], "little")
                if 0xE00000 <= x <= 0xFFFFFF and same_target(x, y, src, dst):
                    i = j + 3
                    break
        else:
            return False
    return True


RAM_TOP = 0x40000      # RAM operands the trees move between builds lie below this
RAM_SHIFT = 0x400      # ... and move by less than this (v7's region sits 156 bytes lower)
TOKEN = re.compile(r'[A-Za-z_.][\w.$]*|\d+|\S')
HEXNUM = re.compile(r'\b0[xX][0-9A-Fa-f]{3,5}\b')


def ram_pairs(sb, db, src, dst):
    """For bodies of the same shape that differ only in RAM operands: {v10 value: target value},
    or None.  Lines must pair up and differ token for token only where (a) both tokens are
    numbers below RAM_TOP, less than RAM_SHIFT apart, (b) both are code labels that
    translate_addr maps onto each other (the same routine under another name), or (c) both are
    the same `.equ` whose value moved.  The same symbol with a moved value counts as (c) on equal
    lines too.  The mapping must be one-to-one."""
    if len(sb) != len(db):
        return None
    pairs = {}

    def add(x, y):
        if x == y:
            return True
        if not (x < RAM_TOP and y < RAM_TOP and abs(x - y) < RAM_SHIFT):
            return False
        if pairs.get(x, y) != y or (y in pairs.values() and pairs.get(x) != y):
            return False
        pairs[x] = y
        return True

    def value_pair(x, y):
        if x in src.addr or y in dst.addr:          # code labels: the same routine?
            return (x in src.addr and y in dst.addr
                    and translate_addr(src.addr[x], src, dst) == dst.addr[y])
        if x in src.value and y in dst.value:       # absolute .equ
            return add(src.value[x], dst.value[y])
        return False

    for (_, s, _, _), (_, d, _, _) in zip(sb, db):
        ts, td = TOKEN.findall(s), TOKEN.findall(d)
        if len(ts) != len(td):
            return None
        for x, y in zip(ts, td):
            if x.isdigit() and y.isdigit():
                if not add(int(x), int(y)):
                    return None
            elif x[0].isdigit() or y[0].isdigit():
                return None
            elif x != y:
                if not (re.match(r'[A-Za-z_]', x) and re.match(r'[A-Za-z_]', y)
                        and value_pair(x, y)):
                    return None
            elif x in src.value and x in dst.value and x not in src.addr:
                if not add(src.value[x], dst.value[x]):
                    return None
    return pairs


def bytes_match_with(a, b, pairs, src, dst):
    """Same length and bytes, except relocated ROM pointers (as pointers_correspond) and 2- to
    4-byte little-endian operands whose v10 value maps to the target's through `pairs`."""
    if len(a) != len(b):
        return False
    i = 0
    while i < len(a):
        if a[i] == b[i]:
            i += 1
            continue
        nxt = None
        for w in (2, 3, 4):
            for j in range(max(0, i - w + 1), i + 1):
                if j + w <= len(a):
                    x, y = int.from_bytes(a[j:j + w], "little"), int.from_bytes(b[j:j + w], "little")
                    if pairs.get(x) == y or (w == 3 and 0xE00000 <= x <= 0xFFFFFF
                                             and same_target(x, y, src, dst)):
                        nxt = j + w
                        break
            if nxt:
                break
        if not nxt:
            return False
        i = nxt
    return True


def remap_ram(text, pairs, body_numbers):
    """Header text with each RAM number of `pairs` written as the target's value -> (text, bad):
    a number of 3-5 hex digits that is neither in `pairs` nor spelled in the body is unproven."""
    bad = []

    def sub(m):
        tok = m.group(0)
        v = int(tok, 16)
        if v in pairs:
            digits = len(tok) - 2
            f = "%0*X" if tok[2:].upper() == tok[2:] else "%0*x"
            return tok[:2] + f % (digits, pairs[v])
        if v >= 0x100 and v < RAM_TOP and (v in pairs.values() or v not in body_numbers):
            bad.append(tok)
        return tok

    out = HEXNUM.sub(sub, text)
    return out, bad


def rom_span(tree, name, end_label):
    """ROM bytes from `name` to the label that ends its body.  At the end of a file the body
    ends at the next symbol address that is not one of the body's own names."""
    a = tree.addr.get(name)
    e = tree.addr.get(end_label) if end_label else None
    if a is not None and e is None and end_label is None:
        rel, i, k, _ = tree.span(name)
        own = set()
        for line in tree.files[rel][i:k]:
            m = LABEL.match(line) or re.match(r'^\s*\.set\s+([^,\s]+)', line)
            if m:
                own.add(m.group(1))
        later = [x for n, x in tree.addr.items() if x > a and n not in own]
        e = min(later) if later else None
    if a is None or e is None or not 0xE00000 <= a <= e <= 0x1000000:
        return None
    return tree.rom[a - 0xE00000:e - 0xE00000]


def translate_addr(x, src, dst):
    """The target-image address of v10 ROM address x, or None.  x is taken relative to the
    nearest preceding v10 label that the target defines too, and accepted only when the bytes
    from that label to x + 4 are the same code in both images (same_code)."""
    for a, name in reversed(src.sorted_addr[:bisect.bisect_right(src.sorted_keys, x)][-8:]):
        b = dst.addr.get(name)
        if b is None or x - a > 0x800:
            continue
        off = x - a
        sa = src.rom[a - 0xE00000:x - 0xE00000 + 4]
        db = dst.rom[b - 0xE00000:b + off - 0xE00000 + 4]
        if len(sa) == len(db) and same_code(sa, db):
            return b + off
    return None


def translate_linerefs(text, dst):
    """Rewrite `path.s:NNNN` to the target's line number -> (text, first refused ref or '').
    A line number alone proves nothing, so a reference is translated only when the comment
    quotes that line's code in backticks right after it -- (path.s:5315): `RegObjTable
    ...` -- and that code occurs on exactly one line of the target's file of that name."""
    bad = []

    def sub(m):
        path = m.group(1).replace("kn5000_v10_program", "kn5000_%s_program" % dst.ver)
        q = re.match(r'\)?:?\s*`([^`]+)`', text[m.end():])
        files = [r for r in dst.files if r.endswith("/" + path)]
        if not q or len(files) != 1:
            bad.append(m.group(0))
            return m.group(0)
        want = norm_code(q.group(1))
        hits = [n for n, line in enumerate(dst.files[files[0]], 1)
                if norm_code(split_comment(line)[0]) == want]
        if len(hits) != 1:
            bad.append(m.group(0))
            return m.group(0)
        return "%s:%d" % (m.group(1).replace("kn5000_v10_program",
                                             "kn5000_%s_program" % dst.ver), hits[0])

    out = LINEREF.sub(sub, text)
    return out, (bad[0] if bad else "")


def adapt(text, src, dst, translate=True, exact=True, body_nums=(), keep=()):
    """-> (text for the target, reason it cannot be copied or '', detail).  An inline address
    note after a symbol (`Foo (0xEF97B6)`) is dropped, not translated.  Quoted v10 ROM
    addresses are rewritten to the target's when their correspondence is proved (and the
    number is not one the code spells as a literal, i.e. a constant).  For a target whose RAM
    moved (dst.ram, v7), every RAM number goes through ram_check: rewritten by the measured
    map when the target's code spells the moved value, kept when the compared body
    (body_nums) spells it or it is a constant the target spells, refused otherwise; anything
    else version-specific (a source line number that translate_linerefs cannot place, a
    version name, a symbol the target lacks) is refused.  With translate=False (the in-body comments) a quoted ROM address is refused
    too: those are mostly inline address notes, which CLAUDE.md forbids, and a constant in the
    0xE00000-0xFFFFFF range (an object handle such as 0xf4fc10) can look like one.  A
    `; |....|` byte dump is copied only when the span's bytes are exactly equal (exact),
    since same_code lets pointer bytes differ."""
    notes = []
    if not exact and DUMP.search(text):
        return text, "dump-of-differing-bytes", DUMP.search(text).group(0).strip()

    def sub_addr(m):
        tok = m.group(0)
        if not translate or not TRANSLATE:
            notes.append(tok)
            return tok
        x = int(tok[2:] if tok[:2] in ("0x", "0X") else tok, 16)
        y = translate_addr(x, src, dst)
        if y is None or (y != x and x in src.literals):
            notes.append(tok)
            return tok
        digits = "%06X" % y if tok[-6:].upper() == tok[-6:] else "%06x" % y
        return tok[:-6] + digits

    out = ROM_ADDR.sub(sub_addr, drop_address_notes(text, src.symbols))
    if notes:
        return text, "quotes-rom-address", notes[0]
    if getattr(dst, "ram", None) is not None:
        out, bad, _ = ram_check(out, dst.ram, body_nums, keep)
        if bad:
            return text, "quotes-ram-address", bad[0]
    out, bad = translate_linerefs(out, dst)
    if bad:
        return text, "quotes-source-line", bad
    if VERSION.search(out):
        return text, "mentions-version", VERSION.search(out).group(0)
    absent = sorted({w for w in IDENT.findall(out)
                     if w in src.symbols and w not in dst.symbols})
    if absent:
        return text, "names-absent-symbol", " ".join(absent[:6])
    return out, "", ""


# ---- v7 RAM relocation guard -------------------------------------------------------------
# v7 keeps two RAM regions at other addresses (v7-ram-shift-2026-10-24.txt).  A RAM number in
# a v10 comment is therefore checked against the target's code before the comment travels.
RAMNUM = re.compile(r'\b0[xX][0-9A-Fa-f]{4,5}\b|\b\d[0-9A-Fa-f]{3,4}[hH]\b|'
                    r'(?<![\w.,$])\d{4,5}\b(?![\w])')
ABBREV = re.compile(r'(?:/[0-9A-Fa-f]{1,3}\b)+')          # 0xFD34/35/4A: low digits only
NUM_IN_CODE = re.compile(r'\b0[xX][0-9A-Fa-f]+\b|\b\d+\b')


def ram_value(tok):
    if tok[:2] in ("0x", "0X"):
        return int(tok[2:], 16)
    if tok[-1] in "hH":
        return int(tok[:-1], 16)
    return int(tok)


def ram_spell(tok, v):
    """v written in the notation (and digit case / width) of tok."""
    if tok[:2] in ("0x", "0X"):
        digits = tok[2:]
        f = "%0*X" if digits.upper() == digits else "%0*x"
        return tok[:2] + f % (len(digits), v)
    if tok[-1] in "hH":
        digits = tok[:-1]
        f = "%0*X" if digits.upper() == digits else "%0*x"
        return f % (len(digits), v) + tok[-1]
    return str(v)


def code_numbers(tree):
    """-> (every number the tree's code lines spell, the subset spelled as a memory operand,
    right after `(`), outside strings and comments, `.equ` values included: what 'the code
    uses' means below."""
    out, mem = set(), set()
    for lines in tree.files.values():
        for line in lines:
            code = split_comment(line)[0]
            if not code.strip():
                continue
            for n, part in enumerate(code.split('"')):
                if n % 2 == 0:
                    for m in NUM_IN_CODE.finditer(part):
                        v = int(m.group(0), 0)
                        out.add(v)
                        if part[:m.start()].rstrip().endswith("("):
                            mem.add(v)
    return out, mem


class RamMap:
    """The v10 -> target RAM relocation, measured by scripts/analysis/v7_ram_shift_map.py
    (paired memory operands; runs of at least 2 observations per address, as committed in
    v7-ram-shift-2026-10-24.txt)."""

    def __init__(self, src, dst):
        sys.path.insert(0, os.path.join(REPO, "scripts", "analysis"))
        import v7_ram_shift_map as M
        self.obs = M.observations(src, dst)
        self.runs = M.runs(self.obs, 2)
        self.src_code, self.src_mem = code_numbers(src)
        self.dst_code, self.dst_mem = code_numbers(dst)

    def run_of(self, n):
        for r in self.runs:
            if r["lo"] <= n <= r["hi"]:
                return r
        return None

    def moved(self, n):
        """Delta of the measured run holding n (0 when unmoved), or None between runs."""
        r = self.run_of(n)
        if r:
            return r["delta"]
        if n < self.runs[0]["lo"] or n > self.runs[-1]["hi"]:
            return 0
        return None

    def decide(self, n, body_nums):
        """-> ("keep", n) | ("rewrite", target value) | ("refuse", why) for v10 number n quoted
        in a comment that travels to the target.  In a moved range, n is rewritten only when
        v10's code spells n and the target's code spells n + delta (and not n, or n is shown
        moved by paired code); kept when the compared body spells it, or when it is a constant
        (the target spells n, never as a memory operand, and never spells n + delta); refused
        otherwise -- an address may be loaded as an immediate (`ld xix, 0x3692`), so a number
        both trees spell is no constant when the target also spells n + delta."""
        if n < 0x100 or n >= RAM_TOP or n in body_nums:
            return "keep", n                     # not RAM, or spelled by the compared body
        c = self.obs.get(n)
        d = c.most_common(1)[0][0] if c else self.moved(n)
        if d == 0:
            return "keep", n
        if d is None:                            # between measured runs
            if n in self.src_code and n in self.dst_code:
                return "keep", n
            return "refuse", "unmeasured RAM range, not spelled by both trees' code"
        src, dst, moved = n in self.src_code, n in self.dst_code, n + d in self.dst_code
        if src and moved and not dst:
            return "rewrite", n + d
        if dst and not moved and n not in self.dst_mem:
            return "keep", n                     # a constant the target code spells too
        if src and moved and c and c.most_common(1)[0][0] == d:
            return "rewrite", n + d              # paired code shows the target's address
        if not src:
            return "refuse", "v10's code never spells it (moved %+d?)" % d
        return "refuse", "in a range moved %+d; not shown which value the target uses" % d


def ram_check(text, ram, body_nums, keep=(), only=None):
    """Rewrite the RAM numbers of `text` for the target -> (text, refusals, rewrites).
    keep: values already written for the target (RAM tier, hand ports).  only: when given,
    just these token spellings are candidates (the audit: tokens verbatim from v10's text)."""
    bad, done = [], []

    def sub(m):
        tok = m.group(0)
        if only is not None and tok not in only:
            return tok
        n = ram_value(tok)
        if n in keep:
            return tok
        what, v = ram.decide(n, body_nums)
        if what == "keep":
            return tok
        if what == "refuse" or ABBREV.match(text, m.end()):
            bad.append("%s (%s)" % (tok, v if what == "refuse" else "abbreviated suffixes"))
            return tok
        done.append("%s->%s" % (tok, ram_spell(tok, v)))
        return ram_spell(tok, v)

    out = RAMNUM.sub(sub, text)
    return out, bad, done


# `Symbol (0xEF97B6)`: an inline address note (CLAUDE.md forbids them); the symbol says it all
ADDR_NOTE = re.compile(r'\b([A-Za-z_]\w*)\s*\(\s*(?:at\s+)?(?:0[xX](?:00)?[eEfF][0-9A-Fa-f]{5}'
                       r'|[eEfF][0-9A-Fa-f]{5}h?)\s*\)')


def drop_address_notes(text, symbols):
    return ADDR_NOTE.sub(lambda m: m.group(1) if m.group(1) in symbols else m.group(0), text)


STOPWORDS = {"a", "an", "the", "of", "for", "to", "and", "in", "on", "at", "by"}
ABBREVS = {"evt": "event", "cmd": "command", "msg": "message", "ptr": "pointer",
           "btn": "button", "num": "number", "ctrl": "control", "tbl": "table",
           "val": "value", "buf": "buffer", "addr": "address", "idx": "index",
           "cnt": "count", "calc": "calculate", "chk": "check", "disp": "display",
           "len": "length", "pos": "position", "sel": "select", "param": "parameter",
           "init": "initialize", "proc": "procedure", "seq": "sequencer", "app": "application",
           "acc": "accompaniment", "str": "string", "snd": "sound", "util": "utility"}


def restates_label(lines, name):
    """True when the header's words are all words of the label (camel case / underscores,
    common abbreviations and prefixes allowed): it says nothing the label does not."""
    text = " ".join(l.strip().lstrip(";").strip() for l in lines)
    text = re.sub(r'^' + re.escape(name) + r'\s*:', "", text).strip()
    words = [w.lower() for w in re.findall(r'[A-Z]+(?![a-z])|[A-Z]?[a-z]+|\d+', text)]
    toks = [t.lower() for t in re.findall(r'[A-Z]+(?![a-z])|[A-Z]?[a-z]+|\d+', name)]
    if not words or not toks:
        return False

    def match(w):
        for t in toks:
            full = ABBREVS.get(t, t)
            if w in (t, full, t + "s", full + "s"):
                return True
            if len(t) >= 3 and len(w) >= 3 and (w.startswith(t) or t.startswith(w)
                                                or full.startswith(w) or w.startswith(full)):
                return True
        return False

    return all(w in STOPWORDS or match(w) for w in words)


def is_subsequence(small, big):
    it = iter(big)
    return all(any(x == y for y in it) for x in small)


def count(src, dst):
    c = collections.Counter()
    for name, (rel, i) in src.labels.items():
        if name in src.dups or src.header(rel, i) == i:
            continue
        c["src_header"] += 1
        if name not in dst.labels or name in dst.dups:
            c["absent"] += 1
            continue
        r2, i2 = dst.labels[name]
        c["has" if dst.header(r2, i2) < i2 else "lacks"] += 1
    return c


def body_numbers(body):
    """The numbers a body's normalized code spells (norm_code wrote them in decimal)."""
    return {int(t) for _, s, _, _ in body for t in re.findall(r'\d+', s)}


def remapped_header(name, hdr, sb, db, send, dend, src, dst):
    """The RAM-remap tier: a body whose only differences are RAM operands (ram_pairs, checked
    against the bytes) gets v10's header with those RAM numbers rewritten -> (lines, detail)
    or None."""
    pairs = ram_pairs(sb, db, src, dst)
    if not pairs:
        return None
    a, b = rom_span(src, name, send), rom_span(dst, name, dend)
    if not a or b is None or not bytes_match_with(a, b, pairs, src, dst):
        return None
    nums = {int(t) for _, s, _, _ in sb for t in re.findall(r'\d+', s)}
    text, bad = remap_ram("\n".join(hdr), pairs, nums)
    if bad:
        return None
    text, why, _ = adapt(text, src, dst, body_nums=body_numbers(db),
                         keep=set(pairs.values()))
    if why or restates_label(text.split("\n"), name):
        return None
    detail = ", ".join("0x%x->0x%x" % kv for kv in sorted(pairs.items()))
    return text.split("\n"), detail[:160]


def plan(src, dst):
    """-> (edits: {rel: {(line, delete_count): new_lines}}, review rows, stats).  Keyed by
    position because a routine's span contains its `_SkipN` labels' spans: both prove the same
    lines and must not write them twice."""
    edits = collections.defaultdict(dict)
    review, st = [], collections.Counter()
    for name, (rel, i) in sorted(src.labels.items()):
        if name in src.dups:
            continue
        h0 = src.header(rel, i)
        hdr = src.files[rel][h0:i]
        if name not in dst.labels or name in dst.dups:
            if hdr:
                st["absent"] += 1
                review.append([dst.ver, name, "label-absent", "", "%s:%d" % (rel, i + 1), "",
                               "", "", ""])
            continue
        r2, i2 = dst.labels[name]
        dlines = dst.files[r2]
        d0 = dst.header(r2, i2)
        dhdr = dlines[d0:i2]
        sb, sbefore, send = src.body(name)
        db, dbefore, dend = dst.body(name)
        sn, dn = [x[1] for x in sb], [x[1] for x in db]
        row = [dst.ver, name, "", "", "%s:%d" % (rel, i + 1), "%s:%d" % (r2, i2 + 1), "", "",
               ""]
        byte_proven = False
        if sn != dn:
            a, b = rom_span(src, name, send), rom_span(dst, name, dend)
            byte_proven = bool(a) and b is not None and pointers_correspond(a, b, src, dst)
        def ram_tier():
            """The RAM-remap tier; True when it settled the label (ported now or before)."""
            moved = remapped_header(name, hdr, sb, db, send, dend, src, dst)
            if not moved or (dhdr and moved[0] != dhdr):
                return False
            if dhdr:                      # ported before; this run's ports keep their rows
                st["header-already"] += 1    # through write_review's `handport` rule
                return True
            edits[r2][(d0, 0)] = moved[0]
            st["header-by-ram-remap"] += 1
            row[2], row[3], row[8] = "ported-ram-remap", moved[1], "scripted (RAM remap tier)"
            review.append(row)
            return True

        if hdr and dhdr != hdr and sn != dn and not byte_proven and ram_tier():
            continue
        if sn != dn and not byte_proven:
            if hdr and dhdr != hdr:
                sm = difflib.SequenceMatcher(None, sn, dn, autojunk=False)
                nd = sum(max(i2_ - i1, j2 - j1) for t, i1, i2_, j1, j2 in sm.get_opcodes()
                         if t != "equal")
                first = next(((sn[i1:i2_], dn[j1:j2]) for t, i1, i2_, j1, j2 in sm.get_opcodes()
                              if t != "equal"))
                row[2] = "body-differs"
                row[3] = ("v10 %s | %s %s" % (" / ".join(first[0][:2]) or "-", dst.ver,
                                              " / ".join(first[1][:2]) or "-"))[:160]
                row[6], row[7] = str(nd), str(max(len(sn), len(dn)))
                review.append(row)
                st["body-differs"] += 1
            continue
        a, b = rom_span(src, name, send), rom_span(dst, name, dend)
        if byte_proven:
            bytes_ok = True
        elif a is None or b is None:
            bytes_ok = None
        else:
            bytes_ok = same_code(a, b)
        exact = a is not None and a == b
        if bytes_ok is False and hdr and dhdr != hdr and ram_tier():
            continue
        if bytes_ok is False:
            if hdr and dhdr != hdr:
                row[2], row[3] = "bytes-differ", "%d vs %d bytes" % (len(a), len(b))
                review.append(row)
                st["bytes-differ"] += 1
            continue
        if bytes_ok is None:
            st["no-byte-check"] += 1
            exact = False
        # ---- the header
        if hdr and dhdr != hdr:
            text, why, what = adapt("\n".join(hdr), src, dst, True, exact, body_numbers(db))
            new_hdr = text.split("\n")
            if not why and not dhdr and restates_label(new_hdr, name):
                why, what = "restates-label", new_hdr[0].strip()[:100]
            if not why and new_hdr == dhdr:
                st["header-already"] += 1           # already ported, addresses translated
                why = "done"
            elif not why and dhdr and not is_subsequence(dhdr, new_hdr):
                why, what = "existing-header-differs", dhdr[0].strip()[:100]
            if not why:
                dfile = set(l.strip() for l in dlines)
                dup = [l for l in new_hdr if len(l.strip()) > 30 and l.strip() in dfile
                       and l not in dhdr]
                if dup:
                    why, what = "header-text-elsewhere", dup[0].strip()[:100]
            if not why and byte_proven and SPELLING.search(text):
                why, what = "spelling-differs", SPELLING.search(text).group(0)
            if why == "done":
                pass
            elif why:
                row[2], row[3] = why, what
                review.append(row)
                st[why] += 1
            else:
                edits[r2][(d0, i2 - d0)] = new_hdr
                st["header-replaced" if dhdr else "header-inserted"] += 1
                if byte_proven:
                    st["header-by-bytes"] += 1
                if new_hdr != hdr:
                    st["header-addresses-translated"] += 1
        elif hdr:
            st["header-already"] += 1
        # ---- in-body comments (same proof: body text + bytes; a byte-proven body is spelled
        # differently, so its lines do not pair up)
        if byte_proven:
            continue
        for k, (sj, _, scom, scode) in enumerate(sb):
            dj, _, dcom, dcode = db[k]
            com, why, _ = (adapt(scom, src, dst, False, exact, body_numbers(db))
                           if scom and not dcom and not WAS.match(scom) else ("", "x", ""))
            if not why and (dj, 1) not in edits[r2]:
                gap = scode[len(scode.rstrip()):] or "\t"
                edits[r2][(dj, 1)] = [dlines[dj].rstrip() + gap + com]
                st["trailing-carried"] += 1
            elif scom and dcom and scom.strip() != dcom.strip():
                st["trailing-differs"] += 1
            # a comment run in front of a label line is that label's header: its own turn
            if (k in sbefore and k not in dbefore and k > 0 and not LABEL.match(dlines[dj])
                    and (dj, 0) not in edits[r2]):
                text, why, _ = adapt("\n".join(src.files[rel][x] for x in sbefore[k]), src, dst,
                                     False, exact, body_numbers(db))
                if not why:
                    edits[r2][(dj, 0)] = text.split("\n")
                    st["interior-carried"] += 1
    return edits, review, st


# ---- audit of comments already written (since BASE) ---------------------------------------
def added_comments(base, tree):
    """{rel: (set of added comment-only line indices, {code line index: line at BASE})} for
    the comments written into `tree` since BASE (a code line whose comment was appended maps
    to its old text).  Code lines pair up in order (--verify's invariant); between two code
    lines, the BASE comment lines are matched greedily, in order, and the rest are new."""
    files = subprocess.run(["git", "diff", "--name-only", base, "--", tree.ver + "/maincpu"],
                           cwd=REPO, capture_output=True, text=True, check=True).stdout.split()
    res = {}
    for rel in files:
        if not rel.endswith(".s") or rel not in tree.files:
            continue
        old = subprocess.run(["git", "show", "%s:%s" % (base, rel)], cwd=REPO,
                             capture_output=True, check=True).stdout.decode("latin-1").split("\n")
        new = tree.files[rel]

        def segments(lines):
            """[(comment-only lines before code line n, (index, code line n))] + tail."""
            segs, com = [], []
            for k, l in enumerate(lines):
                if is_comment_line(l):
                    com.append((k, l))
                elif split_comment(l)[0].strip():
                    segs.append((com, (k, l)))
                    com = []
            segs.append((com, None))
            return segs

        so, sn = segments(old), segments(new)
        if len(so) != len(sn):
            raise SystemExit("%s: code lines changed since %s" % (rel, base))
        added, appended = set(), {}
        for (oc, ol), (nc, nl) in zip(so, sn):
            it = iter([l for _, l in oc])
            want = next(it, None)
            for k, l in nc:
                if l == want:
                    want = next(it, None)
                else:
                    added.add(k)
            if want is not None:
                raise SystemExit("%s: a comment line was lost since %s" % (rel, base))
            if ol and nl and ol[1] != nl[1]:
                if split_comment(ol[1])[0].rstrip() != split_comment(nl[1])[0].rstrip():
                    raise SystemExit("%s:%d: a code line changed since %s" % (rel, nl[0] + 1, base))
                appended[nl[0]] = ol[1]
        res[rel] = (added, appended)
    return res


def hand_ported(review, ver):
    """Labels whose header in `ver` is a hand port (review list, `handport` column): the
    person who ported it judged its numbers, and the note says why each one holds."""
    out = set()
    if os.path.exists(review):
        with open(review, newline="", encoding="utf-8") as f:
            for r in csv.DictReader(f, delimiter="\t"):
                if r["target"] == ver and r.get("handport", "").startswith("hand-ported"):
                    out.add(r["label"])
    return out


def audit(base, src, dst, fix, check_only=False, review=None):
    """Re-examine every comment written into dst since BASE under the current rules:
    RAM numbers (v7), inline address notes, label-restating headers.  -> (edits, rows, stats,
    report lines).  check_only: only flag RAM tokens by the review criterion (verbatim in
    v10's header, v10 code spells it, the target's code never does, and spells it moved by
    -156 or -198)."""
    added = added_comments(base, dst)
    edits = collections.defaultdict(dict)
    rows, st, report = [], collections.Counter(), []
    syms = (src.symbols or set()) | (dst.symbols or set())
    flagged_headers = set()
    by_hand = hand_ported(review, dst.ver) if review else set()
    for rel in sorted(added):
        new_comments, appended = added[rel]
        lines = dst.files[rel]
        labels = [(k, LABEL.match(l).group(1)) for k, l in enumerate(lines) if LABEL.match(l)]
        keys = [k for k, _ in labels]
        in_header = set()

        def enclosing(k):
            j = bisect.bisect_right(keys, k) - 1
            return labels[j][1] if j >= 0 else None

        def nums_of(name):
            if not name or name not in dst.labels or dst.labels[name][0] != rel:
                return set()
            return body_numbers(dst.body(name)[0])

        for k, name in labels:
            h0 = dst.header(rel, k)
            block = list(range(h0, k))
            new = [j for j in block if j in new_comments]
            if not new:
                continue
            in_header.update(block)
            st["headers-touched"] += 1
            v10 = ""
            if name in src.labels and name not in src.dups:
                r1, i1 = src.labels[name]
                v10 = "\n".join(src.files[r1][src.header(r1, i1):i1])
            only = {m.group(0) for m in RAMNUM.finditer(v10)}
            if check_only:
                for j in new:
                    for m in RAMNUM.finditer(lines[j]):
                        n = ram_value(m.group(0))
                        if (m.group(0) in only and n in dst.ram.src_code
                                and n not in dst.ram.dst_code
                                and (n - 156 in dst.ram.dst_code or n - 198 in dst.ram.dst_code)):
                            st["flagged-tokens"] += 1
                            flagged_headers.add(name)
                            report.append("FLAG %s %s:%d %s" % (name, rel, j + 1, m.group(0)))
                continue
            body = nums_of(name)
            out, bad, done = {}, [], []
            for j in new:
                t = drop_address_notes(lines[j], syms)
                if t != lines[j]:
                    st["address-notes-dropped"] += 1
                if dst.ram is not None and name not in by_hand:
                    t, b, d = ram_check(t, dst.ram, body, only=only)
                    bad += b
                    done += d
                out[j] = t
            whole = len(new) == len(block)
            row = [dst.ver, name, "", "", "", "%s:%d" % (rel, k + 1), "", "", ""]
            if bad:
                why, what = "quotes-ram-address", bad[0]
            elif whole and restates_label([out[j] for j in block], name):
                why, what = "restates-label", out[block[0]].strip()[:100]
            else:
                why = ""
            if why:
                for j in new:
                    edits[rel][(j, 1)] = []
                st["header-removed-" + why] += 1
                row[2], row[3] = why, what
                rows.append(row)
                report.append("REMOVE %-20s %s %s:%d  %s" % (why, name, rel, k + 1, what))
                continue
            for j in new:
                if out[j] != lines[j]:
                    edits[rel][(j, 1)] = [out[j]]
            if done:
                st["header-ram-rewritten"] += 1
                report.append("REWRITE %s %s:%d  %s" % (name, rel, k + 1, ", ".join(done)))
        if check_only:
            continue
        # in-body comment runs and appended trailing comments: copied verbatim from v10
        runs, cur = [], []
        for j in sorted(new_comments - in_header):
            if cur and j == cur[-1] + 1:
                cur.append(j)
            else:
                cur = [j]
                runs.append(cur)
        for run in runs:
            name = enclosing(run[0])
            out, bad = {}, []
            for j in run:
                t = drop_address_notes(lines[j], syms)
                if dst.ram is not None:
                    t, b, _ = ram_check(t, dst.ram, nums_of(name))
                    bad += b
                out[j] = t
            if bad:
                for j in run:
                    edits[rel][(j, 1)] = []
                st["interior-removed"] += 1
                report.append("REMOVE interior %s %s:%d  %s" % (name, rel, run[0] + 1, bad[0]))
            else:
                for j in run:
                    if out[j] != lines[j]:
                        edits[rel][(j, 1)] = [out[j]]
        for j, old in sorted(appended.items()):
            name = enclosing(j)
            code, com = split_comment(lines[j])
            t = drop_address_notes(com, syms)
            bad = []
            if dst.ram is not None:
                t, bad, _ = ram_check(t, dst.ram, nums_of(name))
            if bad:
                edits[rel][(j, 1)] = [old]
                st["trailing-removed"] += 1
                report.append("REMOVE trailing %s %s:%d  %s" % (name, rel, j + 1, bad[0]))
            elif t != com:
                edits[rel][(j, 1)] = [code + t]
    if check_only:
        st["flagged-headers"] = len(flagged_headers)
    return edits, rows, st, report


def references(tree):
    """{symbol: [(rel, line index)]} of every code-line mention (a label's own definition
    excluded)."""
    out = collections.defaultdict(list)
    for rel, lines in tree.files.items():
        for k, line in enumerate(lines):
            c = split_comment(line)[0]
            m = LABEL.match(c)
            if m:
                c = c[m.end():]
            for n, part in enumerate(c.split('"')):
                if n % 2 == 0:
                    for t in re.findall(r'[A-Za-z_][\w.$]*', part):
                        out[t].append((rel, k))
    return out


def extent(tree, refs, name):
    """(rel, label line, end line) of the routine's real extent: Tree.span's rule, but also
    running through labels that only the extent itself references (a `_Loop` / `_Skip` /
    `_Join` of another spelling).  Tree.span stops at the first label not prefixed with the
    name, so its proof may cover only the entry fragment."""
    rel, i = tree.labels[name]
    lines = tree.files[rel]
    k = i + 1
    while k < len(lines):
        m = LABEL.match(lines[k])
        if m:
            n = m.group(1)
            if not (n.startswith(name + "_") or
                    (refs[n] and all(r == rel and i <= x < k for r, x in refs[n]))):
                break
        k += 1
    return rel, i, k


def extent_body(tree, rel, a, b):
    out = []
    for line in tree.files[rel][a:b]:
        if is_comment_line(line):
            continue
        c = split_comment(line)[0]
        m = CODE_LABEL.match(c)
        if m:
            c = c[m.end():]
        n = norm_code(c)
        if n:
            out.append((0, n, "", ""))
    return out


def extent_report(base, src, dst):
    """Headers written into dst since BASE whose proof covered only the entry fragment:
    the routine's real extent (extent()) runs past Tree.span's end, and the code over the real
    extent differs -- by RAM operands only (ram_pairs), or by more."""
    added = added_comments(base, dst)
    rs, rd = references(src), references(dst)
    st, lines_out = collections.Counter(), []
    for rel in sorted(added):
        new = added[rel][0]
        for k, line in enumerate(dst.files[rel]):
            m = LABEL.match(line)
            if not m:
                continue
            h0 = dst.header(rel, k)
            name = m.group(1)
            if not any(j in new for j in range(h0, k)) or name not in src.labels \
                    or name in src.dups or name in dst.dups:
                continue
            st["headers"] += 1
            _, _, dk = extent(dst, rd, name)
            sr, si, sk = extent(src, rs, name)
            if dk <= dst.span(name)[2] and sk <= src.span(name)[2]:
                continue
            st["extent-longer"] += 1
            a, b = extent_body(src, sr, si, sk), extent_body(dst, rel, k, dk)
            if [x[1] for x in a] == [x[1] for x in b]:
                continue
            if ram_pairs(a, b, src, dst) is not None:
                st["extent-differs-ram-only"] += 1
                kind = "ram-only"
            else:
                st["extent-differs"] += 1
                kind = "differs"
            lines_out.append("%s\t%s\t%s\t%s:%d" % (dst.ver, kind, name, rel, k + 1))
    return st, lines_out


def apply_edits(tree, edits):
    for rel, ops in edits.items():
        lines = tree.files[rel]
        # bottom-up; at one line, the replacement of that line before insertions above it
        for (line, delete), new in sorted(ops.items(), reverse=True):
            lines[line:line + delete] = new
        with open(os.path.join(REPO, rel), "wb") as f:
            f.write("\n".join(lines).encode("latin-1"))


def write_review(path, rows):
    kept = []
    if os.path.exists(path):
        with open(path, newline="", encoding="utf-8") as f:
            for r in csv.DictReader(f, delimiter="\t"):
                if r.get("handport"):
                    kept.append([r[c] for c in REVIEW_COLS])
    done = {(r[0], r[1]) for r in kept}
    rows = kept + [r for r in rows if (r[0], r[1]) not in done]
    rows.sort(key=lambda r: (r[0], r[2], r[1]))
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f, delimiter="\t", lineterminator="\n")
        w.writerow(REVIEW_COLS)
        w.writerows(rows)
    return len(rows), len(kept)


def verify(base):
    """Insertions only: every changed v9/v7 .s file keeps its code lines exactly and keeps
    every comment of `base` in order (a greedy subsequence test, which is exact -- unlike a
    difflib alignment, which can misreport runs of repeated comments as lost)."""
    files = subprocess.run(["git", "diff", "--name-only", base, "--", "v9", "v7"], cwd=REPO,
                           capture_output=True, text=True, check=True).stdout.split()
    bad = 0
    for rel in files:
        if not rel.endswith(".s"):
            continue
        old = subprocess.run(["git", "show", "%s:%s" % (base, rel)], cwd=REPO,
                             capture_output=True, check=True).stdout.decode("latin-1")
        new = open(os.path.join(REPO, rel), "rb").read().decode("latin-1")
        parts = []
        for text in (old, new):
            code, coms = [], []
            for line in text.split("\n"):
                c, com = split_comment(line)
                if c.strip():
                    code.append(c.rstrip())
                if com:
                    coms.append(com.rstrip())
            parts.append((code, coms))
        (oc, ocom), (nc, ncom) = parts
        if oc != nc:
            print("CODE CHANGED: %s" % rel)
            bad += 1
        elif not is_subsequence(ocom, ncom):
            print("COMMENT LOST: %s" % rel)
            bad += 1
    print("%d files checked: %s" % (len(files), "FAIL" if bad else
                                    "PASS (code unchanged, comments insertions only)"))
    return 1 if bad else 0


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--to", nargs="+", default=["v9", "v7"], choices=("v9", "v7"))
    ap.add_argument("--count", action="store_true", help="only measure, change nothing")
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--no-translate", action="store_true",
                    help="refuse every quoted ROM address (with a dry run: calibrates the "
                         "translation against headers already ported by hand)")
    ap.add_argument("--verify", metavar="BASE", help="check the edit since BASE is insertions only")
    ap.add_argument("--audit", metavar="BASE",
                    help="re-examine the comments written since BASE under the current rules "
                         "(v7 RAM numbers, inline address notes, label-restating headers); "
                         "with --apply, fix them")
    ap.add_argument("--check-ram", metavar="BASE",
                    help="flag v7 RAM numbers copied verbatim from v10 into headers written "
                         "since BASE although v7 keeps that variable 156 / 198 bytes lower")
    ap.add_argument("--extent-report", metavar="BASE",
                    help="list headers written since BASE whose proof covered only the entry "
                         "fragment of a routine whose real extent differs")
    ap.add_argument("--report", help="--audit / --check-ram / --extent-report: also write the "
                                     "findings here")
    ap.add_argument("--review", default=os.path.join(
        REPO, "analysis", "header-propagation",
        "review-%s.tsv" % datetime.date.today().isoformat()))
    a = ap.parse_args()
    if a.verify:
        return verify(a.verify)
    global TRANSLATE
    TRANSLATE = not a.no_translate
    if a.no_translate and a.apply:
        ap.error("--no-translate is for dry runs")
    src = Tree("v10")
    if a.extent_report:
        src.load_elf()
        out = ["# target\tkind\tlabel\twhere (propagate_v10_headers.py --extent-report %s)"
               % a.extent_report]
        for v in a.to:
            dst = Tree(v)
            dst.load_elf()
            st, rows = extent_report(a.extent_report, src, dst)
            head = "%s: %s" % (v, ", ".join("%s %d" % kv for kv in sorted(st.items())))
            print(head)
            out += ["# " + head] + rows
        if a.report:
            with open(a.report, "w", encoding="latin-1") as f:
                f.write("\n".join(out) + "\n")
        return
    if a.audit or a.check_ram:
        src.load_elf()
        out = []
        for v in a.to:
            dst = Tree(v)
            dst.load_elf()
            if v == "v7":
                dst.ram = RamMap(src, dst)
            elif a.check_ram:
                continue
            edits, rows, st, report = audit(a.audit or a.check_ram, src, dst, a.apply,
                                            check_only=bool(a.check_ram), review=a.review)
            head = "%s: %s" % (v, ", ".join("%s %d" % kv for kv in sorted(st.items())))
            print(head)
            out += [head] + report
            if a.apply and a.audit:     # the review list is then rewritten by a plain --apply
                apply_edits(dst, edits)
        if a.report:
            with open(a.report, "w", encoding="latin-1") as f:
                f.write("\n".join(out) + "\n")
        return
    if a.count:
        for v in a.to:
            c = count(src, Tree(v))
            print("%-3s v10 labels with a header block: %d; in %s: present %d, with header %d, "
                  "without %d, label absent %d" % (v, c["src_header"], v, c["has"] + c["lacks"],
                                                   c["has"], c["lacks"], c["absent"]))
        return
    src.load_elf()
    allrows = []
    for v in a.to:
        dst = Tree(v)
        dst.load_elf()
        if v == "v7":
            dst.ram = RamMap(src, dst)
        edits, rows, st = plan(src, dst)
        allrows += rows
        print("%s: %s" % (v, ", ".join("%s %d" % kv for kv in sorted(st.items()))))
        if a.apply:
            apply_edits(dst, edits)
    if a.apply or not os.path.exists(a.review):
        n, kept = write_review(a.review, allrows)
        print("review list: %s (%d rows, %d hand-port rows kept)" %
              (os.path.relpath(a.review, REPO), n, kept))


if __name__ == "__main__":
    sys.exit(main())
