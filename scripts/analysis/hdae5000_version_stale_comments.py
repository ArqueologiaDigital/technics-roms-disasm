#!/usr/bin/env python3
"""Which comments of a ported HD-AE5000 tree still quote a v2.06i number?

QUESTION ANSWERED
    scripts/tools/port_hdae5000_version.py rewrites the CODE of a source line (a
    literal, a constant, a label) and keeps its comment.  When the comment quotes
    the number the code used to hold -- `ld xbc, 0xf4ce ; Count = 62,762 bytes`,
    `lda xbc, (0x23a055:24) ; XBC = 0x23A0D2` -- the comment is now wrong for the
    version.  This pairs every line of the version tree with its v2.06i twin (a
    line-level diff of each file; a changed line is paired when its replace block
    has as many lines on both sides), takes the numbers that left the code part,
    and lists the paired lines whose comment still quotes one of them (as hex,
    any case or width, or as decimal with or without thousands commas).

    With --fix, a quoted number that is hex is replaced by the new value in the
    same width and case; a decimal one by the new value in decimal (with commas if
    the old one had them).  A comment where the old and new numbers cannot be paired
    one to one is only listed.

    That first check (TEXT) only sees lines whose source text changed.  A line
    whose text is the same but assembles to other bytes -- a symbolic operand
    whose constant or label moved -- keeps a comment that quotes v2.06i's value.
    Three more checks read the assembled bytes of both trees (the porting tool's
    marker build, which knows the bytes every source line emits):

      BYTES  a trailing comment that is a byte dump (`; f2 9a a0 23 60`, `xx` for
             a byte the dump leaves open) is compared with the bytes its line
             emits; a dump of the same length is rewritten from them.
      OPER   every line is paired with its v2.06i twin (difflib over each file);
             where the twins emit as many bytes but different ones, each changed
             24-bit window (and 16-bit, for `pushw` halves) that holds a RAM or
             ROM address gives an old -> new pair, and a comment quoting the old
             value (as a whole 24-bit number, or as 0xHH + the 16-bit half) is
             rewritten to the new one.
      SYM    the trailing comment of a byte-emitting line that quotes, as hex,
             the v2.06i value of a symbol both trees define (a label, or an
             HDAE5000_RAM_* / other `.equ` address in 0x200000-0x2fffff) whose
             v2.01i value differs; it is rewritten when every such symbol moved
             to the same value, the quoted number is no v2.01i symbol's value,
             the comment quotes no address range (rewriting one end of a range
             would leave the other end and its size wrong) and does not name
             v2.06i (those compare the versions on purpose).  Block comments
             (prose on lines of their own) are not checked: the banner of
             hd-ae5000_<ver>.s says they keep v2.06i's addresses.

      IMAGE  hdae5000_init_data.s holds the ROM image HDAE5000_Clear_Work_Buffer
             copies to RAM, and its comments say where each item lands
             ("RAM 0x23a09e").  The image is laid out differently in each
             version.  A RAM address quoted in that file is mapped through the
             copy: v2.06i RAM -> v2.06i ROM byte -> the source line that emits
             it -> its v2.01i twin line (same length) -> the same byte's v2.01i
             RAM address.  A quoted ROM address inside the image is mapped the
             same way, to the byte's v2.01i ROM address.  Only a quote that the v2.06i twin's comment also
             makes is rewritten, so a quote already rewritten is left alone.

RUN
    python3 scripts/analysis/hdae5000_version_stale_comments.py v2_01i [--fix]
"""
import difflib
import os
import re
import subprocess
import sys

BYTEDUMP = re.compile(rb'^;\s*((?:[0-9a-fA-F]{2}|xx)(?:[ \t]+(?:[0-9a-fA-F]{2}|xx))+)\s*$')
HEX = re.compile(rb'(?<![\w.])0x([0-9a-fA-F]{4,8})(?![\w])')
ADDR_LO, ADDR_HI = 0x200000, 0x300000
RANGE = re.compile(rb'0x[0-9a-fA-F]+\s*(?:-|\.\.)\s*0x[0-9a-fA-F]+')

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NUM = re.compile(rb'(?<![\w.])(0x[0-9a-fA-F]+|\d[\d,]*\d|\d)(?![\w])')


