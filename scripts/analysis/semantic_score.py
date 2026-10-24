#!/usr/bin/env python3
"""semantic_score.py -- one score for the semantic-disassembly effort, and the README badges that show it.

QUESTION IT ANSWERS
  "How far is the disassembly of every ROM of all three models from fully semantic, as one number that can sit
   in a badge -- and what is that number made of?"  Byte-identity is a gate (always 100%), not progress.  The
  score averages four measurable shares from DISASSEMBLY-COMPLETENESS-SPEC.md's levels.  Each is pooled over
  every image of a model, so a bigger image weighs more.  The KN5000 and SX-WSA1R definitions:

  bytes   L1  bytes whose purpose the source states with evidence: (CODE + DATA-KNOWN-A + FILLER) / all bytes.
              Source: scripts/analysis/data_range_census.py --json (its "strict" figure).
  names   L2  symbols in the linked ELFs (.text, all 12 images) with a semantic name / all rated symbols.
              Rated = semantic + generic + positional.  Not rated: local branch labels, in every style the
              trees use -- _Skip/_Join/_Loop/_Return/..., and prom_c's Parent__F9A123 / Parent__loop -- whatever
              their parent is called, so a routine is rated once, by its own name, not once per branch inside
              it.  This is wave7_documentation_metrics.py's rule ("an internal branch target is not a
              documentation debt"); rules 1 (the first release) still rated them, under an unnamed parent as
              positional.
              Positional: l2_symbol_reference.py's rule, the name restates an address (_0xHEX, _A1B2..., LABEL_,
              sub_, loc_, unk_).
              Generic: the name says only "a piece of X" (_Helper7, _Data_3, _Code, _Block2, _Case5,
              _Switch2_Case5, ...).  The _Case labels of scripts/tools/frame_switch_cases.py count here
              until each case is understood.
  entry   L2  jump/call tables whose every code entry lands on a labelled instruction and is spelled
              symbolically / all tables.  Source: the newest COMMITTED docs/coverage/dispatch-census-*.json
              (framed tables and unframed runs).  A table the census classes STALE (declared `census: stale`
              in the source and accepted by its checks, 2026-10-06) is not counted as not used.
  fields  L3  C struct/union members with a meaningful name / all declared members, in every *.c / *.h of
              the image trees.  A name is a placeholder when nothing is left once index tokens (3, w0, v80,
              0a38) and generic words (str, ptr, field, unk, pad, reserved, data, ...) are dropped:
              field_0a38, str_3, v80_e0, ptrs_0.  w0_text, rect and Style_g0_s0_Title3 count as named.
              A model with no C has no fields component.

  THE SX-KN7000 MODEL (rules 3).  Images: program (build 941), table (build 84) and cnv, the seven Style Convert
  Disk converters pooled (kn7000/src/cnv/*.s).  The SP7001 set (942/83, BASEEXT.XAP) and the IC19 picture image
  are not rated yet.  It has no ELF, no dispatch census and no C, so two of its components are defined from the
  sources and two are absent:
  bytes   the share of each image emitted by source rather than `.incbin_range` passthrough: kn7000/tools/
          coverage_score.py's "source coverage" for program (its figure is cross-checked and the run stops on a
          mismatch), and the same parse for table and cnv.  Image sizes are the built images'
          (kn7000/build/, `make kn7000`).  WEAKER than the L1 figure above: a byte spelled as `.byte` or as
          an instruction counts whether or not its purpose is stated, so this is an upper bound on L1.
  names   named routines / all rated routines.  program: the recovered functions, i.e. the generator banners
          `# Name  (CPU 0x...)` (converted or still passthrough), plus the names in program.s's block of
          `.equ` labels for internal helpers called by converted code (`func_484057D9` and friends), minus the
          `*_entry` second entry points; distinct names.  cnv: the label under each generator banner
          `# ---- Name ----`, in each converter (a routine the seven share counts once per converter).  table:
          none (data only).  Positional / generic as above (`func_<hex>` is positional).  Data labels (cnv's
          str_/bss_/data_, RAM `.equ`s) are not rated, unlike the KN5000/WSA1 rating of every .text symbol, and a
          routine nobody has found inside the passthrough is in no denominator.
  entry   absent (null): no dispatch census covers the MN10300 images.
  fields  absent: no C.

  score = the mean of the components a model has.  "all" pools the models component by component, then
  averages.  So "all" bytes adds the strict L1 count of KN5000 and WSA1 to kn7000's source-share upper bound
  (kn7000 is about 42% of the pooled denominator): the pooled bytes badge mixes the two definitions, and the
  per-model components in the JSON are the ones to compare.  A number goes up only when the disassembly gets more meaningful.  The score is a summary for a
  badge, not a substitute for the components, which the JSON and the README badges also show.

OUTPUT (docs/badges/)
  semantic-score.svg, semantic-score-kn5000.svg, semantic-score-wsa1.svg, semantic-score-kn7000.svg, and one
  badge per component: semantic-bytes.svg, semantic-names.svg, semantic-entry.svg, semantic-fields.svg (all
  models pooled)
  semantic-score.json   every numerator and denominator, the commit, the date
  semantic-score-history.csv   one row appended per run (a rerun at the same commit replaces its row); the
                               kn7000 column is the last one and is empty in the rows from before rules 3

RUN (repository root; needs a built tree: `make everything`, which builds kn7000/build/ too)
  python3 scripts/analysis/semantic_score.py                       # runs the data census (a few minutes)
  python3 scripts/analysis/semantic_score.py --census-json F.json  # reuse a data_range_census.py --json output
  python3 scripts/analysis/semantic_score.py --print                # compute and print only, write nothing
  make semantic-score
"""
import collections
import csv
import datetime
import glob
import json
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NM = os.path.expanduser("~/compartilhado/llvm-project/build/bin/llvm-nm")
OUT = os.path.join(ROOT, "docs", "badges")

