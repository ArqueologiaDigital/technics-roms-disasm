#!/usr/bin/env python3
"""data_incbin_census.py -- the binary-include ledger: per tree, how many bytes are still a generic binclude.

QUESTION IT ANSWERS
  "Which data in the sources is still pulled in as an anonymous blob, although it could be described as typed
   records, strings, tables, a generator's output or a self-describing file?"  Set up 2026-10-29, at the owner's
   request: "ensure any data block in the source is only left as a generic binclude if there's no other better
   semantic representation for it".

WHAT IT READS
  Every git-tracked `.s` / `.inc` / `.S` file under each tree in TREES (bytes mode: these files hold non-UTF-8
  `.ascii` bytes).  Each `.incbin` (llvm-mc and kn7asm) and `.incbin_range` (kn7asm) directive is one entry.

SIZE
  `.incbin "f", skip, count`  -> count;   `.incbin "f", skip` -> size(f) - skip;   `.incbin "f"` -> size(f);
  `.incbin_range "f", a, b`   -> b - a.
  A file is looked up next to the including file, then in each ancestor directory up to the repo root, and in
  `<tree>/build/`.  A file that does not exist (not built yet, or a git-ignored reference not copied) and has no
  count is reported as `unsized`; run the tree's build first for exact byte figures.

CLASSES (first match wins)
  generated   the path contains `generated/` (KN5000 compiled C: byte-exact clang output, see CLAUDE.md), or the
              directive's line or the comment line right above it carries `census: generated -- <generator>`:
              the bytes come out of a committed generator from committed source.
  media       the file has a self-describing format a viewer reads directly: jpg jpeg bmp png gif tif wav aif mid
              (the file IS the semantic representation; its container is documented by its own standard).
  opaque      the line, or the comment line right above, carries `census: opaque -- <kind>: <why>`: the bytes have
              no better representation than themselves.  The reason is mandatory and is listed in the report.
              Accepted kinds: pcm (sample bodies), compressed (an entropy-coded stream with no committed
              encoder), code (an undisassembled code gap; not data, counted so it is visible), unknown-dump (an
              undecoded vendor blob, with what was tried), personal (the owner's own instrument data, kept out of
              the public sources on purpose), fill (verified uniform fill).
  generic     everything else: an anonymous binclude.  The goal is generic = 0.

  A program image's `.incbin_range` gaps in kn7000/ and the MN10300 siblings mix code and data; until a lane
  declares them, they are generic.

OUTPUT
  A table per tree (count and bytes per class) and, with --list generic, every generic entry with its location.
  --snapshot writes docs/coverage/data-incbin-<date>-NN.{txt,json} (a committed snapshot is never rewritten;
  a re-run reuses today's uncommitted file).  --compare <json> exits 1 when any tree's generic bytes ROSE.

USAGE
  python3 scripts/analysis/data_incbin_census.py                       # the table
  python3 scripts/analysis/data_incbin_census.py --list generic --tree kn7000-table
  python3 scripts/analysis/data_incbin_census.py --snapshot --compare $(ls docs/coverage/data-incbin-*.json | tail -1)
"""
import argparse, datetime, json, os, re, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

