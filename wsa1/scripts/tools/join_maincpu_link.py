#!/usr/bin/env python3
r"""join_maincpu_link.py -- link prom_b and prom_a as ONE program (phase B3 of PLAN-join-and-split.md).

QUESTION THIS ANSWERS
    Can CPU 1's two EPROMs be linked as the one program they are, so that a name one image
    uses for the other's code is checked by the linker instead of copied in as a number?

    Before 2026-10-31 each image was linked on its own.  prom_b carried 1,809 `.set Name, addr`
    lines naming prom_a labels, prom_a carried 1,811 naming prom_b labels, and prom_a.ld defined
    10 more prom_b symbols by number.  The byte gate protected every VALUE but no NAME: a rename
    in one image left the other's equate stale until a separate `--check-equates` was run.

    Now both objects go into one ld.lld link (maincpu/maincpu.ld, output sections .prom_b at
    0xF00000 and .prom_a at 0xF80000), and llvm-objcopy cuts the two EPROM images out of it.
    Each image's block of address equates is gone.  The importing side now leaves the name
    undefined and the linker resolves it; the exporting side lists the labels the other image
    references in prom_X/exports.syms, and the Makefile makes exactly those global in the
    assembled object (`llvm-objcopy --globalize-symbols`).  A renamed or missing name now fails
    the link.

    ⚠ WHY A FILE AND NOT `.global` IN THE SOURCE -- measured, not taste.  llvm-mc resolves a
    branch to a LOCAL label at assembly time, but leaves a branch to a GLOBAL one to the linker
    and relaxes it to the long form: `.global Lab` / `jr z,Lab` assembles to the 3-byte `jrl`
    with an R_TLCS900_PC16, the local spelling to the 2-byte `jr` (this script's --selftest
    re-runs that comparison).  Declared in the source, the exports grew prom_a by 6 bytes and
    prom_b by 1 and the link overflowed both windows.  Globalizing after assembly keeps every
    encoding the firmware has.

    Labels that are not exported stay local to their object, which is why the three routines
    the program carries twice (maincpu/shared/*.s, included in both images) need no rename: each
    image's references still bind to its own copy, as in the firmware.  prom_a's two references to
    prom_b's copies keep the names PromB_LCD_ScreenRedraw_Begin / _End, now defined in prom_b
    as aliases of its copy rather than as numbers in prom_a.ld.

RUN (from wsa1/)
    python3 scripts/tools/join_maincpu_link.py --apply         # one-shot source rewrite (done 2026-10-31)
    python3 scripts/tools/join_maincpu_link.py --proof REV     # every old equate == the joined ELF's value
    python3 scripts/tools/join_maincpu_link.py --selftest      # the joined link's invariants

    --proof reads the two equate blocks and prom_a.ld as they were at REV (130735749 is the last
    revision with them) and checks that every name resolves, in rebuilt_ROMs/wsa1_maincpu.llvm.elf,
    to the very address the equate gave it.  Together with the byte gate this shows the rewrite
    moved no value and lost no name.
"""
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NM = os.path.expanduser("~/compartilhado/llvm-project/build/bin/llvm-nm")
ELF = os.path.join(ROOT, "rebuilt_ROMs", "wsa1_maincpu.llvm.elf")

IMAGES = {
    # file, marker of the block it carries, the image whose labels that block names
    "prom_a": ("prom_a/wsa1_prom_a.s", "prom_b ADDRESS EQUATES", "prom_b"),
    "prom_b": ("prom_b/wsa1_prom_b.s", "prom_a ADDRESS EQUATES", "prom_a"),
}
SET = re.compile(rb"^\s*\.set\s+([A-Za-z_][\w.]*)\s*,\s*(0x[0-9a-fA-F]+)\s*(;.*)?$")
LDSYM = re.compile(r"^([A-Za-z_]\w*)\s*=\s*(0x[0-9A-Fa-f]+);")
EXPORT_MARK = b"ADDRESS EQUATES RETIRED (scripts/tools/join_maincpu_link.py)"
ALIASES = [(b"PromB_LCD_ScreenRedraw_Begin", b"LCD_ScreenRedraw_Begin"),
           (b"PromB_LCD_ScreenRedraw_End", b"LCD_ScreenRedraw_End")]


def block(lines, marker):
    i = [k for k, l in enumerate(lines) if (b"BEGIN " + marker.encode()) in l]
    j = [k for k, l in enumerate(lines) if (b"END " + marker.encode()) in l]
    if len(i) != 1 or len(j) != 1:
        return None
    return i[0], j[0]


def equates(text, marker):
    """{name: (value, comment)} of the address-equate block."""
    L = text.split(b"\n")
    ij = block(L, marker)
    if ij is None:
        sys.exit("no %s block" % marker)
    out = {}
    for l in L[ij[0]:ij[1] + 1]:
        m = SET.match(l)
        if m:
            out[m.group(1)] = (int(m.group(2), 16), (m.group(3) or b"").strip())
        elif l.strip() and not l.startswith(b";"):
            sys.exit("unexpected line in %s block: %r" % (marker, l))
    return out