MODELS = {
    "kn5000": ["v10", "v9", "v7", "v142", "subboot", "tabledata", "customdata", "hdae5000"],
    "wsa1": ["prom_a", "prom_b", "prom_c", "prom_d"],
    "kn7000": ["program", "table", "cnv"],
}
KN7000 = {      # key: (sources, built images) -- glob patterns, relative to ROOT
    "program": ("kn7000/src/program.s", "kn7000/build/kn7000_program.rom"),
    "table": ("kn7000/src/table.s", "kn7000/build/kn7000_table.rom"),
    "cnv": ("kn7000/src/cnv/*.s", "kn7000/build/cnv/*.cnv"),
}
ELF = {
    "v10": "rebuilt_ROMs/kn5000_v10_program.llvm.elf", "v9": "rebuilt_ROMs/kn5000_v9_program.llvm.elf",
    "v7": "rebuilt_ROMs/kn5000_v7_program.llvm.elf", "v142": "rebuilt_ROMs/kn5000_subprogram_v142.llvm.elf",
    "subboot": "rebuilt_ROMs/kn5000_subcpu_boot.llvm.elf", "tabledata": "rebuilt_ROMs/kn5000_table_data.llvm.elf",
    "customdata": "rebuilt_ROMs/kn5000_custom_data.llvm.elf", "hdae5000": "rebuilt_ROMs/hd-ae5000_v2_06i.llvm.elf",
    "prom_a": "wsa1/rebuilt_ROMs/wsa1_prom_a.llvm.elf", "prom_b": "wsa1/rebuilt_ROMs/wsa1_prom_b.llvm.elf",
    "prom_c": "wsa1/rebuilt_ROMs/wsa1_prom_c.llvm.elf", "prom_d": "wsa1/rebuilt_ROMs/wsa1_prom_d.llvm.elf",
}
C_TREES = {
    "kn5000": ["v10/maincpu", "v9/maincpu", "v7/maincpu", "v142/subcpu", "subcpu/boot", "table_data",
               "custom_data", "hdae5000"],
    "wsa1": ["wsa1"],
    "kn7000": [],
}
POSITIONAL = [re.compile(p) for p in (r'_0x[0-9A-Fa-f]+$', r'_[0-9A-F]{4,}$', r'^LABEL_', r'^(loc|sub|unk)_', r'^\.L')]
CONTINUATION = re.compile(r'_(Skip|Join|Loop|Return|Epilogue|Done|Next|Exit|Cont|End|Default|Resume|Nop)\d*$'
                          r'|__[0-9A-Fa-f]{4,6}$|__[a-z]\w*$')
