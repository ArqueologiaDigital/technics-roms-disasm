#!/usr/bin/env python3
"""collect_open_items.py -- the register of every open item in this repository.

QUESTION IT ANSWERS
  "What is still open in technics-roms-disasm, where is it written down, and what would close it?"
  Set up 2026-10-31 (lane open3/register) for the owner's goal: "work on all open items until nothing else
  is left open".

WHAT IT COLLECTS (the four sources)
  N  notes: every item under an open-items heading ("Open", "Open questions", "Open items", "Open work",
     "Left open", "Still open", "What remains (open)", "Still unknown", "Follow-up(s)", "TODO", ...) in
       notes/**/README.md, kn7000/notes/**/*.md, kn6000/notes/**/*.md, kn2400/notes/**/*.md,
       kn6500/notes/**/*.md, hdsx3/notes/**/*.md, hdsx3/README.md, wsa1/notes/**/*.md,
       the per-tree READMEs (<dir>/README.md and <dir>/<sub>/README.md, notes/ excluded),
       and the rows of the repo-root CLAUDE.md "Known Disputed Interpretations" table and its
       "Still investigating" checklist.
     An item is a top-level list item or a table body row of the section; a section with neither gives one
     item per sub-heading, and a section with neither gives one item per paragraph.  An item the note itself
     marks as settled (struck through with ~~, or "Resolved" / "RESOLVED" / "CLOSED" / "(resolved by" /
     "[x]") is collected with `inline_resolved` set.
  I  .beads/issues.jsonl: every issue whose status is not "closed" (and the ones this register closed, kept
     under their id so that the closure stays visible: they are listed with their close_reason).
  T  `; TODO` and `TODO(port)` markers in the git-tracked sources (.s .inc .S .c .h .ld), counted per tree and
     grouped by their first words (`TODO(port)`, `TODO: not named`, ...), not listed one by one.
  O  `census: opaque -- unknown-dump` (and `-- code`) declarations, from
     `scripts/analysis/data_incbin_census.py --list opaque`, counted per tree and grouped by their reason
     with the numbers taken out.

  Every item gets a stable id: N-<8 hex of sha1(file, item key)>, the issue id, T-<tree>-<group>,
  O-<tree>-<n>.  The item key is the item's text with markdown and any resolution clause removed and cut
  to 100 characters, so that marking an item resolved in its note does not change its id.

TRIAGE
  notes/open-items/triage.json maps id -> {status, area, title, plan, blocker, size, owner, evidence}.
  status is one of RESOLVED / ACTIONABLE / BLOCKED (see README.md).  The script joins the collected items
  with it; an item with no triage row is UNTRIAGED, a triage row whose item is no longer collected is
  ORPHAN (it is still written to the register, from the triage row, when it is RESOLVED).  A triage row
  with a "source" of its own (id L-...) is an item no source above holds -- an item a lane brief names, or
  text outside an open-items heading -- and is written to the register as it is.

OUTPUT
  notes/open-items/REGISTER.md (with --write), the counts on stdout.  --check exits 1 on any UNTRIAGED item or
  non-RESOLVED ORPHAN.  --dump FILE writes the collected items as JSON (for triage work).

USAGE
  python3 notes/open-items/collect_open_items.py                 # counts only
  python3 notes/open-items/collect_open_items.py --write         # regenerate REGISTER.md
  python3 notes/open-items/collect_open_items.py --check         # what is not triaged yet
  python3 notes/open-items/collect_open_items.py --dump items.json --no-census
  --no-census skips source O (the census takes about a minute); the O rows are then read from the
  previous REGISTER.md's cache, notes/open-items/opaque-groups.json.
"""
import argparse, hashlib, json, re, subprocess, sys
from collections import Counter, OrderedDict, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HERE = ROOT / "notes" / "open-items"
TRIAGE = HERE / "triage.json"
REGISTER = HERE / "REGISTER.md"
OPAQUE_CACHE = HERE / "opaque-groups.json"

STATUSES = ["RESOLVED", "ACTIONABLE", "BLOCKED"]
AREAS = ["KN5000", "HD-AE5000", "WSA1R", "KN7000", "MN10300 siblings", "floppies", "media", "tooling",
         "MAME/emulation", "homebrew", "documentation"]