def ld_symbols(text):
    return {m.group(1).encode(): int(m.group(2), 16)
            for m in map(LDSYM.match, text.split("\n")) if m}


def notice(image, other):
    return [
        b"; >>> %s" % EXPORT_MARK,
        b"; This block held one `.set Name, <address>` per %s label this image references." % other.encode(),
        b"; Since 2026-10-31 prom_b and prom_a are linked as ONE program (maincpu/maincpu.ld): such a",
        b"; name is left undefined here and ld.lld resolves it to %s's own label, which" % other.encode(),
        b"; %s/exports.syms makes global after assembly.  A renamed or missing name fails the link." % other.encode(),
        b"; This image's own exports, the names %s references, are in %s/exports.syms." % (other.encode(), image.encode()),
        b"; <<< %s" % EXPORT_MARK,
    ]


def exports_file(image, names, comments, other):
    out = [b"# %s/exports.syms -- the %s labels %s references (GENERATED, scripts/tools/join_maincpu_link.py)" % (image.encode(), image.encode(), other.encode()),
           b"#",
           b"# The Makefile runs `llvm-objcopy --globalize-symbols=%s/exports.syms` on wsa1_%s.llvm.o" % (image.encode(), image.encode()),
           b"# before the joint link (maincpu/maincpu.ld), so %s's undefined references to these names" % other.encode(),
           b"# resolve to %s's labels.  Every other label stays local.  Why a file and not `.global` in" % image.encode(),
           b"# the source: a global label is a relocation, and llvm-mc relaxes a short branch to it to the",
           b"# long form, which changes the bytes (scripts/tools/join_maincpu_link.py docstring).",
           b"# A label renamed in %s and not here leaves %s's reference undefined: the link fails." % (image.encode(), other.encode()),
           b""]
    for n in sorted(names):
        c = comments.get(n, b"")
        out.append(n + ((b"	# " + c.lstrip(b"; ")) if c else b""))
    return b"\n".join(out) + b"\n"


def apply():
    texts = {k: open(os.path.join(ROOT, v[0]), "rb").read() for k, v in IMAGES.items()}
    old = {k: equates(texts[k], IMAGES[k][1]) for k in IMAGES}
    ldpath = os.path.join(ROOT, "prom_a/prom_a.ld")
    ld = open(ldpath).read()
    ldsyms = ld_symbols(ld)
    # names each image must EXPORT = names the other image's block (or prom_a.ld) imported
    exports = {"prom_b": dict((n, c) for n, (v, c) in old["prom_a"].items()),
               "prom_a": dict((n, c) for n, (v, c) in old["prom_b"].items())}
    for n in ldsyms:
        exports["prom_b"].setdefault(n, b"")
    for image, (path, marker, owner) in IMAGES.items():
        L = texts[image].split(b"\n")
        i, j = block(L, marker)
        # the block in THIS file named the OTHER image's labels; it is replaced by THIS
        # image's exports (the names the other image imported)
        L[i:j + 1] = notice(image, owner)
        texts[image] = b"\n".join(L)
        open(os.path.join(ROOT, image, "exports.syms"), "wb").write(
            exports_file(image, exports[image], exports[image], owner))
    # prom_b's copy of the twice-carried redraw pair gets the two names prom_a uses for it
    pb = os.path.join(ROOT, "prom_b/modules/f7d000_f7ffff_panel_screen_methods.s")
    t = open(pb, "rb").read()
    inc = b'\t.include "maincpu/shared/lcd_screen_redraw.s"\n'
    assert t.count(inc) == 1
    alias = (b"; prom_a calls THIS copy (its boot block, below 0xF80000's own copy) under these two names;\n"
             b"; they are prom_b's names for it, exported (prom_b/exports.syms), so the link checks them.\n")
    for a, b_ in ALIASES:
        alias += b"\t.set\t" + a + b", " + b_ + b"\n"
    t = t.replace(inc, inc + alias)
    open(pb, "wb").write(t)
    for image, (path, _, _) in IMAGES.items():
        open(os.path.join(ROOT, path), "wb").write(texts[image])
    # prom_a.ld: the numeric prom_b symbols go; the link defines them now
    k = ld.index("/* Cross-ROM: prom_b routines prom_a reaches by number")
    ld = ld[:k].rstrip("\n") + "\n\n/* prom_b symbols prom_a references are resolved by the joint link,\n * maincpu/maincpu.ld (scripts/tools/join_maincpu_link.py, 2026-10-31); this script is\n * now only the record of prom_a's own window. */\n"
    open(ldpath, "w").write(ld)
    print("rewrote %d + %d export lines" % (len(exports["prom_a"]), len(exports["prom_b"])))


def nm(elf):
    syms = {}
    for l in subprocess.run([NM, elf], capture_output=True, check=True).stdout.split(b"\n"):
        p = l.split()
        if len(p) == 3:
            syms.setdefault(p[2], set()).add(int(p[0], 16))
    return syms


