#!/usr/bin/env python3
"""Which WSA1 identifiers spell the letter O with the digit 0, and what do they become?

QUESTION IT ANSWERS
    The owner, 2026-11-06 (register item N-b796721c): "Normalise: rename across the whole tree,
    L0ad->Load, S0und->Sound, C0py->Copy, F0rmat->Format, and so on."  Some SX-WSA1R captions are typed
    with 0x30 for capital O (`DISK L0AD`, `FL0PPY`, `F0RMAT`, `FILE SELECTI0N`), and labels named after
    them copied the zero.  This script decides, for EVERY identifier of the wsa1/ assembly (labels,
    `.set` / `.equ` names, macro names, exports.syms and linker-script symbols) that has a digit 0 next
    to a letter, whether that zero is the letter O -- and says why for each one it leaves alone.

HOW IT DECIDES
    Identifiers are read from code only: `;` comments and string literals are stripped, because a
    quotation of the ROM keeps its zero.  A zero is the letter O when it sits inside one of the WORD
    TOKENS below at a CamelCase boundary (`MeasureC0py_Field`, `L0ad0pti0n`, `Input0utput`).  Each
    token is a word whose zero is a letter -- `C0py` is "Copy" -- and the table shows the ROM caption
    bytes that carry it (searched in the four committed images, 0x30 in the word).  A token that the
    ROM never spells (`C0mbination`, with one zero) is a word the tree derived from such a caption.
    Every other zero beside a letter is KEPT and gets a reason: an address or hex value
    (`sub_F9FD0E`, `Msg0D`), a decimal number beside a word (`Part0Ctrl`, `Range0To100`, `Floppy720K`),
    a CPU register or interrupt (`INT0`, `ADREG0H`, `TREG0`), a float constant's digits (`F64_..em05`),
    or one of the EXPLICIT cases, each with its evidence.
    ★ CROSS-CHECK.  An independent dictionary scan (every 0-for-O reading of a zero that turns the
    CamelCase word containing it into an English word, /usr/share/dict/words plus a few domain words)
    must find nothing outside the token set except the EXPLICIT cases.  The two methods agree, or this
    script fails.
    ★ COLLISIONS.  A new name that is already an identifier of the tree is resolved in OVERRIDES, with
    evidence, never with a number suffix.

RUN (from wsa1/)
    python3 notes/zero-for-o/inventory.py                  # the inventory at the base revision
    python3 notes/zero-for-o/inventory.py --write          # + inventory.md, renames.tsv, kept.tsv, the .sed
    python3 notes/zero-for-o/inventory.py --check          # the WORKING TREE after the rename
    python3 notes/zero-for-o/inventory.py --elf-proof BEFORE AFTER   # two `llvm-nm` listings
    python3 notes/zero-for-o/inventory.py --explain-moved LOG        # a join_maincpu_link.py --proof output
    `--rev REV` reads another revision (default 34bc0c5fe, main when the rename began).
"""
import collections
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
WSA1 = os.path.dirname(os.path.dirname(HERE))
REPO = os.path.dirname(WSA1)
sys.path.insert(0, os.path.dirname(HERE))
from caption_o_for_zero import camel as caption_camel  # noqa: E402

BASE = "34bc0c5fe"
SED = os.path.join(REPO, "scripts", "renaming", "rename_wsa1_zero_for_o.sed")
ROMS = {"prom_a": ("original_ROMs/wsa1_prom_a.ic12", 0xF80000),
        "prom_b": ("original_ROMs/wsa1_prom_b.ic13", 0xF00000),
        "prom_c": ("original_ROMs/wsa1_prom_c.ic28", 0xF98000),
        "prom_d": ("original_ROMs/wsa1_prom_d.bin", 0)}

# token -> its spelling with O.  Each is a word in which the zero is a letter.
TOKENS = {
    "C0py": "Copy", "Vel0city": "Velocity", "S0ng": "Song", "Transp0se": "Transpose", "M0de": "Mode",
    "C0mbinati0n": "Combination", "C0mbination": "Combination", "C0mbi": "Combi", "N0te": "Note",
    "L0ad": "Load", "S0und": "Sound", "T0uch": "Touch", "Lf0": "Lfo", "Gr0up": "Group",
    "P0siti0n": "Position", "T0ne": "Tone", "Mem0ry": "Memory", "Err0r": "Error", "0pti0n": "Option",
    "M0deling": "Modeling", "0utput": "Output", "T0tal": "Total", "M0vement": "Movement",
    "Attenti0n": "Attention", "0verall": "Overall", "C0ntr0ller": "Controller", "Aut0": "Auto",
    "F0rmat": "Format", "Pr0gram": "Program", "Pr0g": "Prog", "Selecti0n": "Selection",
    "C0nfigure": "Configure",
}