RULES = 3       # 1: first release; 2 (2026-10-06): local branch labels are not rated whatever their parent;
                # 3 (2026-10-24): the SX-KN7000 model (program, table, cnv) is added and pooled into "all".  The
                #   KN5000 and WSA1 figures are computed exactly as under 2; "all" and the pooled component badges
                #   move because the kn7000 bytes and names join their numerators and denominators.
GENERIC = re.compile(r'_(Helper|Data|Code|Block|Branch|Stub|Part|Case|Entry|Sub|Thunk|Wrapper|Body|Chunk|Tail|Frag'
                     r'|Fragment)\d*(_\d+)*$|_Switch\d+_Case\d+$')
GENERIC_WORDS = {"field", "unk", "unknown", "pad", "padding", "reserved", "res", "str", "ptr", "ptrs", "entry",
                 "entries", "item", "items", "data", "raw", "byte", "bytes", "word", "words", "dword", "val", "arr",
                 "tbl", "tab", "elem", "rec", "slot", "x", "b", "w", "d", "e", "v", "f", "m"}
INDEX_TOKEN = re.compile(r'^(?:0x)?[A-Za-z]?(?:[0-9A-F]+|[0-9a-f]*[0-9][0-9a-f]*)$')    # 3, w0, v80, vFD, 0a38


def placeholder_field(name):
    """True when nothing is left of the name once index tokens (3, w0, v80, 0a38) and generic words
    (str, ptr, field, unk, pad, reserved, data, ...) are dropped: str_3, v80_e0, field_0a38, ptrs_0."""
    return not [t for t in name.split("_") if t and not INDEX_TOKEN.match(t) and t.lower() not in GENERIC_WORDS]
LABEL = {"bytes": "bytes understood", "names": "semantic names", "entry": "jump tables resolved",
         "fields": "C fields named"}


def git(*a):
    return subprocess.run(["git", "-C", ROOT] + list(a), capture_output=True, text=True).stdout.strip()


# ---- components -------------------------------------------------------------------------------------------
def names(key):
    if key in KN7000:
        return kn7000_names(key)
    out = subprocess.run([NM, "--defined-only", os.path.join(ROOT, ELF[key])], capture_output=True, text=True)
    if out.returncode:
        sys.exit("llvm-nm failed on %s (build the tree first: make everything)" % ELF[key])
    c = collections.Counter()
    for line in out.stdout.split("\n"):
        f = line.split()
        if len(f) != 3 or f[1] not in "tT":
            continue
        n = f[2]
        if CONTINUATION.search(n):
            c["continuation"] += 1
        elif any(p.search(n) for p in POSITIONAL):
            c["positional"] += 1
        elif GENERIC.search(n):
            c["generic"] += 1
        else:
            c["semantic"] += 1
    return c["semantic"], c["semantic"] + c["generic"] + c["positional"], dict(c)


def kn7000_files(pattern):
    return sorted(glob.glob(os.path.join(ROOT, pattern)))


def kn7000_val(expr):
    """An .incbin_range operand: hex / decimal terms joined by + and - (coverage_score.py's rule)."""
    total, sign = 0, 1
    for tok in re.findall(r'[+-]|0x[0-9A-Fa-f]+|\d+', expr):
        if tok in "+-":
            sign = 1 if tok == "+" else -1
        else:
            total += sign * int(tok, 16 if tok.lower().startswith("0x") else 10)
    return total


