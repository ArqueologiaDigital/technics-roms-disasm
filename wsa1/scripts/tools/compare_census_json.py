#!/usr/bin/env python3
"""compare_census_json.py -- did a source-layout change move anything in the dispatch census?

QUESTION IT ANSWERS
  A change that only moves lines between files (the CPU 1 module split,
  scripts/tools/split_cpu1_images.py) must leave every table the census finds, every entry and
  every verdict exactly as it was.  Only the `file:line` strings may change.  This compares two
  `census.py --json` dumps (census_keys.py takes the same flag) field by field, with every
  `<path>:<line>` string -- the `file` of a table and the `marker` of a stale group -- either
  ignored or, with --map, translated back to the pre-split listing's line numbers first.

RUN (repository root; the two dumps come from census_keys.py ... --json FILE)
    python3 wsa1/scripts/tools/compare_census_json.py BEFORE.json AFTER.json
    python3 wsa1/scripts/tools/compare_census_json.py BEFORE.json AFTER.json --map
  --map: AFTER's `prom_X/modules/<part>.s:<n>` is translated to `prom_X/wsa1_prom_X.s:<n'>`, n'
  being the line that part's line n held in the joined listing (split_cpu1_images.joined()), so
  the comparison then also checks that every reference points at the SAME source line.
Exit 0 = identical (under the chosen rule), 1 = a difference, printed.
"""
import importlib.util
import json
import os
import re
import sys

WSA1 = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LOC = re.compile(r'^(prom_[a-d]/[^:\s]+\.s):(\d+)$')


def part_offsets():
    """{part rel path: line index in the joined listing of its first line}."""
    spec = importlib.util.spec_from_file_location("split", os.path.join(WSA1, "scripts", "tools",
                                                                         "split_cpu1_images.py"))
    s = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(s)
    off = {}
    cwd = os.getcwd()
    os.chdir(WSA1)
    try:
        for img in ("prom_a", "prom_b"):
            root = s.read_lines(s.root_path(img))
            if s.BEGIN not in root:
                continue
            pos = root.index(s.BEGIN)
            for ln in root[root.index(s.BEGIN) + 1:root.index(s.END)]:
                m = s.INCLUDE_RE.match(ln)
                if m:
                    off[m.group(1)] = (img, pos)
                    pos += len(s.read_lines(os.path.join(WSA1, m.group(1))))
    finally:
        os.chdir(cwd)
    return off


def norm(x, mode, off):
    if isinstance(x, dict):
        return {k: norm(v, mode, off) for k, v in x.items()}
    if isinstance(x, list):
        return [norm(v, mode, off) for v in x]
    if isinstance(x, str):
        m = LOC.match(x)
        if m:
            if mode == "ignore":
                return "<loc>"
            rel, n = m.group(1), int(m.group(2))
            if rel in off:
                img, base = off[rel]
                return "%s/wsa1_%s.s:%d" % (img, img, base + n)
        elif mode == "ignore" and re.match(r'^prom_[a-d]/\S+\.s$', x):
            return "<file>"
    return x


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    mode = "map" if "--map" in sys.argv else "ignore"
    a = json.load(open(sys.argv[1]))
    b = json.load(open(sys.argv[2]))
    off = part_offsets() if mode == "map" else {}
    na, nb = norm(a, mode, {}), norm(b, mode, off)
    if mode == "map":
        # the directory's table `file` is a bare path, not a location: compare it ignoring files
        for d in (na, nb):
            for key in d:
                for t in d[key].get("tables", []):
                    if LOC.match(t.get("file", "")) is None and t.get("file", "").endswith(".s"):
                        t["file"] = "<file>"
    bad = 0
    for key in sorted(set(na) | set(nb)):
        if na.get(key) == nb.get(key):
            print("%-8s identical (%s)" % (key, "locations mapped to the joined listing" if mode == "map"
                                          else "file:line strings ignored"))
            continue
        bad += 1
        ta, tb = na.get(key, {}).get("tables", []), nb.get(key, {}).get("tables", [])
        print("%-8s DIFFERS: %d vs %d tables" % (key, len(ta), len(tb)))
        for x, y in zip(ta, tb):
            if x != y:
                print("   first differing table: %s\n   vs %s" % (json.dumps(x)[:300], json.dumps(y)[:300]))
                break
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