# Tokens the ROM never spells: where the tree got them.
TOKEN_NOTE = {
    "C0mbination": "not in the ROMs with one zero: the hand-made L0adSingleC0mbination family, named beside "
                   "L0adSingleS0und; the ROM's word is C0MBINATI0N (prom_b 0xF18ABD)",
}

# A new name that collides with an identifier the tree already has.  Resolved from evidence.
OVERRIDES = {
    # 0xF58A62 (drawn by ScreenEnter_MidiFileSave_Page0) is spelled with O in the ROM and already owns
    # DL_MidiFileSaveFileSelection.  0xF59222 (drawn by ScreenEnter_MidiFileSave_Page1) draws the same
    # title with 0x30 and then "FROM S0NG NUMBER :"; the tree's title rule keeps accumulating the list's
    # own literals while a name collides (notes/prom_a_dl_text_names.py, notes/prom_b_dl_screens_round5.py),
    # which gives this name.
    "DL_MidiFileSaveFileSelecti0n": "DL_MidiFileSaveFileSelectionFromSongNumber",
}

# Zeros beside a letter that a word reading would turn into an O, kept, each with its evidence.
EXPLICIT = [
    (r"INT0", "the CPU's external interrupt INT0 (TMP95C061 INT0 pin / vector), a digit"),
    (r"(?:1440|720)K", "a floppy capacity in kilobytes (720K, 1440K)"),
    (r"SoundRam_BankName_S0|S0WSA1|WsaSoundRamS0", "flash bank S0 of four, \"WSA SOUND RAM S0\" .. \"S3\" (prom_c 0xFE14CB)"),
    (r"^(?:CS0|CR_DMAS0|INTES0)\b", "TMP95C061 SFR / chip-select channel 0"),
    (r"MASK_CLEAR_BITS0_3", "bits 0 to 3"),
    (r"^(?:ADREG0[HL]|PG0REG|PG01CR|TREG0|T01MOD)$", "TMP95C061 SFR: A/D result 0, port G, timer 0"),
    (r"^StepLength_AddTo0E53$", "`AddTo` + RAM address 0x0E53"),
    (r"^F(?:64|32)_", "a floating-point constant's name: digits, `p` for the point, `em05` for e-05"),
    (r"^DLBTable_12k16k20k24k28k32k36k$", "the table's own text \"1.2k\"; \"1.6k\"; \"2.0k\" ..: frequencies, 2.0k is a digit"),
    (r"^SoundConv_Arg0$", "argument 0"),
]

HISTORY = [
    # Dated records that keep the names they were written with.  The .sed above is their translation table.
    "scripts/renaming/rename_wsa1_",          # every earlier WSA1 rename script (except this one)
    "wsa1/notes/naming-pilot-2026-10-06/",
    "notes/lanes/",
    "notes/branch-symbolization-2026-09-25/",
    "notes/data-census-2026-09-02/",
    "notes/wsa1-dl-drawers-2026-10-03/renames.txt",
    "wsa1/notes/prom_a_preservation_check.py",     # declarations: old -> name as declared then
    "wsa1/notes/prom_b_names_session_53b889a2.py",
    "wsa1/notes/zero-for-o/",
    "notes/open4-kn5000-b/naming/issue-comments.json",      # issue comments as posted
    "notes/open6-kn5000-d/wsa1/issue-comment-kn5000-wxn.txt",
    ".beads/issues.jsonl",          # the issue record; kn5000-wxn gets a comment instead (README)
    "notes/open-items/",            # the integrator's register: lanes do not edit it
]

# Where names are quoted outside the code: prose, Python name tables, generated notes.  The words found here at
# the base revision that hold a token and are NOT code identifiers (screen-name morphemes such as `DiskL0adFile`,
# partial names such as `DL_*F0rmat*`) get word rules of their own, in the .sed's second block.
SCOPE = ("wsa1/", "notes/open6-kn5000-d/", "notes/open4-kn5000-b/", "notes/wsa1-dl-drawers-2026-10-03/",
         "scripts/tools/name_wsa1_ram.py")

ID = re.compile(rb"(?<![0-9A-Za-z_.$])[A-Za-z_.$][A-Za-z0-9_.$]*")
STR = re.compile(rb'"(?:[^"\\]|\\.)*"')