# ---------------------------------------------------------------- source N: notes
OPEN_HEADING = re.compile(
    r"(?i)(^(\d+\.\s*)?open\b|\bopen (questions?|items?|work|leads?|discrepancy|disagreement)\b|"
    r"\bleft open\b|\bstill open\b|\bremains? open\b|\bwhat (is )?(still )?remains?\b|\bremains? unknown\b|"
    r"\bstill unknown\b|\bremain unexplained\b|\bfollow-?ups?\b|\btodo\b|\bA\d OPEN\b|\bcount still open\b|"
    r"\bopen\)?$)")
# sections that are open-item lists although their heading does not say so: (file, heading prefix)
EXTRA_SECTIONS = [
    ("wsa1/notes/WSA1-EMULATION-DISASM-GAPS.md", "The list"),
    ("wsa1/notes/WSA1-EMULATION-DISASM-GAPS.md", "Gaps I could not frame sharply"),
    ("wsa1/notes/WSA1-EMULATION-DISASM-GAPS.md", "Appendix: gaps that are MAME's"),
    ("notes/NEXT-STEPS-2026-10-17.md", "Pending work"),
]
NOT_OPEN_HEADING = re.compile(r"(?i)\b(this closes|this answers|answers a|settles|question closed|how to open|"
                              r"resolved\b|closed\b)")
RESOLVED_MARK = re.compile(r"(~~|\bresolved\b|\bRESOLVED\b|\bCLOSED\b|\bclosed by\b|\[x\]|\bDONE\b|"
                           r"\bsettled\b|\bfixed\b)", re.I)
RESOLVED_LEAD = re.compile(r"^\s*(~~|\[x\]|\(?resolved|\(?RESOLVED|CLOSED|DONE\b)", re.I)


def note_files():
    pats = ["notes/**/README.md", "kn7000/notes/**/*.md", "kn6000/notes/**/*.md", "kn2400/notes/**/*.md",
            "kn6500/notes/**/*.md", "hdsx3/notes/**/*.md", "wsa1/notes/**/*.md", "*/README.md",
            "*/*/README.md"]
    tracked = set(subprocess.run(["git", "ls-files"], cwd=ROOT, capture_output=True, text=True).stdout.split("\n"))
    out = set()
    for p in pats:
        for f in ROOT.glob(p):
            rel = f.relative_to(ROOT).as_posix()
            if rel in tracked:
                out.add(rel)
    out.discard("notes/open-items/README.md")
    out.update(f for f, _ in EXTRA_SECTIONS)
    return sorted(out)


def strip_md(s):
    s = re.sub(r"`([^`]*)`", r"\1", s)
    s = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", s)
    s = s.replace("~~", "").replace("**", "").replace("__", "")
    s = re.sub(r"^\s*([-*+]|\d+[.)])\s+", "", s)
    s = re.sub(r"^\s*\[[ x]\]\s*", "", s)
    s = re.sub(r"\s+", " ", s).strip()
    return s


def item_key(text):
    t = strip_md(text)
    m = re.search(r"(?i)[(\[]?\b(resolved|closed by|closed \d{4}|done \d{4})\b", t)
    if m and m.start() > 0:
        t = t[:m.start()]
    t = t.lower()
    t = re.sub(r"[^a-z0-9]+", " ", t).strip()
    return t[:100]


def heading_level(line):
    m = re.match(r"^(#{1,6})\s+(.*?)\s*#*\s*$", line)
    return (len(m.group(1)), m.group(2)) if m else (None, None)


