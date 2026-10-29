#!/usr/bin/env python3
r"""hdae5000_gui_readability.py -- how much of the HD-AE5000 GUI source is still numbers?

QUESTION ANSWERED
-----------------
"Can a reader see the HD-AE5000's screens in the source, or only numbers?"  Per tree
(hdae5000/ = v2.06i, hdae5000_v2_01i/ = v2.01i) it counts, over the GUI's source -- the UI
object records (ROM pool and .data image), the object table, the object-id constants and
the UI state block -- :

  objects           UI objects (records)
  class_numeric     class ids written as numbers (0x016S_KKKK) instead of by class name
  links_numeric     super / sub / next / prev links written as numeric object indices
  addr_numeric      fields holding an address or an id (RAM pointer, object, function or
                    title id, string pointer), object-table entries and object-id
                    constants, written as numbers
  fields_unnamed    record words with no field name ("class body", "attribute word", raw
                    .short runs) or with a placeholder name (field_*)
  state_unlabelled  words of the UI state block (the RAM variables the records point at)
                    under no variable label
  style_numeric     (new form only; informative) font, colour, border, icon, style, alignment
                    and line-mode values: named fields whose VALUES are still plain numbers
                    (ids into the main CPU's resource tables that no firmware name was found for),
                    defaults included

It reads either form of the source: the typed records of before 2026-10-29 (pool in
hdae5000_data_tables.s, RAM records as .short runs under HDAE5000_WindowGeometry_Init) or
the tree written by scripts/converters/hdae5000_ui_tree.py (hdae5000_ui_tree.s and the
ui_ram_records block), so a before / after comparison is one run per revision.

RUN (repo root)
    python3 scripts/analysis/hdae5000_gui_readability.py            # the working tree
    python3 scripts/analysis/hdae5000_gui_readability.py --rev 9dbc03088
Read-only; prints one Markdown table.
"""
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TREES = ["hdae5000", "hdae5000_v2_01i"]
METRICS = ["objects", "class_numeric", "links_numeric", "addr_numeric", "fields_unnamed", "state_unlabelled",
           "style_numeric"]
NUM = re.compile(r"^-?(0x[0-9a-fA-F]+|\d+)$")
# propdata letters of fields that hold an address or an id
ADDR_TYPES = set("mnrsNtajkX")
STYLE_TYPES = set("c^_bfdg")


def read(rev, path):
    if rev is None:
        p = os.path.join(ROOT, path)
        return open(p, "rb").read().decode("latin-1") if os.path.exists(p) else None
    r = subprocess.run(["git", "show", "%s:%s" % (rev, path)], cwd=ROOT, capture_output=True)
    return r.stdout.decode("latin-1") if r.returncode == 0 else None


def code(ln):
    q = False
    for k, ch in enumerate(ln):
        if ch == '"':
            q = not q
        elif ch == ";" and not q:
            return ln[:k], ln[k:]
    return ln, ""


def values(c):
    m = re.match(r"^\s*(?:[A-Za-z_.][\w.]*:)?\s*\.(short|long|byte|word)\s+(.*)$", c)
    return [x.strip() for x in m.group(2).split(",")] if m else []


def split_args(s):
    out, cur, q = [], "", False
    for ch in s:
        if ch == '"':
            q = not q
        if ch == "," and not q:
            out.append(cur.strip())
            cur = ""
        else:
            cur += ch
    if cur.strip():
        out.append(cur.strip())
    return out


def is_num(t):
    return bool(NUM.match(t.strip()))


def old_form(dt, init):
    m = dict.fromkeys(METRICS[:-1], 0)
    L = dt.split("\n")
    k0 = next(k for k, l in enumerate(L) if l.startswith("; HD-AE5000 UI OBJECT DESCRIPTOR POOL"))
    k1 = next(k for k, l in enumerate(L) if l.startswith("HdaeUiName_000:"))
    for l in L[k0:k1]:
        c, com = code(l)
        if re.match(r"^HdaeUiObj_\d+:", c):
            m["objects"] += 1
        v = values(c)
        if not v:
            if re.match(r"^\s*\.equ\s+HDAE5000_OBJ_\w+\s*,\s*0x", c):
                m["addr_numeric"] += 1
            continue
        if "+0x00 class id" in com:
            m["class_numeric"] += sum(map(is_num, v))
        elif "parent, first child" in com:
            m["links_numeric"] += sum(map(is_num, v))
        elif "attribute word" in com:
            m["fields_unnamed"] += len(v)
        elif "class body" in com:
            m["fields_unnamed"] += len(v)
        elif c.strip().startswith(".long"):
            m["addr_numeric"] += sum(1 for x in v if is_num(x) and int(x, 0) >= 0x10000)
    # the .data image: state block, then the RAM records
    I = init.split("\n")
    s0 = next(k for k, l in enumerate(I) if l.startswith("HDAE5000_WindowState_Init:"))
    g0 = next(k for k, l in enumerate(I) if l.startswith("HDAE5000_WindowGeometry_Init:"))
    g1 = next(k for k, l in enumerate(I) if l.startswith("HDAE5000_ScreenProc_Table:"))
    for l in I[s0:g0]:
        m["state_unlabelled"] += len(values(code(l)[0]))
    words = []
    for l in I[g0:g1]:
        c, com = code(l)
        v = values(c)
        if c.strip().startswith(".long"):
            m["addr_numeric"] += sum(map(is_num, v))
        else:
            words += v
    m["state_unlabelled"] += 4               # the four 0xffff words before the first record
    nrec = 20
    m["objects"] += nrec
    m["class_numeric"] += nrec
    m["links_numeric"] += 4 * nrec
    m["fields_unnamed"] += len(words) - 4 - 2 * nrec - 4 * nrec
    return m