def git_show(rev, path):
    top = subprocess.run(["git", "rev-parse", "--show-prefix"], cwd=ROOT, capture_output=True,
                         check=True, text=True).stdout.strip()
    return subprocess.run(["git", "show", "%s:%s%s" % (rev, top, path)], cwd=ROOT,
                          capture_output=True, check=True).stdout


def proof(rev):
    syms = nm(ELF)
    bad = n = 0
    for image, (path, marker, owner) in IMAGES.items():
        lo, hi = (0xF00000, 0xF80000) if owner == "prom_b" else (0xF80000, 0x1000000)
        for name, (v, c) in equates(git_show(rev, path), marker).items():
            n += 1
            got = syms.get(name, set())
            if v not in got:
                bad += 1
                print("MOVED %s: equate 0x%06x, joined ELF %s" % (name.decode(), v, sorted(map(hex, got))))
            elif not lo <= v < hi:
                bad += 1
                print("WRONG IMAGE %s 0x%06x" % (name.decode(), v))
    for name, v in ld_symbols(git_show(rev, "prom_a/prom_a.ld").decode()).items():
        n += 1
        if v not in syms.get(name, set()):
            bad += 1
            print("MOVED %s (prom_a.ld) 0x%06x" % (name.decode(), v))
    print("proof against %s: %d names, %d moved" % (rev, n, bad))
    return bad == 0


def selftest():
    fails = 0

    def check(ok, what):
        nonlocal fails
        print(("ok    " if ok else "FAIL  ") + what)
        fails += not ok
    texts = {k: open(os.path.join(ROOT, v[0]), "rb").read() for k, v in IMAGES.items()}
    for k, (path, marker, _) in IMAGES.items():
        check(block(texts[k].split(b"\n"), marker) is None, "%s has no address-equate block" % path)
        check(texts[k].count(EXPORT_MARK) == 2, "%s carries the retirement notice" % path)
    ld = open(os.path.join(ROOT, "prom_a/prom_a.ld")).read()
    check(not ld_symbols(ld), "prom_a.ld defines no symbol by number")
    syms = nm(ELF)
    exp = {}
    for k in IMAGES:
        exp[k] = [l.split(b"\t")[0] for l in open(os.path.join(ROOT, k, "exports.syms"), "rb").read().split(b"\n")
                  if l and not l.startswith(b"#")]
    lo = {"prom_b": (0xF00000, 0xF80000), "prom_a": (0xF80000, 0x1000000)}
    for k, names in exp.items():
        wrong = [n for n in names if not any(lo[k][0] <= v < lo[k][1] for v in syms.get(n, ()))]
        check(not wrong, "every %s export (%d) is defined inside %s's window%s"
              % (k, len(names), k, (": " + b", ".join(wrong[:5]).decode()) if wrong else ""))
    for a, b_ in ALIASES:
        check(syms.get(a) == syms.get(b_ + b"") or (syms.get(a, set()) & syms.get(b_, set())),
              "%s aliases prom_b's %s" % (a.decode(), b_.decode()))
    for dup in (b"IndexedTable_GetPtr", b"LCD_ScreenRedraw_Begin", b"LCD_ScreenRedraw_End"):
        v = sorted(syms.get(dup, ()))
        check(len(v) == 2 and v[0] < 0xF80000 <= v[1], "%s is local to both images (%s)" % (dup.decode(), [hex(x) for x in v]))
    # the measurement behind exports.syms: in an OBJECT (not -show-encoding, which never relaxes)
    # a short branch to a global label is relaxed to the long form
    import tempfile
    bindir = os.path.expanduser("~/compartilhado/llvm-project/build/bin")
    scratch = os.environ.get("TMPDIR") or os.path.expanduser("~/compartilhado/tmp")
    sizes = {}
    with tempfile.TemporaryDirectory(prefix="joinlink_", dir=scratch) as d:
        for g in (True, False):
            s, o = os.path.join(d, "t.s"), os.path.join(d, "t.o")
            open(s, "w").write((".global Lab\n" if g else "") + "jr z, Lab\nnop\nLab: nop\n")
            subprocess.run([os.path.join(bindir, "llvm-mc"), "-triple=tlcs900", "-filetype=obj", "-o", o, s], check=True)
            h = subprocess.run([os.path.join(bindir, "llvm-objdump"), "-h", o], capture_output=True, text=True).stdout
            sizes[g] = int([l.split()[2] for l in h.splitlines() if " .text " in l][0], 16)
    check(sizes[True] == sizes[False] + 1, "a branch to a .global label assembles 1 byte longer (%d) than to a local one (%d)"
          % (sizes[True], sizes[False]))
    print("FAILURES: %d" % fails)
    return fails == 0


if __name__ == "__main__":
    a = sys.argv[1:]
    if a == ["--apply"]:
        apply()
    elif len(a) == 2 and a[0] == "--proof":
        sys.exit(0 if proof(a[1]) else 1)
    elif a == ["--selftest"]:
        sys.exit(0 if selftest() else 1)
    else:
        sys.exit(__doc__)
