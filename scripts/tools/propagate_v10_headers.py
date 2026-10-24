#!/usr/bin/env python3
r"""Carry v10's routine header comments (and in-body comments) to v9 and v7 where the code is the same.

QUESTION ANSWERED / JOB IT DOES
    CLAUDE.md's multi-version sync policy wants an edit made in one KN5000 maincpu tree to reach
    every tree holding the same code.  Documentation passes have mostly worked in v10, so many
    v10 routines carry a `;` header block that the same label in v9/maincpu or v7/maincpu lacks.
    `--count` answers "how many v10 labels with a header block have one in v9 / v7 too?".
    The default run decides, per label, whether v10's comments may be copied, and `--apply`
    copies them.

    The comment is copied only when it is provably about the same code:
      * BODY.  The source from the label to the next column-0 label that does not extend the
        label's name (`Foo` runs through `Foo_Skip3`, `Foo_Return`, ...) must be textually equal
        in both trees after dropping comments, collapsing whitespace and lower-casing hex
        literals.  A `.set NAME, VALUE` line is compared by NAME only: the value is a
        version-specific position, and spelling it in a `.set` is what keeps the code lines
        symbolic.  A raw number that differs in an instruction is NOT tolerated.
      * BYTES.  The ROM bytes of that span, located through each tree's linked ELF, must be
        equal except where a 3-byte run is a ROM address (0xE00000-0xFFFFFF) in both images
        (the same `same_code` rule as scripts/renaming/harmonize_version_labels.py).  Equal
        text over an `.incbin` does not prove equal data; this does.
      * HEADER TEXT.  The header must not quote a maincpu ROM address (0xE00000-0xFFFFFF, which
        moves between builds), must not mention a firmware version (v7/v9/v10), and every
        symbol it names that the source tree defines must be defined in the target too.
      * NO DUPLICATES.  A target label that already has a header keeps it.  When the target's
        header is a subsequence of v10's (v10 extended it), it is replaced by v10's -- an
        insertion-only change.  A longer header line that already occurs elsewhere in the
        target file sends the label to review instead of being written a second time.
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
DUMP = re.compile(r'^\s*;\s*\|.*\|\s*$', re.M)      # `; |..I.3.e.|` byte dumps
WAS = re.compile(r'^;\s*was\b')                      # `; was .ascii "..."`: that tree's history
LINEREF = re.compile(r'\b((?:[\w.-]+/)*[\w.-]+\.s):(\d+)\b')
IDENT = re.compile(r'\b[A-Za-z_][A-Za-z0-9_]{3,}\b')
TRANSLATE = True       # --no-translate: calibration run, every quoted ROM address refused
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


def norm_code(code):
    """Comparable form of one code line (comment already removed); '' for nothing."""
    s = code.strip()
    if not s:
        return ""
    m = re.match(r'^\.set\s+([^,\s]+)\s*,', s)
    if m:
        return ".set " + m.group(1)
    s = HEX.sub(lambda h: h.group(0).lower(), s)
    s = re.sub(r'\s*,\s*', ',', s)
    return re.sub(r'\s+', ' ', s)


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
        self.addr, self.symbols = {}, set()
        for line in out.splitlines():
            parts = line.split()
            if len(parts) != 3:
                continue
            self.symbols.add(parts[2])
            if parts[1].lower() == "t":
                self.addr[parts[2]] = int(parts[0], 16)
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
            if j == i:
                text = text[LABEL.match(text).end():]
                c, com = split_comment(text)
                code.append((j, "%s: %s" % (name, norm_code(c)), com, c))
                continue
            if is_comment_line(text):
                pending.append(j)
                continue
            c, com = split_comment(text)
            n = norm_code(c)
            if not n:
                pending = []          # a blank line ends a comment run
                continue
            if pending:
                before[len(code)] = pending
                pending = []
            code.append((j, n, com, c))
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
    if not TRANSLATE:
        return None
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


def adapt(text, src, dst, translate=True, exact=True):
    """-> (text for the target, reason it cannot be copied or '', detail).  Quoted v10 ROM
    addresses are rewritten to the target's when their correspondence is proved (and the
    number is not one the code spells as a literal, i.e. a constant); anything
    else version-specific (a source line number, a version name, a symbol the target lacks)
    is refused.  With translate=False (the in-body comments) a quoted ROM address is refused
    too: those are mostly inline address notes, which CLAUDE.md forbids, and a constant in the
    0xE00000-0xFFFFFF range (an object handle such as 0xf4fc10) can look like one.  A
    `; |....|` byte dump is copied only when the span's bytes are exactly equal (exact),
    since same_code lets pointer bytes differ."""
    notes = []
    if not exact and DUMP.search(text):
        return text, "dump-of-differing-bytes", DUMP.search(text).group(0).strip()

    def sub_addr(m):
        tok = m.group(0)
        if not translate:
            notes.append(tok)
            return tok
        x = int(tok[2:] if tok[:2] in ("0x", "0X") else tok, 16)
        y = translate_addr(x, src, dst)
        if y is None or (y != x and x in src.literals):
            notes.append(tok)
            return tok
        digits = "%06X" % y if tok[-6:].upper() == tok[-6:] else "%06x" % y
        return tok[:-6] + digits

    out = ROM_ADDR.sub(sub_addr, text)
    if notes:
        return text, "quotes-rom-address", notes[0]
    if LINEREF.search(out):          # line numbers move with every edit; never translated
        return text, "quotes-source-line", LINEREF.search(out).group(0)
    if VERSION.search(out):
        return text, "mentions-version", VERSION.search(out).group(0)
    absent = sorted({w for w in IDENT.findall(out)
                     if w in src.symbols and w not in dst.symbols})
    if absent:
        return text, "names-absent-symbol", " ".join(absent[:6])
    return out, "", ""


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
        if sn != dn:
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
        if a is None or b is None:
            bytes_ok = None
        else:
            bytes_ok = same_code(a, b)
        exact = a is not None and a == b
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
            text, why, what = adapt("\n".join(hdr), src, dst, True, exact)
            new_hdr = text.split("\n")
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
            if why == "done":
                pass
            elif why:
                row[2], row[3] = why, what
                review.append(row)
                st[why] += 1
            else:
                edits[r2][(d0, i2 - d0)] = new_hdr
                st["header-replaced" if dhdr else "header-inserted"] += 1
                if new_hdr != hdr:
                    st["header-addresses-translated"] += 1
        elif hdr:
            st["header-already"] += 1
        # ---- in-body comments (same proof: body text + bytes)
        for k, (sj, _, scom, scode) in enumerate(sb):
            dj, _, dcom, dcode = db[k]
            com, why, _ = (adapt(scom, src, dst, False, exact)
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
                                     False, exact)
                if not why:
                    edits[r2][(dj, 0)] = text.split("\n")
                    st["interior-carried"] += 1
    return edits, review, st


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
