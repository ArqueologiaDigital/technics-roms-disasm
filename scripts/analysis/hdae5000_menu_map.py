#!/usr/bin/env python3
r"""hdae5000_menu_map.py -- the HD-AE5000 GUI as a browsable Markdown map, from the source.

QUESTION ANSWERED
-----------------
"Which screens does the HD-AE5000 have, what is on each, and where does each button,
page switch and EXIT lead?"  The answer is read from the SOURCE, not from the ROM:
<tree>/hdae5000_ui_tree.s (the object tree, one class-macro line per object, nested by
ui_sub / ui_endsub), the RAM-object records in <tree>/hdae5000_init_data.s, the class
macros' parameters and defaults in hdae5000/shared/naka_ui_macros.s, and the code's
uses of HDAE5000_OBJ_<name> in the tree's other .s files.  For every top-level object
(a screen, window or dialog) it lists its class, caption, geometry, where it is opened
from (object-id fields of other objects -- AcScreenMenu.screen, IvExitScreen.screen,
IvPageControl.window ... -- and routines that name its object id), and its children,
nested, each with class, caption, handler function and destination.

The map is committed as notes/data-gui-hdae5000-2026-10-29/menu-map-<ver>.md; `make gate`
runs this script with --check, which fails when the committed map is not what the
source gives.

RUN (from the repo root)
    python3 scripts/analysis/hdae5000_menu_map.py            # rewrite both maps
    python3 scripts/analysis/hdae5000_menu_map.py --check    # compare, exit 1 if stale
"""
import collections
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TREES = {"v2_06i": ("hdae5000", "v2.06i"), "v2_01i": ("hdae5000_v2_01i", "v2.01i")}
MACROS = os.path.join(ROOT, "hdae5000", "shared", "naka_ui_macros.s")
OUT = os.path.join(ROOT, "notes", "data-gui-hdae5000-2026-10-29")
CODE = ("hd-ae5000_*.s", "hdae5000_hd_driver.s", "hdae5000_filesystem.s",
        "hdae5000_ui_display.s", "hdae5000_utilities.s")
LINK_FIELDS = {"N": "opens", "t": "window"}


def split_args(s):
    out, cur, q, esc = [], "", False, False
    for ch in s:
        if esc:
            cur += ch
            esc = False
        elif ch == "\\" and q:
            cur += ch
            esc = True
        elif ch == '"':
            cur += ch
            q = not q
        elif ch == "," and not q:
            out.append(cur.strip())
            cur = ""
        else:
            cur += ch
    if cur.strip():
        out.append(cur.strip())
    return out


def strip_comment(s):
    q = False
    for k, ch in enumerate(s):
        if ch == '"':
            q = not q
        elif ch == ";" and not q:
            return s[:k]
    return s


def load_classes():
    """{class: dict(params [(name, default)], types {field: letter}, cid)}"""
    text = open(MACROS, "rb").read().decode("latin-1").split("\n")
    classes, cur = {}, None
    for ln in text:
        m = re.match(r"^; (\w+) -- class id (0x[0-9a-f]+)", ln)
        if m:
            cur = classes.setdefault(m.group(1), dict(cid=int(m.group(2), 16), types={}, params=[]))
            continue
        m = re.match(r"^;\s+\+(\d+)\s+(\w+)\s+.*\((.)\)$", ln)
        if m and cur is not None:
            cur["types"][m.group(2)] = m.group(3)
            continue
        m = re.match(r"^\t\.macro\t(\w+) ([^;]*)", ln)
        if m and m.group(1) in classes:
            ps = []
            for p in split_args(m.group(2)):
                k, _, d = p.partition("=")
                ps.append((k, d if _ else None))
            classes[m.group(1)]["params"] = ps
    return classes