# ------------------------------------------------------------------ reading the tree
def tree_files(rev):
    """{path: bytes} of wsa1/'s assembly-side files, at `rev` or (rev None) in the working tree."""
    want = lambda p: (p.startswith("wsa1/") and "original_ROMs" not in p
                      and (p.endswith((".s", ".inc", ".ld", ".syms"))))
    if rev is None:
        names = subprocess.run(["git", "-C", REPO, "ls-files", "wsa1"], capture_output=True,
                               check=True).stdout.decode().split("\n")
        return {p: open(os.path.join(REPO, p), "rb").read() for p in names if want(p)
                and os.path.exists(os.path.join(REPO, p))}
    names = subprocess.run(["git", "-C", REPO, "ls-tree", "-r", "--name-only", rev, "wsa1"],
                           capture_output=True, check=True).stdout.decode().split("\n")
    names = [p for p in names if want(p)]
    out = {}
    proc = subprocess.run(["git", "-C", REPO, "cat-file", "--batch"], capture_output=True, check=True,
                          input=b"".join(b"%s:%s\n" % (rev.encode(), p.encode()) for p in names)).stdout
    i = 0
    for p in names:
        hdr_end = proc.index(b"\n", i)
        size = int(proc[i:hdr_end].split()[2])
        out[p] = proc[hdr_end + 1:hdr_end + 1 + size]
        i = hdr_end + 1 + size + 1
    return out


def code_part(line, kind):
    if kind in (".syms", ".ld"):
        s = line.split(b"#")[0]
        return re.sub(rb"/\*.*?\*/", b"", s)
    s = STR.sub(b" ", line)
    s = re.sub(rb"'.'", b" ", s)
    return s.split(b";")[0].split(b"//")[0]


def identifiers(files):
    """Counter of identifiers in code, and {identifier: set of files}."""
    ids, where = collections.Counter(), collections.defaultdict(set)
    for p, b in files.items():
        kind = os.path.splitext(p)[1]
        for ln in b.split(b"\n"):
            for m in ID.finditer(code_part(ln, kind)):
                t = m.group().decode("latin-1")
                ids[t] += 1
                where[t].add(p)
    return ids, where


LETTER_ZERO = re.compile(r"[A-Za-z]0|0[A-Za-z]")


# ------------------------------------------------------------------ deciding
def token_spans(name):
    """[(start, end, token)] of TOKENS inside `name` at CamelCase boundaries, longest first."""
    spans, used = [], set()
    for tok in sorted(TOKENS, key=len, reverse=True):
        for m in re.finditer(re.escape(tok), name):
            a, b = m.span()
            if used & set(range(a, b)):
                continue
            prev = name[a - 1] if a else ""
            nxt = name[b] if b < len(name) else ""
            lead_ok = (not prev or not prev.isalpha() or (prev.islower() and (tok[0].isupper() or tok[0] == "0"))
                       or (prev.isupper() and tok[0] == "0"))
            tail_ok = not nxt or not nxt.isalpha() or nxt.isupper()
            if lead_ok and tail_ok:
                spans.append((a, b, tok))
                used |= set(range(a, b))
    return sorted(spans)


def renamed(name):
    if name in OVERRIDES:
        return OVERRIDES[name]
    out, last = [], 0
    for a, b, tok in token_spans(name):
        out += [name[last:a], TOKENS[tok]]
        last = b
    return "".join(out) + name[last:]


SFR_NAMES = None


def sfr_names(files):
    global SFR_NAMES
    if SFR_NAMES is None:
        b = files.get("wsa1/include/tmp95c061_sfr.inc", b"")
        SFR_NAMES = {m.group(1).decode() for m in re.finditer(rb"^\s*\.(?:equ|set)\s+(\w+)", b, re.M)}
    return SFR_NAMES


def keep_reason(name, files):
    for pat, why in EXPLICIT:
        if re.search(pat, name):
            return "EXPLICIT", why
    if name in sfr_names(files):
        return "SFR", "defined in include/tmp95c061_sfr.inc"
    reasons = set()
    for m in re.finditer("0", name):
        i = m.start()
        prev = name[i - 1] if i else ""
        nxt = name[i + 1] if i + 1 < len(name) else ""
        if not (prev.isalpha() or nxt.isalpha()):
            continue
        # the maximal uppercase-hex run around this zero
        a = i
        while a and name[a - 1] in "0123456789ABCDEF":
            a -= 1
        b = i + 1
        while b < len(name) and name[b] in "0123456789ABCDEF":
            b += 1
        lo_a = i
        while lo_a and name[lo_a - 1] in "0123456789abcdef":
            lo_a -= 1
        lo_b = i + 1
        while lo_b < len(name) and name[lo_b] in "0123456789abcdef":
            lo_b += 1
        if b - a >= 2:
            reasons.add("HEX")
        elif lo_b - lo_a >= 3 and (not lo_a or name[lo_a - 1] in "x_."):
            reasons.add("HEX")
        elif prev.islower() and re.match(r"(?:to|or)\d", name[i + 1:i + 4]):
            reasons.add("NUMBER")       # Bit0to7, Parts0to15, Is0or2or4: a range or list of numbers
        elif (prev.isdigit() or nxt.isdigit() or not prev.isalpha() or not nxt.isalpha()
              or (prev.islower() and nxt.isupper()) or (prev.isupper() and nxt.isupper())):
            reasons.add("NUMBER")
        else:
            reasons.add("UNDECIDED")
    if not reasons:
        return "NUMBER", ""
    if "UNDECIDED" in reasons:
        return "UNDECIDED", ""
    return "+".join(sorted(reasons)), ""