def kn7000_bytes(key):
    """(bytes emitted by source, image bytes) for one kn7000 image: the image minus its .incbin_range bytes."""
    srcs, imgs = kn7000_files(KN7000[key][0]), kn7000_files(KN7000[key][1])
    if not srcs or len(imgs) != len(srcs):
        sys.exit("kn7000 %s: %d sources but %d built images under %s (build them: make kn7000)"
                 % (key, len(srcs), len(imgs), KN7000[key][1]))
    raw = 0
    for p in srcs:
        text = open(p, "rb").read().decode("latin-1")
        if re.search(r'^\s*\.incbin\s', text, re.M):
            sys.exit("%s: a plain .incbin; kn7000_bytes() only reads .incbin_range" % p)
        hits = re.findall(r'^\s*\.incbin_range\s+"[^"]+",\s*([^,]+?),\s*([^\n#;]+?)\s*(?:[#;]|$)', text, re.M)
        if len(hits) != len(re.findall(r'^\s*\.incbin_range\b', text, re.M)):
            sys.exit("%s: an .incbin_range this parser cannot read would count as source" % p)
        raw += sum(kn7000_val(b) - kn7000_val(a) for a, b in hits)
    size = sum(os.path.getsize(p) for p in imgs)
    if key == "program":         # the same figure kn7000/tools/coverage_score.py reports, or stop
        import importlib.util
        spec = importlib.util.spec_from_file_location("coverage_score",
                                                      os.path.join(ROOT, "kn7000/tools/coverage_score.py"))
        cs = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cs)
        m = cs.measure()
        if (m["prog_src"], m["prog_total"]) != (size - raw, size):
            sys.exit("kn7000 program: %d/%d source bytes here, %d/%d from coverage_score.py"
                     % (size - raw, size, m["prog_src"], m["prog_total"]))
    return size - raw, size


def kn7000_names(key):
    """kn7000 routine names, classified like names(): see the docstring (THE SX-KN7000 MODEL)."""
    rated = []
    for p in kn7000_files(KN7000[key][0]):
        lines = open(p, "rb").read().decode("latin-1").split("\n")
        if key == "program":
            got = set()
            for i, ln in enumerate(lines):
                m = re.match(r'^#\s+([A-Za-z_]\w*)\s+\(CPU 0x[0-9A-Fa-f]+\)\s*$', ln)
                if m:
                    got.add(m.group(1))
                elif ln.startswith("#") and "synthetic labels for internal helpers" in ln:
                    for eq in lines[i + 1:]:
                        mm = re.match(r'^\.equ\s+([A-Za-z_]\w*)\s*,', eq)
                        if not mm:
                            break
                        if not mm.group(1).endswith("_entry"):
                            got.add(mm.group(1))
            rated += sorted(got)
        else:
            for i, ln in enumerate(lines[:-1]):
                if re.match(r'^# ---- [A-Za-z_]\w* -*\s*$', ln):
                    for nx in lines[i + 1:]:
                        mm = re.match(r'^([A-Za-z_.$][\w.$]*):', nx)
                        if mm:
                            rated.append(mm.group(1))
                            break
                        if nx.strip() and not nx.lstrip().startswith("#"):
                            break
    c = collections.Counter()
    for n in rated:
        if any(pp.search(n) for pp in POSITIONAL):
            c["positional"] += 1
        elif GENERIC.search(n):
            c["generic"] += 1
        else:
            c["semantic"] += 1
    return c["semantic"], c["semantic"] + c["generic"] + c["positional"], dict(c)


def entry_tables():
    snaps = sorted(git("ls-files", "docs/coverage/dispatch-census-*.json").split())
    if not snaps:
        sys.exit("no committed dispatch census snapshot (make dispatch-census)")
    d = json.load(open(os.path.join(ROOT, snaps[-1])))
    res = {}
    for k, v in d["images"].items():
        n = v["framed"] + v["unframed_runs"]
        res[k] = (n - v["not_used"] - v["unframed_not_used"], n)
    return res, snaps[-1], d.get("head")