def parse_tree(tree, classes):
    objs, stack, last = [], [], None
    path = os.path.join(ROOT, tree, "hdae5000_ui_tree.s")
    for no, raw in enumerate(open(path, "rb").read().decode("latin-1").split("\n"), 1):
        ln = strip_comment(raw).rstrip()
        body = ln.strip()
        if not body:
            continue
        word = body.split(None, 1)[0]
        if word == "ui_sub":
            stack.append(last)
            continue
        if word == "ui_endsub":
            stack.pop()
            continue
        if word == "ui_tree_end":
            break
        if word == "ui_ram_object":
            a = split_args(body.split(None, 1)[1])
            o = dict(name=a[0], cls=a[1], args={}, ram=True, line=no)
        elif word in classes:
            a = split_args(body.split(None, 1)[1])
            o = dict(name=a[0], cls=word, ram=False, line=no,
                     args=dict(x.split("=", 1) for x in a[1:]))
        else:
            continue
        o["parent"] = stack[-1] if stack else None
        o["children"] = []
        o["i"] = len(objs)
        if o["parent"] is not None:
            o["parent"]["children"].append(o)
        objs.append(o)
        last = o
    by = {o["name"]: o for o in objs}
    # the RAM objects' records
    init = os.path.join(ROOT, tree, "hdae5000_init_data.s")
    on = False
    for no, raw in enumerate(open(init, "rb").read().decode("latin-1").split("\n"), 1):
        body = strip_comment(raw).strip()
        if body == "ui_ram_records":
            on = True
            continue
        if body == "ui_ram_records_end":
            break
        if on and body:
            word, rest = body.split(None, 1)
            a = split_args(rest)
            o = by[a[0]]
            o["args"] = dict(x.split("=", 1) for x in a[1:])
            o["ram_line"] = no
    for o in objs:
        full = {}
        for k, d in classes[o["cls"]]["params"]:
            if k == "obj":
                continue
            if k in o["args"]:
                full[k] = o["args"][k]
            elif d is not None:
                full[k] = d
        o["full"] = full
    return objs, by


def code_refs(tree):
    out = collections.defaultdict(list)
    lab = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*):")
    use = re.compile(r"HDAE5000_OBJ_([A-Za-z0-9_]+)")
    for pat in CODE:
        for f in sorted(glob.glob(os.path.join(ROOT, tree, pat))):
            cur = None
            for ln in open(f, "rb").read().decode("latin-1").split("\n"):
                m = lab.match(ln)
                if m and not re.search(r"_(Skip|Loop)\d+$", m.group(1)):
                    cur = m.group(1)
                code = strip_comment(ln)
                if code.lstrip().startswith(".equ"):
                    continue
                for n in use.findall(code):
                    if cur and cur not in out[n]:
                        out[n].append(cur)
    return out


def table(rows, head):
    w = [max(len(str(r[k])) for r in rows + [head]) for k in range(len(head))]
    fmt = lambda r: "| " + " | ".join(str(c).ljust(w[k]) for k, c in enumerate(r)) + " |"
    return [fmt(head), "|" + "|".join("-" * (x + 2) for x in w) + "|"] + [fmt(r) for r in rows]


def caption(o):
    for k in ("title", "str", "text", "caption", "stron", "stroff"):
        v = o["full"].get(k)
        if v and v.startswith('"') and v != '""':
            return v
    for k in ("title_at", "str_at", "text_at", "caption_at", "stron_at"):
        v = o["full"].get(k)
        if v and v != "0":
            return "`%s`" % v
    return ""


def root_of(o):
    while o["parent"] is not None:
        o = o["parent"]
    return o


def anchor(name):
    return name.lower()


def target(by, val):
    if val.startswith("HDAE5000_OBJ_") and val[13:] in by:
        t = by[val[13:]]
        r = root_of(t)
        if r is t:
            return "[%s](#%s)" % (t["name"], anchor(t["name"]))
        return "[%s](#%s) (in %s)" % (t["name"], anchor(r["name"]), r["name"])
    if val == "NAKA_NO_OBJECT":
        return "-"
    return "`%s`" % val


def describe(o, classes, by, with_caption=True):
    """One line: what the object shows and does."""
    t = classes[o["cls"]]["types"]
    parts = []
    cap = caption(o)
    if cap and with_caption:
        parts.append(cap)
    for k, v in o["full"].items():
        ch = t.get(k) or ""
        if ch in LINK_FIELDS and v != "NAKA_NO_OBJECT":
            parts.append("%s %s" % (LINK_FIELDS[ch], target(by, v)))
        elif ch and ch in "jk" and v not in ("NAKA_APFUNC_DefaultFunction", "NAKA_APFUNC_LanguageTextReturn") \
                and not re.match(r"^0x0*1[24]0000+$", v):
            parts.append("%s `%s`" % (k, v))
        elif ch == "a" and k == "exit":
            parts.append("EXIT -> `%s`" % v)
        elif ch == "b" and k == "icon" and v != "0":
            parts.append("icon %s" % v)
        elif ch == "e" and v.startswith("ES_") and v != "ES_None":
            parts.append("switch %s" % v[3:])
        elif k == "index" and o["cls"].startswith("AcLanguageText"):
            parts.append("text #%s" % v)
    return "; ".join(parts)