REASON_TEXT = {
    "HEX": "the zero is a digit of an address or hex value (sub_F9FD0E, Msg0D, Rec0E3E, x0060f300)",
    "NUMBER": "the zero is a decimal number beside a word: an index, count or value (Part0Ctrl, Range0To100)",
    "HEX+NUMBER": "both: a hex value and a decimal number",
    "SFR": "a TMP95C061 special-function register",
}


# ------------------------------------------------------------------ the dictionary cross-check
def dictionary():
    try:
        words = {w.strip().lower() for w in open("/usr/share/dict/words", encoding="utf-8", errors="ignore")
                 if "'" not in w}
    except OSError:
        return None
    return words | {"combi", "prog", "midi", "lfo", "lfos", "auto", "mono", "demo", "solo", "tempo"}


def dict_hits(name, words):
    """True when some 0 -> o/O reading of a zero beside a letter turns the CamelCase word that holds it
    into a dictionary word (3+ letters, or a common two-letter one), and that word is not plain hex."""
    two = {"on", "of", "to", "no", "ok", "go", "do", "so", "or"}
    for seg in re.split(r"[_.$]", name):
        zs = [i for i, c in enumerate(seg) if c == "0" and ((i and seg[i - 1].isalpha())
                                                          or (i + 1 < len(seg) and seg[i + 1].isalpha()))]
        for z in zs:
            for rep in "oO":
                r = seg[:z] + rep + seg[z + 1:]
                for w in re.finditer(r"[A-Z]+(?![a-z])|[A-Z]?[a-z]+", r):
                    a, b = w.span()
                    if not a <= z < b:
                        continue
                    src, wd = seg[a:b], w.group().lower()
                    if all(c in "0123456789abcdefABCDEF" for c in src) and (len(src) <= 4 or src.upper() == src):
                        continue
                    other = [k for k in range(a, b) if k != z and seg[k] == "0"]
                    if other:
                        wd = "".join("o" if (a + k) in other else ch for k, ch in enumerate(wd))
                    if (len(wd) >= 3 and wd in words) or wd in two:
                        return True
    return False


def scope_texts(rev):
    """{path: text} of the SCOPE files (outside HISTORY) that hold a token, at `rev` or in the working tree."""
    toks = sorted(TOKENS, key=len, reverse=True)
    cmd = ["git", "-C", REPO, "grep", "-l", "-a", "-F"] + sum([["-e", t] for t in toks], [])
    cmd += ([rev] if rev else []) + ["--"] + list(SCOPE)
    paths = [l.split(":", 1)[1] if rev else l
             for l in subprocess.run(cmd, capture_output=True).stdout.decode().split("\n") if l]
    paths = [q for q in paths if not any(q.startswith(h) for h in HISTORY) and "original_ROMs" not in q]
    out = {}
    for q in paths:
        if rev:
            b = subprocess.run(["git", "-C", REPO, "show", "%s:%s" % (rev, q)], capture_output=True).stdout
        else:
            b = open(os.path.join(REPO, q), "rb").read()
        out[q] = b.decode("latin-1")
    return out


WORD = re.compile(r"[A-Za-z0-9_]+")


def prose_words(rev, ren):
    """{word: new} for every word of the SCOPE texts that holds a token and is not a code identifier."""
    out = {}
    for q, t in scope_texts(rev).items():
        for m in WORD.finditer(t):
            w = m.group()
            if w not in ren and token_spans(w):
                out[w] = renamed(w)
    return out


def unpaired(texts, olds):
    """[(path, line number, word)] where an old spelling stands without its new spelling on the same line."""
    bad = []
    for q, t in texts.items():
        for i, ln in enumerate(t.split("\n")):
            for m in WORD.finditer(ln):
                w = m.group()
                if (w in olds or token_spans(w)) and renamed(olds.get(w, w)) not in ln and olds.get(w) not in ln:
                    bad.append((q, i + 1, w))
    return bad


# ------------------------------------------------------------------ the inventory
def inventory(rev):
    files = tree_files(rev)
    ids, where = identifiers(files)
    cand = sorted(t for t in ids if LETTER_ZERO.search(t) and not re.fullmatch(r"0x[0-9a-fA-F]+", t))
    ren, kept = {}, {}
    for t in cand:
        if token_spans(t) or t in OVERRIDES:
            ren[t] = renamed(t)
        else:
            kept[t] = keep_reason(t, files)
    return files, ids, where, cand, ren, kept