# tree name -> directories (relative to ROOT) whose sources belong to it.  New data trees add a row here.
TREES = {
    "kn5000-v10":        ["v10/maincpu"],
    "kn5000-v9":         ["v9/maincpu"],
    "kn5000-v7":         ["v7/maincpu"],
    "kn5000-v6":         ["v6/maincpu"],
    "kn5000-v5":         ["v5/maincpu"],
    "kn5000-v142":       ["v142/subcpu"],
    "kn5000-v141":       ["v141/subcpu"],
    "kn5000-v140":       ["v140/subcpu"],
    "kn5000-subboot":    ["subcpu/boot"],
    "kn5000-tabledata":  ["table_data"],
    "kn5000-customdata": ["custom_data"],
    "kn5000-hdae5000":   ["hdae5000"],
    "kn5000-hdae201":    ["hdae5000_v2_01i"],
    "kn5000-waveform":   ["waveform"],
    "kn5000-rhythm":     ["rhythm_data"],
    "kn5000-floppy":     ["floppy/kn5000"],
    "wsa1":              ["wsa1/src", "wsa1/include"],
    "wsa1-floppy":       ["floppy/wsa1"],
    "kn7000-program":    ["kn7000/src/program", "kn7000/src/program.s"],
    "kn7000-table":      ["kn7000/src/table", "kn7000/src/table.s"],
    "kn7000-sp7001":     ["kn7000/src/sp7001"],
    "kn7000-b80":        ["kn7000/src/b80"],
    "kn7000-b893":       ["kn7000/src/b893"],
    "kn7000-b935":       ["kn7000/src/b935"],
    "kn7000-cnv":        ["kn7000/src/cnv"],
    "kn7000-ic18":       ["kn7000/src/ic18"],
    "kn7000-picture":    ["kn7000/src/picture", "kn7000/src/picture.s"],
    "kn7000-wave":       ["kn7000/src/wave"],
    "kn7000-customdata": ["kn7000/src/customdata"],
    "kn6000-customdata": ["kn6000/src/customdata"],
    "kn7000-floppy":     ["floppy/kn7000"],
    "kn6000-floppy":     ["floppy/kn6000"],
    "kn2400":            ["kn2400/src"],
    "kn6000":            ["kn6000/src/program.s", "kn6000/src/program"],
    "kn6500":            ["kn6500/src"],
    "hdsx3":             ["hdsx3/src"],
}

MEDIA = {"jpg", "jpeg", "bmp", "png", "gif", "tif", "tiff", "wav", "aif", "aiff", "mid"}
KINDS = {"pcm", "compressed", "code", "unknown-dump", "personal", "fill"}
INC = re.compile(rb'^\s*(?:[A-Za-z_.$][\w.$]*:\s*)?\.(incbin_range|incbin)\s+"([^"]+)"\s*(?:,\s*([^,;#\s]+))?\s*(?:,\s*([^,;#\s]+))?')
MARK = re.compile(rb'census:\s*(generated|opaque)\s*--\s*(.*)')


def tracked_files():
    out = subprocess.run(["git", "ls-files", "-z"], cwd=ROOT, capture_output=True, check=True).stdout
    return [p.decode() for p in out.split(b"\0") if p]


def num(tok):
    if tok is None:
        return None
    try:
        return int(tok.decode(), 0)
    except ValueError:
        return None


def locate(path, src, tree_dirs):
    cands = []
    d = (ROOT / src).parent
    while True:
        cands.append(d / path)
        if d == ROOT:
            break
        d = d.parent
    for td in tree_dirs:
        base = ROOT / td
        if base.is_file():
            base = base.parent
        cands.append(base / "build" / path)
    for c in cands:
        if c.is_file():
            return c
    return None


def classify(line, prev, path):
    for txt in (line, prev):
        m = MARK.search(txt)
        if m:
            kind = m.group(1).decode()
            why = m.group(2).decode("latin-1").strip()
            if kind == "opaque":
                k = why.split(":", 1)[0].strip()
                if k not in KINDS or ":" not in why or not why.split(":", 1)[1].strip():
                    return "generic", "malformed opaque marker: " + why
                return "opaque", why
            return "generated", why
    if "generated/" in path:
        return "generated", "compiled C"
    ext = path.rsplit(".", 1)[-1].lower() if "." in path else ""
    if ext in MEDIA:
        return "media", ext
    return "generic", ""