def split_items(lines, prefer_subheadings=False):
    """lines of one section body -> list of (lineno_offset, text)."""
    if prefer_subheadings:
        return [(i, heading_level(l)[1]) for i, l in enumerate(lines) if heading_level(l)[0]]
    items, cur, cur_start = [], None, None
    in_code = False
    kinds = Counter()
    raw = []
    for i, l in enumerate(lines):
        if l.strip().startswith("```"):
            in_code = not in_code
            continue
        if in_code:
            continue
        raw.append((i, l))
    # 1. top-level list items and table rows
    for i, l in raw:
        if re.match(r"^\s{0,1}([-*+]|\d+[.)])\s+\S", l):
            if cur:
                items.append((cur_start, cur))
            cur, cur_start = l, i
            kinds["list"] += 1
        elif re.match(r"^\s*\|", l):
            if cur:
                items.append((cur_start, cur)); cur = None
            if re.match(r"^\s*\|[\s:|-]+\|\s*$", l):
                continue
            items.append((i, l)); kinds["table"] += 1
        elif cur and l.strip() and (l.startswith(" ") or l.startswith("\t")):
            cur += " " + l.strip()
        elif cur and l.strip() and not l.startswith("#") and not l.startswith(">"):
            cur += " " + l.strip()
        else:
            if cur:
                items.append((cur_start, cur)); cur = None
    if cur:
        items.append((cur_start, cur))
    # drop table header rows (the first row of each table)
    out, prev_table = [], False
    for i, t in items:
        is_table = t.lstrip().startswith("|")
        if is_table and not prev_table:
            prev_table = True
            continue
        prev_table = is_table
        out.append((i, t))
    if out:
        return out
    # 2. sub-headings
    subs = [(i, heading_level(l)[1]) for i, l in raw if heading_level(l)[0]]
    if subs:
        return subs
    # 3. paragraphs
    paras, cur = [], None
    for i, l in raw:
        if l.strip() and not l.startswith(">"):
            if cur is None:
                cur = (i, l.strip())
            else:
                cur = (cur[0], cur[1] + " " + l.strip())
        else:
            if cur:
                paras.append(cur); cur = None
    if cur:
        paras.append(cur)
    return paras


def collect_notes():
    items = []
    for rel in note_files():
        lines = (ROOT / rel).read_bytes().decode("utf-8", "replace").splitlines()
        in_code = False
        i = 0
        while i < len(lines):
            l = lines[i]
            if l.strip().startswith("```"):
                in_code = not in_code
            lvl, title = (None, None) if in_code else heading_level(l)
            extra = lvl and any(rel == f and title.startswith(h) for f, h in EXTRA_SECTIONS)
            if lvl and lvl >= 2 and (extra or (OPEN_HEADING.search(title) and not NOT_OPEN_HEADING.search(title))):
                j = i + 1
                code = False
                while j < len(lines):
                    if lines[j].strip().startswith("```"):
                        code = not code
                    if not code:
                        l2, _ = heading_level(lines[j])
                        if l2 and l2 <= lvl:
                            break
                    j += 1
                body = lines[i + 1:j]
                parts = split_items(body, prefer_subheadings=bool(extra) and any(
                    heading_level(x)[0] for x in body))
                for off, text in parts:
                    plain = strip_md(text)
                    if not plain or plain.lower().startswith("(none") or len(plain) < 8:
                        continue
                    lead = RESOLVED_LEAD.search(text) is not None
                    key = item_key(text)
                    hid = hashlib.sha1((rel + "\0" + key).encode()).hexdigest()[:8]
                    items.append(OrderedDict(
                        id="N-" + hid, source=f"{rel}:{i + 1 + off + 1}", section=strip_md(title),
                        text=plain, inline_resolved=lead or bool(re.search(
                            r"(?i)\b(resolved|closed|answered|typed|done)( 20\d\d| by| in| \(|:)|\bRESOLVED\b|^~~|^\W*\w+\W*~~", text.strip())),
                        default_area=area_for_path(rel)))
                i = j
                continue
            i += 1
    # repo-root CLAUDE.md: Known Disputed Interpretations
    lines = (ROOT / "CLAUDE.md").read_bytes().decode("utf-8", "replace").splitlines()
    try:
        s = next(k for k, l in enumerate(lines) if l.startswith("### Known Disputed Interpretations"))
    except StopIteration:
        s = None
    if s is not None:
        e = next((k for k in range(s + 1, len(lines)) if lines[k].startswith("## ") or lines[k].startswith("### ")),
                 len(lines))
        body = lines[s + 1:e]
        rows = [(k, l) for k, l in enumerate(body) if l.startswith("| **")]
        checks = [(k, l) for k, l in enumerate(body) if re.match(r"^- \[[ x]\]", l)]
        for k, l in rows + checks:
            key = item_key(l)
            hid = hashlib.sha1(("CLAUDE.md\0" + key).encode()).hexdigest()[:8]
            items.append(OrderedDict(id="N-" + hid, source=f"CLAUDE.md:{s + 2 + k}",
                                     section="Known Disputed Interpretations", text=strip_md(l),
                                     inline_resolved=l.startswith("- [x]"), default_area="KN5000"))
    # de-duplicate (the same text twice in one file)
    seen, out = set(), []
    for it in items:
        if it["id"] in seen:
            continue
        seen.add(it["id"]); out.append(it)
    return out