def rom_hits(tok):
    up = tok.upper().encode()
    out = []
    for tag, (path, base) in ROMS.items():
        data = open(os.path.join(WSA1, path), "rb").read()
        for m in re.finditer(re.escape(up), data):
            out.append("%s 0x%06X" % (tag, base + m.start()))
    return out


def problems(ids, cand, ren, kept):
    bad = []
    new_count = collections.Counter(ren.values())
    for o, n in sorted(ren.items()):
        if new_count[n] > 1:
            bad.append("two old names become %s" % n)
        if n in ids and n not in ren:
            bad.append("COLLISION %s -> %s, which the tree already has" % (o, n))
        if "0" in n and LETTER_ZERO.search(n) and token_spans(n):
            bad.append("%s still holds a token after renaming: %s" % (o, n))
    for t, (r, _w) in kept.items():
        if r == "UNDECIDED":
            bad.append("UNDECIDED %s" % t)
    words = dictionary()
    if words is None:
        print("  (no /usr/share/dict/words: the dictionary cross-check is skipped)")
    else:
        for t in cand:
            if t not in ren and dict_hits(t, words) and kept[t][0] != "EXPLICIT":
                bad.append("the dictionary reads an O in %s, which is neither renamed nor EXPLICIT" % t)
    return bad


def names_in_literals(files, names):
    """[(path, line)] where one of `names` sits inside a string literal of code (before any `;`)."""
    if not names:
        return []
    rx = re.compile(rb"\b(" + b"|".join(re.escape(n.encode()) for n in sorted(names, key=len, reverse=True)) + rb")\b")
    out = []
    for p, b in files.items():
        if not p.endswith((".s", ".inc")):
            continue
        for ln in b.split(b"\n"):
            for m in STR.finditer(ln):
                if b";" in STR.sub(b"", ln[:m.start()]):
                    break
                if rx.search(m.group()):
                    out.append((p, ln[:100].decode("latin-1")))
    return out


def md_table(rows, head):
    fmt = lambda r: "| " + " | ".join(str(c).ljust(w[i]) for i, c in enumerate(r)) + " |"
    rows = [tuple(str(c).replace("|", "\\|") for c in r) for r in rows]
    head = tuple(str(c).replace("|", "\\|") for c in head)
    w = [max(len(str(r[i])) for r in rows + [head]) for i in range(len(head))]
    return "\n".join([fmt(head), "|" + "|".join("-" * (x + 2) for x in w) + "|"] + [fmt(r) for r in rows])


DEF = re.compile(rb"^\s*([A-Za-z_.$][\w.$]*):|^\s*\.(?:set|equ|macro)\s+([A-Za-z_.$][\w.$]*)")


def definitions(files):
    """{name: the file that defines it} -- a label, `.set` / `.equ` or `.macro`."""
    out = {}
    for p, b in sorted(files.items()):
        for ln in b.split(b"\n"):
            m = DEF.match(ln)
            if m:
                out.setdefault((m.group(1) or m.group(2)).decode("latin-1"), p)
    return out