def macro_defaults():
    t = read(None, "hdae5000/shared/naka_ui_macros.s") or ""
    out = {}
    for l in t.split("\n"):
        mm = re.match(r"^\t\.macro\t(\w+) ([^;]*)", l)
        if mm:
            out[mm.group(1)] = dict(p.strip().split("=", 1) for p in mm.group(2).split(",") if "=" in p)
    return out


def macro_types():
    t = read(None, "hdae5000/shared/naka_ui_macros.s") or ""
    types, cur = {}, None
    for l in t.split("\n"):
        mm = re.match(r"^; (\w+) -- class id 0x", l)
        if mm:
            cur = types.setdefault(mm.group(1), {})
            continue
        mm = re.match(r"^;\s+\+\d+\s+(\w+)\s+.*\((.)\)$", l)
        if mm and cur is not None:
            cur[mm.group(1)] = mm.group(2)
    return types


def new_form(tree_s, init, types, defaults):
    m = dict.fromkeys(METRICS, 0)

    def obj(line):
        c = code(line)[0].strip()
        if not c:
            return
        w = c.split(None, 1)
        if w[0] == "ui_ram_object":
            m["objects"] += 1
            return
        if w[0] not in types:
            v = values(c)
            m["fields_unnamed"] += len(v)
            return
        if len(w) < 2:
            return
        a = split_args(w[1])
        given = dict(x.split("=", 1) for x in a[1:] if "=" in x)
        for k, ch in types[w[0]].items():
            if ch in STYLE_TYPES:
                v = given.get(k, defaults.get(w[0], {}).get(k))
                if v is not None and is_num(v):
                    m["style_numeric"] += 1
        for x in a[1:]:
            k, _, val = x.partition("=")
            k = k.strip()
            val = val.strip()
            ch = types[w[0]].get(k[:-3] if k.endswith("_at") else k, "")
            if k.startswith("field_"):
                m["fields_unnamed"] += 1
            if is_num(val) and ((ch in ADDR_TYPES and int(val, 0) not in (0,)) or int(val, 0) >= 0x10000):
                m["addr_numeric"] += 1
        return True

    on = False
    for l in tree_s.split("\n"):
        c = code(l)[0].strip()
        if c.startswith(".include"):
            on = True
            continue
        if c == "ui_tree_end":
            on = False
            continue
        if not on or not c:
            continue
        w = c.split(None, 1)[0]
        if w in types:
            m["objects"] += 1
            obj(l)
        elif w == "ui_ram_object":
            obj(l)
        elif w.startswith(".") and w not in (".set", ".equ", ".balign", ".asciz", ".ascii"):
            m["fields_unnamed"] += len(values(c))
        elif re.match(r"^\s*\.equ\s+HDAE5000_OBJ_", c):
            m["addr_numeric"] += 1
    # the object table must be generated, not a list of numbers
    t = tree_s.split("\n")
    for l in t:
        c = code(l)[0]
        if re.match(r"^\s*\.long\s+0x", c):
            m["addr_numeric"] += 1
    I = init.split("\n")
    s0 = next(k for k, l in enumerate(I) if l.startswith("; UI run-time state"))
    r0 = next(k for k, l in enumerate(I) if l.strip() == "ui_ram_records")
    r1 = next(k for k, l in enumerate(I) if l.strip() == "ui_ram_records_end")
    labelled = False
    for l in I[s0:r0]:
        c = code(l)[0]
        mm = re.match(r"^([A-Za-z_]\w*):", c)
        if mm:
            labelled = mm.group(1).startswith("HdaeUiVar_")
        v = values(c)
        if v and not labelled:
            m["state_unlabelled"] += len(v)
    for l in I[r0 + 1:r1]:
        obj(l)
    return m


def measure(rev):
    types = macro_types()
    out = {}
    for t in TREES:
        tree_s = read(rev, t + "/hdae5000_ui_tree.s")
        init = read(rev, t + "/hdae5000_init_data.s")
        if tree_s is not None:
            out[t] = new_form(tree_s, init, types, macro_defaults())
        else:
            dt = read(rev, t + "/hdae5000_data_tables.s")
            out[t] = old_form(dt, init) if dt else None
    return out


def main():
    rev = sys.argv[sys.argv.index("--rev") + 1] if "--rev" in sys.argv else None
    res = measure(rev)
    rows = [["tree"] + METRICS]
    for t, m in res.items():
        if m:
            rows.append([t] + ["{:,}".format(m[k]) if k in m else "-" for k in METRICS])
    w = [max(len(r[k]) for r in rows) for k in range(len(rows[0]))]
    print("source: %s" % (rev or "working tree"))
    for n, r in enumerate(rows):
        print("| " + " | ".join(x.ljust(w[k]) for k, x in enumerate(r)) + " |")
        if n == 0:
            print("|" + "|".join("-" * (x + 2) for x in w) + "|")


if __name__ == "__main__":
    main()