def area_for_path(rel):
    if rel.startswith("wsa1/"):
        return "WSA1R"
    if rel.startswith("kn7000/"):
        return "KN7000"
    if rel.split("/")[0] in ("kn6000", "kn6500", "kn2400", "hdsx3"):
        return "MN10300 siblings"
    if rel.startswith("floppy/") or "/floppy-" in rel:
        return "floppies"
    if "/media-" in rel:
        return "media"
    if "hdae" in rel:
        return "HD-AE5000"
    if rel.startswith("mame_driver/"):
        return "MAME/emulation"
    if rel.startswith(("scripts/", "tests/", "notes/lanes/", "archive/")) or "llvm" in rel or "toolchain" in rel:
        return "tooling"
    return "KN5000"


# ---------------------------------------------------------------- source I: issues
def collect_issues():
    items = []
    for raw in (ROOT / ".beads" / "issues.jsonl").read_bytes().splitlines():
        if not raw.strip():
            continue
        d = json.loads(raw)
        closed_here = d.get("status") == "closed" and "open-items register" in (d.get("close_reason") or "")
        if d.get("status") == "closed" and not closed_here:
            continue
        t = d["title"]
        items.append(OrderedDict(id=d["id"], source=".beads/issues.jsonl", section=f"p{d.get('priority')} "
                                 f"{d.get('issue_type')}", text=t, inline_resolved=closed_here,
                                 default_area=area_for_issue(t), issue_status=d.get("status")))
    return items


def area_for_issue(t):
    tl = t.lower()
    if tl.startswith("mame") or "hle" in tl or "emulation" in tl:
        return "MAME/emulation"
    if tl.startswith(("mines", "homebrew", "another world")):
        return "homebrew"
    if tl.startswith(("docs", "documentation", "update website")):
        return "documentation"
    if tl.startswith("llvm"):
        return "tooling"
    if tl.startswith("hdae5000"):
        return "HD-AE5000"
    return "KN5000"


# ---------------------------------------------------------------- source T: TODO markers
TREE_OF = [  # prefix -> tree name, first match wins
    ("v10/", "kn5000-v10"), ("v9/", "kn5000-v9"), ("v7/", "kn5000-v7"), ("v6/", "kn5000-v6"),
    ("v5/", "kn5000-v5"), ("v142/", "kn5000-v142"), ("v141/", "kn5000-v141"), ("v140/", "kn5000-v140"),
    ("subcpu/", "kn5000-subboot"), ("table_data/", "kn5000-tabledata"), ("custom_data/", "kn5000-customdata"),
    ("hdae5000_v2_01i/", "hdae5000-v2.01i"), ("hdae5000_v1_15i/", "hdae5000-v1.15i"),
    ("hdae5000_v1_10i/", "hdae5000-v1.10i"), ("hdae5000/", "hdae5000-v2.06i"), ("waveform/", "kn5000-waveform"),
    ("floppy/kn5000/", "floppy-kn5000"), ("floppy/", "floppy-other"), ("wsa1/", "wsa1"),
    ("kn7000/src/customdata/", "kn7000-customdata"), ("kn7000/src/ic21own/", "kn7000-ic21own"),
    ("kn7000/src/", "kn7000"), ("kn7000/", "kn7000-other"), ("kn6000/", "kn6000"), ("kn6500/", "kn6500"),
    ("kn2400/", "kn2400"), ("hdsx3/", "hdsx3"), ("mame_driver/", "mame_driver"), ("", "other")]
TREE_AREA = {"hdae": "HD-AE5000", "floppy": "floppies", "wsa1": "WSA1R", "kn7000": "KN7000", "kn6": "MN10300 siblings",
             "kn2400": "MN10300 siblings", "hdsx3": "MN10300 siblings", "mame": "MAME/emulation", "other": "tooling"}
SRC_EXT = (".s", ".inc", ".S", ".c", ".h", ".ld")


def tree_of(rel):
    for p, t in TREE_OF:
        if rel.startswith(p):
            return t


def area_for_tree(t):
    for k, a in TREE_AREA.items():
        if t.startswith(k):
            return a
    return "KN5000"