def split(line):
    q = False
    for i, c in enumerate(line):
        if c == 0x22:
            q = not q
        elif c == 0x3B and not q:
            return line[:i], line[i:]
    return line, b""


def val(t):
    return int(t, 16) if t.lower().startswith(b"0x") else int(t.replace(b",", b""), 10)


def nums(code):
    return [val(m.group(1)) for m in NUM.finditer(code)]


def render(tok, v):
    if tok.lower().startswith(b"0x"):
        digits = len(tok) - 2
        s = b"%0*x" % (digits, v)
        return b"0x" + (s.upper() if tok[2:].upper() == tok[2:] and any(c in b"ABCDEF" for c in tok[2:]) else s)
    if b"," in tok:
        return ("{:,}".format(v)).encode()
    return str(v).encode()


def main():
    ver = sys.argv[1] if len(sys.argv) > 1 else "v2_01i"
    sys.path.insert(0, os.path.join(ROOT, "scripts", "tools"))
    import port_hdae5000_version as P0
    base = P0.base_of(sys.argv)
    btree, bmain = P0.base_tree(base)
    fix = "--fix" in sys.argv
    tree = os.path.join(ROOT, "hdae5000_" + ver)
    total = fixed = 0
    for fn in sorted(os.listdir(tree)):
        if not fn.endswith(".s"):
            continue
        wf = os.path.join(btree, bmain if fn.startswith("hd-ae5000_") else fn)
        a = open(wf, "rb").read().split(b"\n")
        b = open(os.path.join(tree, fn), "rb").read().split(b"\n")
        sm = difflib.SequenceMatcher(None, a, b, autojunk=False)
        for op, i1, i2, j1, j2 in sm.get_opcodes():
            if op != "replace" or i2 - i1 != j2 - j1:
                continue
            for i, j in zip(range(i1, i2), range(j1, j2)):
                ca, ka = split(a[i])
                cb, kb = split(b[j])
                if not kb or kb != ka:
                    continue
                na, nb = nums(ca), nums(cb)
                gone = [v for v in na if v not in nb]
                if not gone:
                    continue
                quoted = [m for m in NUM.finditer(kb) if val(m.group(1)) in gone]
                if not quoted:
                    continue
                total += 1
                pairs = {}
                if len(na) == len(nb):
                    for x, y in zip(na, nb):
                        if x != y:
                            pairs.setdefault(x, set()).add(y)
                ok = all(len(pairs.get(val(m.group(1)), ())) == 1 for m in quoted)
                if fix and ok:
                    new = kb
                    for m in reversed(quoted):
                        v = val(m.group(1))
                        new = new[:m.start()] + render(m.group(1), next(iter(pairs[v]))) + new[m.end():]
                    b[j] = cb + new
                    fixed += 1
                else:
                    print("%s:%d  %s" % (fn, j + 1, b[j].decode("latin-1").strip()))
        if fix:
            open(os.path.join(tree, fn), "wb").write(b"\n".join(b))
    print("TEXT   %d comments quote a number their code no longer has; %d rewritten" % (total, fixed))
    bad = byte_checks(ver, tree, fix)
    return 1 if (total - fixed) + bad else 0


def render_hex(tok, v):
    """tok = the hex digits of a quoted 0x literal; v in the same width and case."""
    digits = max(len(tok), len("%x" % v))
    t = "%0*x" % (digits, v)
    if any(c in b"ABCDEF" for c in tok) or (tok.upper() == tok and not any(c in b"abcdef" for c in tok)
                                             and any(c in b"ABCDEF" for c in tok)):
        t = t.upper()
    return t.encode()