def render(ver, tree, tag, classes):
    objs, by = parse_tree(tree, classes)
    refs = code_refs(tree)
    opened = collections.defaultdict(list)
    for o in objs:
        t = classes[o["cls"]]["types"]
        for k, v in o["full"].items():
            if t.get(k) in LINK_FIELDS and v.startswith("HDAE5000_OBJ_") and v[13:] in by:
                opened[v[13:]].append((o, k))
    roots = [o for o in objs if o["parent"] is None]
    L = []
    w = L.append
    w("# HD-AE5000 %s GUI menu map" % tag)
    w("")
    w("GENERATED by `scripts/analysis/hdae5000_menu_map.py` from `%s/hdae5000_ui_tree.s` (the object" % tree)
    w("tree), the RAM-object records in `%s/hdae5000_init_data.s` and the class macros in" % tree)
    w("`hdae5000/shared/naka_ui_macros.s`. Do not edit: change the source and rerun; `make gate` checks it.")
    w("")
    w("%d objects in %d top-level trees (screens, windows, dialogs). An object's id is" % (len(objs), len(roots)))
    w("`HDAE5000_OBJ_<name>` = 0x007F0000 + its index. \"Opened by\" lists the object-id fields of other")
    w("objects that name it (an `AcScreenMenu.screen` button, an `IvExitScreen.screen` EXIT, an")
    w("`IvPageControl.window` page switch) and the routines whose code names its id. Names in")
    w("CAPITALS (and a few mixed-case ones) are the firmware's own resource names; the others were")
    w("made up from the parent and the caption or class. `text #n` is entry n of the language text")
    w("the object draws (AcLanguageText1, via `NAKA_APFUNC_LanguageTextReturn`); the texts are not in")
    w("this ROM. `switch` is the LCD button the object answers to (its `editsw`, by the firmware's")
    w("`ES_*` names): Bottom1-8 under the display, Left1-5 / Right1-5 the side rows, top to bottom.")
    w("")
    w("## Index")
    w("")
    rows = []
    for r in roots:
        n = sum(1 for _ in walk(r)) - 1
        src = len(opened.get(r["name"], [])) + len(refs.get(r["name"], []))
        rows.append(("[%s](#%s)" % (r["name"], anchor(r["name"])), r["cls"], caption(r) or "-",
                     n, src, "%s:%d" % ("hdae5000_ui_tree.s", r["line"])))
    L += table(rows, ("object", "class", "caption", "children", "opened by", "source"))
    for r in roots:
        w("")
        w("## %s" % r["name"])
        w("")
        f = r["full"]
        w("- class `%s`%s, %s" % (r["cls"], (", caption " + caption(r)) if caption(r) else "",
                                  "x %s, y %s, %s x %s" % (f.get("x"), f.get("y"), f.get("w"), f.get("h"))
                                  if "x" in f else "record in RAM"))
        d = describe(r, classes, by, with_caption=False)
        if d:
            w("- %s" % d)
        src = ["`%s.%s`" % (o["name"], k) for o, k in opened.get(r["name"], [])]
        if src:
            w("- opened by: " + ", ".join(src))
        if refs.get(r["name"]):
            w("- named in code by: " + ", ".join("`%s`" % x for x in refs[r["name"]]))
        w("- source: `%s/hdae5000_ui_tree.s` line %d" % (tree, r["line"]))
        if r["children"]:
            w("")
            for o, depth in walk(r):
                if o is r:
                    continue
                d = describe(o, classes, by)
                extra = []
                if opened.get(o["name"]):
                    extra.append("opened by " + ", ".join("`%s.%s`" % (s["name"], k)
                                                          for s, k in opened[o["name"]]))
                if refs.get(o["name"]):
                    extra.append("code: " + ", ".join("`%s`" % x for x in refs[o["name"]]))
                w("%s- `%s` %s%s%s%s" % ("  " * (depth - 1), o["name"], o["cls"],
                                        " (RAM record)" if o["ram"] else "",
                                        (": " + d) if d else "",
                                        (" -- " + "; ".join(extra)) if extra else ""))
    return "\n".join(L) + "\n"


def walk(o, d=0):
    yield o, d
    for c in o["children"]:
        yield from walk(c, d + 1)


def main():
    check = "--check" in sys.argv
    classes = load_classes()
    bad = 0
    for ver, (tree, tag) in TREES.items():
        text = render(ver, tree, tag, classes)
        p = os.path.join(OUT, "menu-map-%s.md" % ver)
        if check:
            old = open(p).read() if os.path.exists(p) else ""
            if old != text:
                print("STALE %s (rerun scripts/analysis/hdae5000_menu_map.py)" % os.path.relpath(p, ROOT))
                bad = 1
            else:
                print("OK    %s is what the source gives" % os.path.relpath(p, ROOT))
        else:
            os.makedirs(OUT, exist_ok=True)
            open(p, "w").write(text)
            print("wrote", os.path.relpath(p, ROOT))
    sys.exit(bad)


if __name__ == "__main__":
    main()