def todo_group(text):
    m = re.search(r"TODO(\([a-z]+\))?\s*:?\s*([A-Za-z]+)?\s*([A-Za-z]+)?", text)
    if m.group(1):
        return "TODO" + m.group(1)
    words = [w for w in (m.group(2), m.group(3)) if w]
    return "TODO: " + " ".join(words) if words else "TODO"


def collect_todos():
    files = subprocess.run(["git", "ls-files", "-z"], cwd=ROOT, capture_output=True).stdout.split(b"\0")
    groups = defaultdict(lambda: [0, None])
    per_tree = Counter()
    for f in files:
        rel = f.decode("utf-8", "replace")
        if not rel.endswith(SRC_EXT):
            continue
        data = (ROOT / rel).read_bytes()
        if b"TODO" not in data:
            continue
        t = tree_of(rel)
        for ln, line in enumerate(data.split(b"\n"), 1):
            if b"TODO" not in line:
                continue
            s = line.decode("utf-8", "replace")
            # comments only: after ';' or '//' or '/*' or '#'
            c = re.search(r"(;|//|/\*|\s#|^#).*TODO", s)
            if not c:
                continue
            g = todo_group(s[c.start():])
            k = (t, g)
            groups[k][0] += 1
            if groups[k][1] is None:
                groups[k][1] = f"{rel}:{ln}"
            per_tree[t] += 1
    items = []
    for (t, g), (n, first) in sorted(groups.items()):
        slug = re.sub(r"[^a-z0-9]+", "-", g.lower()).strip("-")
        items.append(OrderedDict(id=f"T-{t}-{slug}", source=first, section="TODO markers",
                                 text=f"{n} x `{g}` in {t}", inline_resolved=False,
                                 default_area=area_for_tree(t), count=n))
    return items, per_tree


# ---------------------------------------------------------------- source O: opaque declarations
def collect_opaque(run_census):
    if run_census:
        p = subprocess.run([sys.executable, "scripts/analysis/data_incbin_census.py", "--list", "opaque"],
                           cwd=ROOT, capture_output=True, text=True, errors="replace")
        groups = defaultdict(lambda: {"n": 0, "bytes": 0, "first": None, "kind": None, "reason": None})
        seen = set()
        for line in p.stdout.splitlines():
            f = line.split("\t")
            if len(f) < 5 or f[1] in seen:
                continue
            kind, _, why = f[4].partition(":")
            if kind not in ("unknown-dump", "code"):
                continue
            seen.add(f[1])
            reason = re.sub(r"0x[0-9a-fA-F]+", "ADDR", why.strip())
            reason = re.sub(r"\b\d[\d,]*\b", "N", reason)
            reason = re.sub(r"\([^)]*\)$", "", reason).strip()[:110]
            g = groups[(f[0], kind, reason)]
            g["n"] += 1
            try:
                g["bytes"] += int(f[2])
            except ValueError:
                pass
            g["first"] = g["first"] or f[1]
            g["kind"], g["reason"] = kind, reason
        rows = [dict(tree=t, **v) for (t, k, r), v in sorted(groups.items())]
        OPAQUE_CACHE.write_text(json.dumps(rows, indent=1) + "\n")
    else:
        rows = json.loads(OPAQUE_CACHE.read_text()) if OPAQUE_CACHE.exists() else []
    # one register item per (tree, reason class): the reason class is the reason's head, before ';'
    cls = defaultdict(lambda: {"n": 0, "bytes": 0, "first": None, "variants": 0})
    for r in rows:
        head = re.sub(r"^N bytes of ", "", r["reason"]).split(";")[0].strip()
        head = re.sub(r"\bN\b", "", head)
        head = re.sub(r"\s+", " ", head).strip(" ,.")
        c = cls[(r["tree"], r["kind"], head)]
        c["n"] += r["n"]; c["bytes"] += r["bytes"]; c["variants"] += 1
        c["first"] = c["first"] or r["first"]
    items = []
    for (t, k, head), v in sorted(cls.items()):
        slug = hashlib.sha1(head.encode()).hexdigest()[:6]
        items.append(OrderedDict(id=f"O-{t}-{k}-{slug}", source=v["first"], section=f"census: opaque -- {k}",
                                 text=f"{v['n']} x {v['bytes']:,} B in {t}: {head}", inline_resolved=False,
                                 default_area=area_for_census_tree(t), count=v["n"], bytes=v["bytes"]))
    return items, rows