def byte_checks(ver, tree, fix):
    sys.path.insert(0, os.path.join(ROOT, "scripts", "tools"))
    import port_hdae5000_version as P
    base = P.base_of(sys.argv)
    btree, bmain = P.base_tree(base)
    ba = P.Build(btree, bmain, P.incs_of(base),
                 os.path.join(P.SCRATCH, "port_hdae5000_stalecomments_a"))
    bb = P.Build(tree, P.main_of(ver), P.incs_of(ver),
                 os.path.join(P.SCRATCH, "port_hdae5000_stalecomments_b"))
    assert ba.ok and bb.ok, (ba.stderr[-500:], bb.stderr[-500:])

    def emitted(bld):
        out = {}
        for f, n, s0, e0 in bld.lines:
            out[(f, n)] = bld.img[s0 - P.BASE:e0 - P.BASE] if e0 > s0 else b""
        return out
    ea, eb = emitted(ba), emitted(bb)

    def values(elf):
        out = subprocess.run([P.BIN + "/llvm-nm", "--defined-only", elf], capture_output=True,
                             text=True, check=True).stdout
        d = {}
        for l in out.split("\n"):
            q = l.split()
            if len(q) == 3 and q[1] in "tTaA" and not q[2].startswith("__PM_"):
                d[q[2]] = int(q[0], 16)
        return d
    va = values(os.path.join(ROOT, "rebuilt_ROMs", "hd-ae5000_%s.llvm.elf" % base))
    vb = values(os.path.join(ROOT, "rebuilt_ROMs", "hd-ae5000_%s.llvm.elf" % ver))
    vb_set = set(vb.values())
    moved = {}
    for name, a in va.items():
        if name in vb and ADDR_LO <= a < ADDR_HI and vb[name] != a:
            moved.setdefault(a, set()).add(vb[name])
    sym_map = {a: next(iter(s)) for a, s in moved.items() if len(s) == 1 and a not in vb_set}

    def copy_window(bld):
        """(rom_src, ram_dst, count) of the .data copy in HDAE5000_Clear_Work_Buffer."""
        got = {}
        for f, n, s0, e0 in bld.lines:
            com = split(bld.text(f, n))[1]
            for key, tag in ((b"Destination = RAM init area", "dst"), (b"Source = ROM init data", "src"),
                             (b"Count = ", "cnt")):
                if key in com and e0 - s0 == 5 and tag not in got and ("dst" in got or tag == "dst"):
                    got[tag] = int.from_bytes(bld.img[s0 - P.BASE + 1:e0 - P.BASE], "little")
        return got["src"], got["dst"], got["cnt"]
    src_a, dst_a, cnt_a = copy_window(ba)
    src_b, dst_b, cnt_b = copy_window(bb)
    line_at_a = {}                              # v2.06i ROM byte -> (file, line, start)
    for f, n, s0, e0 in ba.lines:
        if src_a <= s0 < src_a + cnt_a:
            for x in range(s0, e0):
                line_at_a[x] = (f, n, s0)
    start_b = {(f, n): (s0, e0) for f, n, s0, e0 in bb.lines}

    n_bytes = n_oper = n_sym = n_img = n_left = 0
    for fn in sorted(bb.texts):
        twin = bmain if fn.startswith("hd-ae5000_") else fn
        if twin not in ba.texts:
            continue
        a, b = ba.texts[twin], bb.texts[fn]
        pair = {}
        sm = difflib.SequenceMatcher(None, a, b, autojunk=False)
        for op, i1, i2, j1, j2 in sm.get_opcodes():
            if op == "equal" or (op == "replace" and i2 - i1 == j2 - j1):
                for i, j in zip(range(i1, i2), range(j1, j2)):
                    pair[j] = i
        changed = False
        inv = {i: j for j, i in pair.items()}
        for j in range(len(b)):
            code, com = split(b[j])
            if not com:
                continue
            new = com
            # IMAGE
            i = pair.get(j)
            if fn == "hdae5000_init_data.s" and i is not None:
                twin_com = split(a[i])[1]
                for hm in reversed(list(HEX.finditer(new))):
                    q = int(hm.group(1), 16)
                    if hm.group(0) not in twin_com:
                        continue
                    if dst_a <= q < dst_a + cnt_a:
                        rom_q, base_a, base_b = q - dst_a + src_a, dst_a, dst_b
                    elif src_a <= q < src_a + cnt_a:
                        rom_q, base_a, base_b = q, src_a, src_b
                    else:
                        continue
                    hit = line_at_a.get(rom_q)
                    jb = inv.get(hit[1] - 1) if hit and hit[0] == twin else None
                    se = start_b.get((fn, jb + 1)) if jb is not None else None
                    sa_e = [(s0, e0) for f, n, s0, e0 in ba.lines if f == twin and n == hit[1]] if hit else []
                    if not se or not sa_e or se[1] - se[0] != sa_e[0][1] - sa_e[0][0] \
                            or not (src_b <= se[0] < src_b + cnt_b):
                        n_left += 1
                        print("IMAGE  %s:%d  0x%x has no twin byte in %s" % (fn, j + 1, q, ver))
                        continue
                    r = se[0] + (rom_q - hit[2]) - src_b + base_b
                    if r != q:
                        n_img += 1
                        new = new[:hm.start(1)] + render_hex(hm.group(1), r) + new[hm.end(1):]
            mine = eb.get((fn, j + 1), b"")
            # BYTES
            m = BYTEDUMP.match(com)
            if m and mine:
                toks = m.group(1).split()
                if len(toks) == len(mine):
                    want = [t if t == b"xx" else b"%02x" % mine[k] for k, t in enumerate(toks)]
                    if [t.lower() for t in toks] != want:
                        n_bytes += 1
                        new = com[:m.start(1)] + b" ".join(want) + com[m.end(1):]
                else:
                    n_left += 1
                    print("BYTES  %s:%d  dump has %d bytes, the line emits %d: %s" % (
                        fn, j + 1, len(toks), len(mine), b[j].decode("latin-1").strip()))
            # OPER
            theirs = ea.get((twin, i + 1), b"") if i is not None else b""
            if mine and theirs and len(mine) == len(theirs) and mine != theirs and not m:
                pairs24, pairs16 = {}, {}
                for k in range(len(mine) - 1):
                    if k + 3 <= len(mine):
                        x = int.from_bytes(theirs[k:k + 3], "little")
                        y = int.from_bytes(mine[k:k + 3], "little")
                        if x != y and ADDR_LO <= x < ADDR_HI and ADDR_LO <= y < ADDR_HI:
                            pairs24.setdefault(x, set()).add(y)
                    x = int.from_bytes(theirs[k:k + 2], "little")
                    y = int.from_bytes(mine[k:k + 2], "little")
                    if x != y:
                        pairs16.setdefault(x, set()).add(y)
                for hm in reversed(list(HEX.finditer(new))):
                    q = int(hm.group(1), 16)
                    r = None
                    if len(pairs24.get(q, ())) == 1:
                        r = next(iter(pairs24[q]))
                    elif ADDR_LO <= q < ADDR_HI and len(pairs16.get(q & 0xFFFF, ())) == 1 \
                            and code.lstrip().startswith(b"pushw"):
                        r = (q & ~0xFFFF) | next(iter(pairs16[q & 0xFFFF]))
                    if r is not None and r != q:
                        n_oper += 1
                        new = new[:hm.start(1)] + render_hex(hm.group(1), r) + new[hm.end(1):]
            # SYM
            if mine and b"v2.06" not in new and not RANGE.search(new):
                for hm in reversed(list(HEX.finditer(new))):
                    q = int(hm.group(1), 16)
                    if q in sym_map:
                        n_sym += 1
                        new = new[:hm.start(1)] + render_hex(hm.group(1), sym_map[q]) + new[hm.end(1):]
            if new != com:
                if fix:
                    b[j] = code + new
                    changed = True
                else:
                    print("STALE  %s:%d  %s" % (fn, j + 1, b[j].decode("latin-1").strip()))
                    print("    ->  %s" % (code + new).decode("latin-1").strip())
        if fix and changed:
            open(os.path.join(tree, fn), "wb").write(b"\n".join(b))
    verb = "rewritten" if fix else "stale"
    print("BYTES  %d byte-dump comments %s" % (n_bytes, verb))
    print("OPER   %d quoted operands %s" % (n_oper, verb))
    print("SYM    %d quoted symbol values %s (%d v2.06i values map to one v2.01i value)" % (
        n_sym, verb, len(sym_map)))
    print("IMAGE  %d quoted RAM-image addresses %s (copy: v2.06i 0x%x -> RAM 0x%x, 0x%x bytes; "
          "%s 0x%x -> RAM 0x%x, 0x%x bytes)" % (n_img, verb, src_a, dst_a, cnt_a, ver, src_b, dst_b, cnt_b))
    print("LEFT   %d comments listed above for a hand fix" % n_left)
    return n_left + (0 if fix else n_bytes + n_oper + n_sym + n_img)


if __name__ == "__main__":
    sys.exit(main())