def write(rev, files, ids, where, cand, ren, kept):
    defs = definitions(files)
    tok_use = collections.Counter()
    for o in ren:
        for _a, _b, tok in token_spans(o):
            tok_use[tok] += 1
    rows = []
    for tok in sorted(TOKENS, key=lambda t: (-tok_use[t], t)):
        hits = rom_hits(tok)
        ev = ("%d in the ROMs, first %s" % (len(hits), hits[0])) if hits else TOKEN_NOTE[tok]
        rows.append(("`%s`" % tok, "`%s`" % TOKENS[tok], "`%s`" % tok.upper(), ev, tok_use[tok]))
    by_reason = collections.Counter(r for r, _w in kept.values())
    strict = sorted(t for t in kept if re.search(r"[A-Za-z]0[A-Za-z]", t))
    with open(os.path.join(HERE, "inventory.md"), "w") as f:
        f.write("# WSA1 identifiers with a digit 0 beside a letter (generated)\n\n")
        f.write("Generated by `python3 notes/zero-for-o/inventory.py --write` (from `wsa1/`) at revision `%s`.\n"
                "Do not edit by hand.  The README beside it says what the script answers.\n\n" % rev)
        f.write("- identifiers in code with a 0 beside a letter: %d\n" % len(cand))
        by_img = collections.Counter(defs.get(o, "?").split("/")[1] for o in ren)
        f.write("- renamed (the zero is the letter O): %d, in `renames.tsv` and "
                "`scripts/renaming/rename_wsa1_zero_for_o.sed`; defined in %s\n"
                % (len(ren), ", ".join("%s %d" % kv for kv in sorted(by_img.items()))))
        f.write("- kept: %d, of which %d have a 0 BETWEEN two letters; every one of those is in `kept.tsv`"
                " with its reason\n\n" % (len(kept), len(strict)))
        f.write("## The word tokens (each renamed identifier holds one or more)\n\n")
        f.write(md_table(rows, ("token", "becomes", "ROM bytes searched", "evidence", "names")) + "\n\n")
        f.write("## Collisions resolved\n\n")
        for o, n in OVERRIDES.items():
            f.write("- `%s` -> `%s`: the plain reading is the name of the O-spelled list at 0xF58A62; "
                    "see OVERRIDES in inventory.py for the evidence.\n" % (o, n))
        f.write("\n## Kept, by reason\n\n")
        krows = [(r, by_reason[r], REASON_TEXT.get(r, "see kept.tsv")) for r in sorted(by_reason)]
        f.write(md_table(krows, ("reason", "identifiers", "meaning")) + "\n\n")
        erows = []
        for pat, why in EXPLICIT:
            names = sorted(t for t, (r, w) in kept.items() if r == "EXPLICIT" and w == why)
            erows.append(("`%s`" % pat, len(names), why))
        f.write("The EXPLICIT cases (a word reading would see an O; the evidence says digit):\n\n")
        f.write(md_table(erows, ("pattern", "identifiers", "evidence")) + "\n")
    defs = definitions(files)
    with open(os.path.join(HERE, "renames.tsv"), "w") as f:
        f.write("old\tnew\ttokens\tdefined in\n")
        for o in sorted(ren):
            toks = " ".join(t for _a, _b, t in token_spans(o)) or "OVERRIDE"
            deff = defs.get(o, "")
            f.write("%s\t%s\t%s\t%s\n" % (o, ren[o], toks, deff))
    with open(os.path.join(HERE, "kept.tsv"), "w") as f:
        f.write("identifier\treason\tdetail\n")
        for t in strict:
            r, w = kept[t]
            f.write("%s\t%s\t%s\n" % (t, r, w or REASON_TEXT.get(r, "")))
    with open(SED, "w") as f:
        f.write("# Generated by wsa1/notes/zero-for-o/inventory.py --write at %s: WSA1 names that spelled the\n"
                "# letter O with the digit 0 (owner decision 2026-11-06, register item N-b796721c).\n"
                "# One rule per old name, word-bounded.  Apply with `LC_ALL=C sed -i -f` (the .s files hold\n"
                "# raw non-UTF-8 bytes).  String literals and quotations of the ROM keep their zeros: no\n"
                "# old name occurs inside one (inventory.py --check).\n" % rev)
        for o in sorted(ren):
            f.write("s/\\b%s\\b/%s/g\n" % (o, ren[o]))
        pw = prose_words(rev, ren)
        f.write("# --- block 2: %d words that are not code identifiers but name things -- screen-name morphemes\n"
                "# (`DiskL0adFile`), the parts of wildcard names (`DL_*F0rmat*`), Python name tables.  Found in\n"
                "# the prose of %s at %s.\n" % (len(pw), ", ".join(SCOPE), rev))
        for o in sorted(pw):
            f.write("s/\\b%s\\b/%s/g\n" % (o, pw[o]))
    with open(os.path.join(HERE, "prose_words.tsv"), "w") as f:
        f.write("old\tnew\n")
        for o in sorted(pw):
            f.write("%s\t%s\n" % (o, pw[o]))
    decl = ['"""The 0-for-O renames of 2026-11-06 (lane open9/zero-for-o, register item N-b796721c), declared for',
            'notes/prom_a_preservation_check.py and notes/prom_b_naming_preservation.py, as each earlier pass declares',
            'its own.  Generated by notes/zero-for-o/inventory.py --write at %s; do not edit.' % rev,
            '',
            'Applied by scripts/renaming/rename_wsa1_zero_for_o.sed.  The list is STATIC, written out here, so it',
            'outlives the sed file\'s application (the rule notes/prom_a_preservation_check.py states).  RENAMES are',
            'code identifiers (old, new; the comment names the file that defines it); WORDS are the screen-name',
            'morphemes and partial names of the .sed\'s block 2, which occur only in comments and prose.',
            '"""',
            'RENAMES = [']
    decl += ['    ("%s", "%s"),   # %s' % (o, ren[o], defs.get(o, "").replace("wsa1/", "", 1)) for o in sorted(ren)]
    decl += [']', '', 'WORDS = [']
    decl += ['    ("%s", "%s"),' % (o, pw[o]) for o in sorted(pw)]
    decl += [']']
    with open(os.path.join(os.path.dirname(HERE), "prom_ab_names_zero_for_o.py"), "w") as f:
        f.write("\n".join(decl) + "\n")
    print("wrote inventory.md, renames.tsv, kept.tsv, prose_words.tsv, notes/prom_ab_names_zero_for_o.py and %s"
          % os.path.relpath(SED, REPO))