def area_for_census_tree(t):
    if "floppy" in t:
        return "floppies"
    if t.startswith("wsa1"):
        return "WSA1R"
    if t.startswith("kn7000"):
        return "KN7000"
    if t.startswith(("kn6", "kn2400", "hdsx3")):
        return "MN10300 siblings"
    if "hdae" in t:
        return "HD-AE5000"
    return "KN5000"


# ---------------------------------------------------------------- join and render
def md_table(header, rows):
    w = [len(h) for h in header]
    rows = [[str(c).replace("|", "\\|").replace("\n", " ") for c in r] for r in rows]
    for r in rows:
        for k, c in enumerate(r):
            w[k] = max(w[k], len(c))
    out = ["| " + " | ".join(h.ljust(w[k]) for k, h in enumerate(header)) + " |",
           "|" + "|".join("-" * (w[k] + 2) for k in range(len(header))) + "|"]
    for r in rows:
        out.append("| " + " | ".join(c.ljust(w[k]) for k, c in enumerate(r)) + " |")
    return "\n".join(out)


def short(s, n):
    s = re.sub(r"\s+", " ", s or "").strip()
    return s if len(s) <= n else s[:n - 3].rstrip() + "..."


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--write", action="store_true")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--dump")
    ap.add_argument("--no-census", action="store_true")
    a = ap.parse_args()

    notes = collect_notes()
    issues = collect_issues()
    todos, todo_per_tree = collect_todos()
    opaque, _ = collect_opaque(not a.no_census)
    items = notes + issues + todos + opaque
    if a.dump:
        Path(a.dump).write_text(json.dumps(items, indent=1, ensure_ascii=False) + "\n")

    triage = json.loads(TRIAGE.read_text()) if TRIAGE.exists() else {}
    by_id = {it["id"]: it for it in items}
    untriaged = [it for it in items if it["id"] not in triage]
    orphans = [k for k in triage if k not in by_id]
    # triage rows with a "source" of their own are items no collector source holds (L- ids: items a lane
    # brief names, or text outside an open-items heading); they are rendered, not reported
    errors = [k for k in orphans if triage[k].get("status") != "RESOLVED" and not triage[k].get("source")]
    bad = [k for k, v in triage.items() if v.get("status") not in STATUSES or
           (v.get("area") and v["area"] not in AREAS)]

    rows = []  # (area, id, source, item, status, plan/blocker, size)
    for it in items:
        t = triage.get(it["id"], {})
        st = t.get("status", "UNTRIAGED")
        area = t.get("area") or it["default_area"]
        rows.append(dict(area=area, id=it["id"], source=it["source"], kind=it["id"][0],
                         item=t.get("title") or it["text"], status=st, owner=t.get("owner", ""),
                         note=t.get("plan") or t.get("blocker") or t.get("evidence") or "", size=t.get("size", "")))
    for k in orphans:
        t = triage[k]
        if t.get("status") == "RESOLVED" or t.get("source"):
            rows.append(dict(area=t.get("area", "KN5000"), id=k, source=t.get("source", "(updated note)"),
                             kind=k[0], item=t.get("title", ""), status=t["status"], owner=t.get("owner", ""),
                             note=t.get("plan") or t.get("blocker") or t.get("evidence", ""),
                             size=t.get("size", "")))

    kinds = {"N": "notes", "k": "issues", "T": "TODO groups", "O": "opaque groups", "L": "listed by hand"}
    st_all = Counter(r["status"] for r in rows)
    by_kind = Counter(kinds.get(r["kind"], "issues") for r in rows)
    print("items:", len(rows), dict(by_kind))
    print("status:", dict(st_all))
    print("TODO markers:", sum(todo_per_tree.values()), "in", len(todo_per_tree), "trees;",
          "opaque groups:", len(opaque), "covering", sum(i["count"] for i in opaque), "declarations")
    print("untriaged:", len(untriaged), " orphan triage rows:", len(orphans),
          "(listed by hand:", sum(1 for k in orphans if triage[k].get("source")), "; in error:", len(errors), ")",
          " bad rows:", len(bad))

    if a.write:
        render(rows, todo_per_tree, opaque)
    if a.check:
        for it in untriaged[:50]:
            print("UNTRIAGED", it["id"], it["source"], short(it["text"], 100))
        for k in errors:
            print("ORPHAN", k, triage[k].get("title", ""))
        for k in bad:
            print("BAD", k, triage[k])
        if untriaged or bad or errors:
            sys.exit(1)