def bytes_understood(census_json):
    if not census_json:
        census_json = os.path.join(os.environ.get("TMPDIR") or os.path.expanduser("~/compartilhado/tmp"),
                                   "semantic-score-data-census.json")
        r = subprocess.run([sys.executable, os.path.join(ROOT, "scripts/analysis/data_range_census.py"),
                            "--json", census_json], cwd=ROOT, capture_output=True, text=True)
        if r.returncode:
            sys.exit("data_range_census.py failed:\n" + r.stdout[-2000:] + r.stderr[-2000:])
    res = {}
    for r in json.load(open(census_json))["results"]:
        t = r["totals"]
        res[r["key"]] = (t["CODE"] + t["KNOWN-A"] + t["FILLER"], r["size"])
    for key in KN7000:
        res[key] = kn7000_bytes(key)
    return res


def c_fields(model):
    named = total = 0
    for tree in C_TREES[model]:
        for p in glob.glob(os.path.join(ROOT, tree, "**", "*.[ch]"), recursive=True):
            if "/generated/" in p:
                continue
            text = open(p, "rb").read().decode("latin-1")
            text = re.sub(r'/\*.*?\*/', ' ', text, flags=re.S)
            text = re.sub(r'//[^\n]*', ' ', text)
            text = re.sub(r'__attribute__\s*\(\([^()]*(?:\([^()]*\)[^()]*)*\)\)', ' ', text)
            for body in re.findall(r'\b(?:struct|union)\b[^{;()]*\{([^{}]*)\}', text):
                for decl in body.split(";"):
                    decl = decl.strip()
                    mm = re.search(r'([A-Za-z_]\w*)\s*(\[[^\]]*\]\s*)*(:\s*\d+\s*)?$', decl)
                    if not decl or not mm or len(decl.split()) < 2:
                        continue
                    total += 1
                    named += 0 if placeholder_field(mm.group(1)) else 1
    return named, total


# ---- badges -----------------------------------------------------------------------------------------------
def colour(p):
    for lim, c in ((90, "#44cc11"), (80, "#97ca00"), (70, "#a4a61d"), (60, "#dfb317"), (40, "#fe7d37")):
        if p >= lim:
            return c
    return "#e05d44"


def badge(label, value, col):
    """A flat-square badge (the shields.io look) as plain SVG: two rectangles and two texts, so every renderer
    draws it the same."""
    w = lambda s: int(len(s) * 6.6 + 10)         # Verdana 11px
    lw, vw = w(label), w(value)
    return ('<svg xmlns="http://www.w3.org/2000/svg" width="{tw}" height="20" role="img" aria-label="{l}: {v}">'
            '<title>{l}: {v}</title>'
            '<rect width="{lw}" height="20" fill="#555555"/><rect x="{lw}" width="{vw}" height="20" fill="{c}"/>'
            '<g fill="#ffffff" text-anchor="middle" font-family="Verdana,Geneva,DejaVu Sans,sans-serif" '
            'font-size="11"><text x="{lx}" y="14">{l}</text><text x="{vx}" y="14">{v}</text></g></svg>\n').format(
        tw=lw + vw, lw=lw, vw=vw, c=col, l=label, v=value, lx=lw / 2, vx=lw + vw / 2)


def pct(n, d):
    return 100.0 * n / d if d else None