# ------------------------------------------------------------------ after the rename
def old_names():
    rows = [l.split("\t") for l in open(os.path.join(HERE, "renames.tsv")).read().split("\n")[1:] if l]
    return {r[0]: r[1] for r in rows}


def check():
    bad = []
    ren0 = old_names()
    files, ids, where, cand, ren, kept = inventory(None)
    print("working tree: %d identifiers with a 0 beside a letter, %d still hold an O-token, %d kept"
          % (len(cand), len(ren), len(kept)))
    bad += ["still O-spelled: %s" % t for t in ren]
    bad += problems(ids, cand, {}, kept)
    defined = set(definitions(files))
    for o, n in ren0.items():
        if n not in defined:
            bad.append("new name %s is not defined" % n)
        if o in ids:
            bad.append("old name %s is still in the code" % o)
    # every tracked file outside HISTORY: an old name (or a token word) may stand only beside its new spelling
    names = sorted(ren0, key=len, reverse=True)
    grep = subprocess.run(["git", "-C", REPO, "grep", "-l", "-a", "-w", "-F"] + sum([["-e", n] for n in names], [])
                          + ["--", "."], capture_output=True).stdout.decode().split("\n")
    texts = scope_texts(None)
    for q in grep:
        if q and q not in texts and not any(q.startswith(h) for h in HISTORY):
            texts[q] = open(os.path.join(REPO, q), "rb").read().decode("latin-1")
    pw = {r[0]: r[1] for r in (l.split("\t") for l in open(os.path.join(HERE, "prose_words.tsv")).read().split("\n")[1:] if l)}
    olds = dict(ren0, **pw)
    for q, n, w in unpaired(texts, olds):
        bad.append("%s:%d: %s stands without its new spelling" % (q, n, w))
    # no old name sits inside a string literal of the assembly (quotations keep their zeros)
    # -- every file that defines a caption typed with 0x30 says so (the ring_put_block.s note is the model)
    nfiles = 0
    for q, b in sorted(files.items()):
        if q.endswith(".s") and caption_zero_words(b.decode("latin-1")):
            nfiles += 1
            if MARKER not in b:
                bad.append("%s defines captions typed with 0x30 but has no note saying so" % q)
    print("source files that define a caption typed with 0x30: %d, each with the note" % nfiles)
    # -- the generator agrees: a --dl-names label re-derived from its literals with the O rule
    agree, total, misses = dl_names_agree(files)
    print("DL_ labels with a --dl-names Evidence header: %d; the O rule re-derives %d of them"
          % (total, agree))
    for m in misses:
        print("  not re-derived (named by a longer rule or by hand): %s" % m)
    print("FAILURES: %d" % len(bad))
    for b in bad[:60]:
        print("  FAIL " + b)
    return 1 if bad else 0


CAPTION_LIT = re.compile(r'(?:text=|\.ascii\s+|\.asciz\s+|\.string\s+)"((?:[^"\\]|\\.)*)"')
NOT_CAPTION = {"S0", "WA0", "rmat0", "0k"}   # bank S0 (EXPLICIT); the "WA0" bulk-dump signature; a fragment; 2.0k
MARKER = b"spell capital O with character code 0x30"


def caption_zero_words(text):
    """The caption words of one source file whose 0x30 stands for O (caption_o_for_zero's rule)."""
    from caption_o_for_zero import o_for_zero
    hits = []
    for ln in text.split("\n"):
        for m in CAPTION_LIT.finditer(ln):
            if ";" in CAPTION_LIT.sub("", ln[:m.start()]):
                break
            t = decode_lit(m.group(1))
            for w in re.split(r"[^A-Za-z0-9.]+", t):
                for x in re.split(r"[^A-Za-z0-9]+", w):
                    if x and x not in NOT_CAPTION and o_for_zero(w) != w and o_for_zero(x) != x and x not in hits:
                        hits.append(x)
    return hits


def decode_lit(s):
    return re.sub(r"\\([0-7]{1,3}|.)", " ", s)