def render(rows, todo_per_tree, opaque):
    out = []
    out.append("# Open-items register")
    out.append("")
    out.append("Generated by `python3 notes/open-items/collect_open_items.py --write` from the four sources its "
               "docstring lists and the triage in `triage.json`; do not edit by hand (README.md says how to "
               "triage an item).  Every count below is the script's.")
    out.append("")
    statuses = STATUSES + (["UNTRIAGED"] if any(r["status"] == "UNTRIAGED" for r in rows) else [])
    out.append("## Summary")
    out.append("")
    hdr = ["area"] + statuses + ["total"]
    tab = []
    for ar in AREAS:
        rs = [r for r in rows if r["area"] == ar]
        c = Counter(r["status"] for r in rs)
        tab.append([ar] + [str(c.get(s, 0)) for s in statuses] + [str(len(rs))])
    c = Counter(r["status"] for r in rows)
    tab.append(["**all**"] + [f"**{c.get(s, 0)}**" for s in statuses] + [f"**{len(rows)}**"])
    out.append(md_table(hdr, tab))
    out.append("")
    kinds = [("N", "notes items"), ("k", "tracker issues"), ("T", "TODO-marker groups"), ("O", "opaque groups"),
             ("L", "listed by hand")]
    tab = []
    for k, name in kinds:
        rs = [r for r in rows if (r["kind"] == k if k != "k" else r["kind"] not in "NTOL")]
        c = Counter(r["status"] for r in rs)
        tab.append([name] + [str(c.get(s, 0)) for s in statuses] + [str(len(rs))])
    out.append(md_table(["source"] + statuses + ["total"], tab))
    out.append("")
    lanes = Counter(r["owner"] for r in rows if r["status"] == "ACTIONABLE")
    tab = [[o or "(no lane: next wave)", str(n)] for o, n in sorted(lanes.items(), key=lambda x: (x[0] != "", x[0]))]
    out.append("ACTIONABLE items by owning lane:")
    out.append("")
    out.append(md_table(["lane", "items"], tab))
    out.append("")
    sizes = Counter(r["size"] for r in rows if r["status"] == "ACTIONABLE" and not r["owner"])
    out.append("Unowned ACTIONABLE items by size: " + ", ".join(f"{s or '?'} {sizes[s]}" for s in "SML" if sizes[s])
               + (f", unsized {sizes['']}" if sizes.get("") else "") + ".")
    out.append("")
    out.append(f"TODO markers in the sources: {sum(todo_per_tree.values())} in {len(todo_per_tree)} trees "
               f"(grouped below as T- rows).  Opaque unknown-dump / code declarations: "
               f"{sum(i['count'] for i in opaque)} in {len(opaque)} groups (O- rows).")
    out.append("")
    out.append("## Next wave: the ACTIONABLE items no lane owns")
    out.append("")
    out.append("The work list for the next wave, by area and size (S first).  The per-area tables below give each "
               "item's plan.")
    out.append("")
    tab = []
    for ar in AREAS:
        rs = sorted([r for r in rows if r["area"] == ar and r["status"] == "ACTIONABLE" and not r["owner"]],
                    key=lambda r: ("SML".index(r["size"]) if r["size"] in ("S", "M", "L") else 3, r["id"]))
        for r in rs:
            tab.append([ar, r["size"], r["id"], short(r["item"], 110)])
    out.append(md_table(["area", "size", "id", "item"], tab))
    out.append("")
    order = {s: k for k, s in enumerate(["BLOCKED", "ACTIONABLE", "UNTRIAGED", "RESOLVED"])}
    for ar in AREAS:
        rs = sorted([r for r in rows if r["area"] == ar], key=lambda r: (order[r["status"]], r["kind"] != "k",
                                                                          r["id"]))
        if not rs:
            continue
        out.append(f"## {ar}")
        out.append("")
        tab = []
        for r in rs:
            note = r["note"]
            if r["owner"] and r["status"] == "ACTIONABLE":
                note = f"lane {r['owner']}: " + note
            tab.append([r["id"], r["source"], short(r["item"], 110), r["status"], short(note, 220), r["size"]])
        out.append(md_table(["id", "source", "item", "status", "plan or blocker", "size"], tab))
        out.append("")
    REGISTER.write_text("\n".join(out))


if __name__ == "__main__":
    main()