def census():
    files = tracked_files()
    res = {}
    for tree, dirs in TREES.items():
        mine = [f for f in files if f.endswith((".s", ".inc", ".S"))
                and any(f == d or f.startswith(d.rstrip("/") + "/") for d in dirs)]
        if not mine:
            continue
        rows = []
        for f in sorted(mine):
            prev = b""
            for ln, line in enumerate((ROOT / f).read_bytes().split(b"\n"), 1):
                m = INC.match(line)
                if m:
                    op, path = m.group(1).decode(), m.group(2).decode("latin-1")
                    a, b = num(m.group(3)), num(m.group(4))
                    size = None
                    if op == "incbin_range" and a is not None and b is not None:
                        size = b - a
                    elif b is not None:
                        size = b
                    else:
                        loc = locate(path, f, dirs)
                        if loc is not None:
                            size = loc.stat().st_size - (a or 0)
                    cls, why = classify(line, prev, path)
                    rows.append({"file": f, "line": ln, "path": path, "size": size, "class": cls, "why": why})
                if line.strip():
                    prev = line
        res[tree] = rows
    return res


def summarize(res):
    summ = {}
    for tree, rows in res.items():
        s = {}
        for c in ("generated", "media", "opaque", "generic"):
            rr = [r for r in rows if r["class"] == c]
            s[c] = {"n": len(rr), "bytes": sum(r["size"] or 0 for r in rr),
                    "unsized": sum(1 for r in rr if r["size"] is None)}
        summ[tree] = s
    return summ


def table(summ):
    head = ["tree", "generated", "media", "opaque", "generic n", "generic bytes", "unsized"]
    body = []
    for t, s in summ.items():
        body.append([t, f'{s["generated"]["n"]} / {s["generated"]["bytes"]:,}', f'{s["media"]["n"]} / {s["media"]["bytes"]:,}',
                     f'{s["opaque"]["n"]} / {s["opaque"]["bytes"]:,}', str(s["generic"]["n"]), f'{s["generic"]["bytes"]:,}',
                     str(sum(s[c]["unsized"] for c in s))])
    w = [max(len(r[i]) for r in [head] + body) for i in range(len(head))]
    out = ["| " + " | ".join(h.ljust(w[i]) for i, h in enumerate(head)) + " |",
           "|" + "|".join("-" * (x + 2) for x in w) + "|"]
    out += ["| " + " | ".join(c.ljust(w[i]) for i, c in enumerate(r)) + " |" for r in body]
    return "\n".join(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--list", choices=["generic", "opaque", "media", "generated"])
    ap.add_argument("--tree")
    ap.add_argument("--snapshot", action="store_true")
    ap.add_argument("--compare")
    a = ap.parse_args()
    res = census()
    summ = summarize(res)
    txt = "class columns are `count / bytes`; unsized = entries whose file is not present (build the tree first)\n\n" + table(summ)
    print(txt)
    if a.list:
        for t, rows in res.items():
            if a.tree and t != a.tree:
                continue
            for r in rows:
                if r["class"] == a.list:
                    print(f'{t}\t{r["file"]}:{r["line"]}\t{r["size"]}\t{r["path"]}\t{r["why"]}')
    rc = 0
    if a.compare:
        old = json.load(open(a.compare))["summary"]
        for t, s in summ.items():
            if t in old and s["generic"]["bytes"] > old[t]["generic"]["bytes"]:
                print(f"ROSE  {t}: generic bytes {old[t]['generic']['bytes']:,} -> {s['generic']['bytes']:,}")
                rc = 1
    if a.snapshot:
        day = datetime.date.today().isoformat()
        cov = ROOT / "docs/coverage"
        committed = set(tracked_files())
        nn = 1
        while (f"docs/coverage/data-incbin-{day}-{nn:02d}.json" in committed):
            nn += 1
        stem = cov / f"data-incbin-{day}-{nn:02d}"
        head = subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=ROOT, capture_output=True, text=True).stdout.strip()
        stem.with_suffix(".txt").write_text(f"data-incbin census {day} at {head}\n\n" + txt + "\n")
        stem.with_suffix(".json").write_text(json.dumps({"date": day, "head": head, "summary": summ,
                                                          "entries": res}, indent=0) + "\n")
        print("wrote", stem.relative_to(ROOT))
    sys.exit(rc)


if __name__ == "__main__":
    main()