def main():
    args = sys.argv[1:]
    cj = args[args.index("--census-json") + 1] if "--census-json" in args else None
    entry, snap, snap_head = entry_tables()
    byt = bytes_understood(cj)
    comp = {}                                      # model -> component -> [num, den]
    detail = {}
    for model, keys in MODELS.items():
        c = {k: [0, 0] for k in ("bytes", "names", "entry", "fields")}
        for key in keys:
            n, d, cls = names(key)
            c["names"][0] += n
            c["names"][1] += d
            c["bytes"][0] += byt[key][0]
            c["bytes"][1] += byt[key][1]
            if key in entry:
                c["entry"][0] += entry[key][0]
                c["entry"][1] += entry[key][1]
            detail[key] = dict(names=cls, bytes=list(byt[key]), entry=list(entry.get(key, (0, 0))))
        c["fields"] = list(c_fields(model))
        comp[model] = c
    comp["all"] = {k: [sum(comp[m][k][0] for m in MODELS), sum(comp[m][k][1] for m in MODELS)]
                   for k in ("bytes", "names", "entry", "fields")}
    score = {}
    for m, c in comp.items():
        vals = [pct(*c[k]) for k in c if c[k][1]]
        score[m] = sum(vals) / len(vals)
    head = git("rev-parse", "--short=8", "HEAD")
    dirty = bool(git("status", "--porcelain", "--untracked-files=no"))
    day = datetime.date.today().isoformat()
    for m in ("all", "kn5000", "wsa1", "kn7000"):
        print("%-7s score %5.1f%%   " % (m, score[m]) + "   ".join(
            "%s %5.1f%% (%d/%d)" % (k, pct(*comp[m][k]), comp[m][k][0], comp[m][k][1])
            for k in ("bytes", "names", "entry", "fields") if comp[m][k][1]))
    print("measured at %s%s; entry from %s" % (head, " (+ uncommitted changes)" if dirty else "", snap))
    if "--print" in args:
        return
    os.makedirs(OUT, exist_ok=True)
    for m, lab in (("all", "semantic disasm"), ("kn5000", "KN5000 semantic"), ("wsa1", "SX-WSA1R semantic"),
                   ("kn7000", "SX-KN7000 semantic")):
        fn = "semantic-score.svg" if m == "all" else "semantic-score-%s.svg" % m
        open(os.path.join(OUT, fn), "w").write(badge(lab, "%.1f%%" % score[m], colour(score[m])))
    for k in ("bytes", "names", "entry", "fields"):
        p = pct(*comp["all"][k])
        open(os.path.join(OUT, "semantic-%s.svg" % k), "w").write(badge(LABEL[k], "%.1f%%" % p, colour(p)))
    json.dump(dict(date=day, head=head, dirty=dirty, rules=RULES, entry_snapshot=snap, entry_snapshot_head=snap_head,
                   score={m: round(v, 2) for m, v in score.items()},
                   components={m: {k: dict(num=v[0], den=v[1], pct=round(pct(*v), 2) if v[1] else None)
                                   for k, v in c.items()} for m, c in comp.items()},
                   images=detail), open(os.path.join(OUT, "semantic-score.json"), "w"), indent=1)
    hist = os.path.join(OUT, "semantic-score-history.csv")
    rows = list(csv.reader(open(hist))) if os.path.exists(hist) else []
    hdr = ["date", "commit", "score", "kn5000", "wsa1", "bytes", "names", "entry", "fields", "rules", "kn7000"]
    # rows from before rules 3 have no kn7000 column, and the oldest no rules column either (rules 1)
    rows = [r + ["1", ""][len(r) - 9:] if len(r) < 11 else r for r in rows[1:] if r and r[1] != head] if rows else []
    rows.append([day, head, "%.2f" % score["all"], "%.2f" % score["kn5000"], "%.2f" % score["wsa1"]] +
                ["%.2f" % pct(*comp["all"][k]) for k in ("bytes", "names", "entry", "fields")] + [str(RULES)] +
                ["%.2f" % score["kn7000"]])
    w = csv.writer(open(hist, "w", newline=""))
    w.writerow(hdr)
    w.writerows(rows)
    print("wrote %s/semantic-score*.svg, semantic-*.svg, semantic-score.json, semantic-score-history.csv"
          % os.path.relpath(OUT, ROOT))


if __name__ == "__main__":
    main()