def dl_names_agree(files):
    total = agree = 0
    misses = []
    for p, b in sorted(files.items()):
        if not p.startswith("wsa1/prom_b/") or not p.endswith(".s"):
            continue
        L = b.decode("latin-1").split("\n")
        for i, l in enumerate(L):
            m = re.match(r"^(DL_\w+):", l)
            if not m:
                continue
            above = "\n".join(L[max(0, i - 12):i])
            if "--dl-names" not in above or ("; %s -- the display list" % m.group(1)) not in above:
                continue
            lits = []
            for k in range(i + 1, len(L)):
                if re.match(r"^[A-Za-z_.][\w.]*:", L[k]) or L[k].startswith("; ---"):
                    break
                for t in re.findall(r'(?:text=|\.ascii\s+)"((?:[^"\\]|\\.)*)"', L[k]):
                    t = decode_lit(t).strip()
                    if re.search(r"[A-Za-z]{2}", t):
                        lits.append(t)
            total += 1
            cands, s = [], ""
            for t in lits:
                s += caption_camel(t)
                cands.append("DL_" + s[:60])
            if m.group(1) in cands or any(m.group(1) == "DL_" + c[3:43] for c in cands):
                agree += 1
            else:
                misses.append("%s (%s)" % (m.group(1), " / ".join(lits)[:60]))
    return agree, total, misses


def elf_proof(before, after):
    """Every symbol of BEFORE is in AFTER at the same value, under the rename map, and nothing else moved."""
    ren = old_names()

    def load(p):
        out = {}
        for ln in open(p):
            f = ln.split()
            if len(f) == 3:
                out[f[2]] = (f[0], f[1])
        return out
    b, a = load(before), load(after)
    bad = 0
    mapped = 0
    for n, v in b.items():
        m = ren.get(n, n)
        mapped += m != n
        if a.get(m) != v:
            bad += 1
            print("  MOVED %s -> %s: %s vs %s" % (n, m, v, a.get(m)))
    extra = set(a) - {ren.get(n, n) for n in b}
    for n in sorted(extra):
        bad += 1
        print("  NEW   %s" % n)
    print("symbols: %d before, %d after, %d renamed, every other name and every value unchanged: %s"
          % (len(b), len(a), mapped, "yes" if not bad else "NO"))
    print("FAILURES: %d" % bad)
    return 1 if bad else 0


def explain_moved(log):
    """scripts/tools/join_maincpu_link.py --proof REV prints `MOVED <name>: equate <value>` for every name of REV's
    equate blocks that the joined ELF lacks.  Each one must be a renamed name whose NEW name the ELF holds at that
    very value -- or one of the names the base revision's own run already reported (BASE_MOVED)."""
    ren = old_names()
    nm = os.path.expanduser("~/compartilhado/llvm-project/build/bin/llvm-nm")
    out = subprocess.run([nm, os.path.join(WSA1, "rebuilt_ROMs", "wsa1_maincpu.llvm.elf")],
                         capture_output=True, text=True, check=True).stdout
    val = {f[2]: int(f[0], 16) for f in (l.split() for l in out.split("\n")) if len(f) == 3}
    moved = re.findall(r"MOVED (\S+): equate (0x[0-9a-fA-F]+)", open(log).read())
    pre = [n for n, _v in moved if n in BASE_MOVED]
    bad = [n for n, v in moved if n not in BASE_MOVED and not (n in ren and val.get(ren[n]) == int(v, 16))]
    print("MOVED %d: %d already moved at the base, %d renamed and found under the new name at the same value, "
          "%d unexplained %s" % (len(moved), len(pre), len(moved) - len(pre) - len(bad), len(bad), bad[:10]))
    print("FAILURES: %d" % len(bad))
    return 1 if bad else 0


# the two names `--proof 130735749` already reported at 34bc0c5fe (renamed by an earlier lane)
BASE_MOVED = {"T_MidiFileSave_Page5_LcdKeyRow3", "MidiFileSave_Page5_LcdKeyRow3"}


def main():
    argv = sys.argv[1:]
    if "--explain-moved" in argv:
        return explain_moved(argv[argv.index("--explain-moved") + 1])
    if "--elf-proof" in argv:
        i = argv.index("--elf-proof")
        return elf_proof(argv[i + 1], argv[i + 2])
    if "--check" in argv:
        return check()
    rev = argv[argv.index("--rev") + 1] if "--rev" in argv else BASE
    files, ids, where, cand, ren, kept = inventory(rev)
    print("revision %s: %d identifiers with a 0 beside a letter; %d renamed, %d kept"
          % (rev, len(cand), len(ren), len(kept)))
    for r, n in sorted(collections.Counter(r for r, _w in kept.values()).items()):
        print("  kept %-12s %5d" % (r, n))
    bad = problems(ids, cand, ren, kept)
    bad += ["an old name inside a string literal: %s: %s" % pl for pl in names_in_literals(files, list(ren))]
    for x in bad[:60]:
        print("  FAIL " + x)
    print("FAILURES: %d" % len(bad))
    if "--write" in argv and not bad:
        write(rev, files, ids, where, cand, ren, kept)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
