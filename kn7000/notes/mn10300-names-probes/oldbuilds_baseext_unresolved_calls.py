#!/usr/bin/env python3
"""oldbuilds_baseext_unresolved_calls.py -- where do the BASEEXT.XAP indirect calls go that
oldbuilds_baseext_indirect_calls.py leaves at a stack slot, a parameter, a return value or a
pointer chain (N-42bc8729)?

That probe's evaluator stops at a value that comes from outside the basic-block walk.  This one
takes each such site (the classes sp / arg / ret / own) and follows the value one step further,
with a rule per kind of source, each checked against the code:

  PARAM      the routine spilled a0 / a1 to the stack slot the call reads (`mov aN, (OFF, sp)` in its
             first instructions), so the value is what every direct caller of the routine passes in aN
             (a call from inside the routine itself that passes the same slot back is recursion):
             - a PtrStrList the .XAP built (oldbuilds_baseext_indirect_calls' own objects): method
               vtbl+K of PtrStrListVtbl;
             - a code address: that routine.
  CTXOBJ     *(*(XapContext) + 4): KssContext word +0x04 is the address KssWorkRam+0x9EC, an object
             the base plug-in builds with PtrStrListCreate (table.s func_483ECB8F): method vtbl+K.
  LISTSRC    the call is inside a method of the .XAP's list-source class or its iterator (their
             vtables are the words the constructors store at +0: 0x502B1DA8 / 0x502B1DD8, initial
             values in the .data image the start-up copies from 0x502B15E4 to 0x502B1B50, 0x56C
             bytes), and reads `this`+0x10 / +0x14 (source) or `this`+0xC -> +0x10 / +0x14 (iterator,
             whose +0xC is its source).  A source's +0x10 / +0x14 are the a1 / d1 its constructor
             0x502AB042 was given; the constructor is called from 3 places in the .XAP and, as the
             .XAP's export slot +0x10, from 2 in the base plug-in (table.s: `(KssWorkRam+0xA44)` is
             the .XAP's export table, slot +0x10, with a1 / d1 = export slots).  So the target is
             one of the 5 sources' functions: a closed set, chosen at run time by the source.
  KSSLIST    the call is inside the .XAP's AcKssList procedure (its export slot +0x04; the base
             plug-in's AcKssListProc forwards to it) and goes through the view instance's word +0x6C
             (GetViewInstance = InitBlockTable[181], then `add 0x6c`): X = inst[0x6C], S = *X,
             obj = *S, call obj->vtbl[K](obj), K in 0x00 / 0x08 / 0x28 / 0x44.  The vtables the two
             plug-ins store at an object's +0 that have all four slots are the 19-word iterators
             StrList, BufStrList and the .XAP's XapListIter.  The procedure's create path stores a
             new StrList at S+0 (the CTXOBJ call, then `mov (a2), a1; mov (a1), a1; mov a0, (a1)`);
             its message 0x2F60008 stores the message's parameter there, and the probe lists what
             every SendEvent / PostEvent of that id passes.

Expected (2026-11-06, after the evaluator fixes of that day leave 19 sites): PARAM 6 (4 to
PtrStrListVtbl+0x0C, 2 to XapNameCmp 0x502A144D, the compare routine of the quicksort
0x5029D3FB), CTXOBJ 1 (PtrStrListVtbl+0x2C), LISTSRC 5 (one of 5 get-item / 5 count routines),
KSSLIST 7 (StrList or XapListIter: 0x2F60008's 17 senders pass StrList 7, XapListIter 6 and 4
values that are not constants); 0 left.  It also prints the .XAP's export slots that the base
plug-in's thunks name (27 procedures).

Run (from kn7000/, read-only on the baserom images and the generated sources):
    UNIDASM=/home/fsanches/compartilhado/mame-sony-video/unidasm \\
        python3 -I notes/mn10300-names-probes/oldbuilds_baseext_unresolved_calls.py
"""
import collections
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import oldbuilds_baseext_indirect_calls as P   # noqa: E402

XAP = open(P.XAP, "rb").read()
DATA_ROM, DATA_RAM, DATA_LEN = 0x502B15E4, 0x502B1B50, 0x56C   # the start-up's .data copy
EXPORT = 0x502B1E50                     # XapEntry returns it in a0 (the loader keeps it per id)
SRC_CTOR, SRC_VT, ITER_VT = 0x502AB042, 0x502B1DA8, 0x502B1DD8
TABLE_S = "src/sp7001/table.s"
SET_LIST = 0x02F60008                   # the message XapAcKssListProc answers with `*S = its parameter`


def word(a):
    """the initial word at RAM address a (the .data copy applied)"""
    if DATA_RAM <= a < DATA_RAM + DATA_LEN:
        a -= DATA_RAM - DATA_ROM
    return struct.unpack_from("<I", XAP, a - P.BASE)[0]


def check_data_copy(insns):
    """the start-up routine XapEntry calls first copies DATA_LEN bytes DATA_ROM -> DATA_RAM"""
    first = next(int(re.search(r"0x([0-9a-f]+)", o).group(1), 16)
                 for a, n, mn, o in insns if mn == "call")
    k = next(i for i, x in enumerate(insns) if x[0] == first)
    body = " ; ".join(f"{mn} {o}" for _a, _n, mn, o in insns[k:k + 24])
    for need in (f"mov {DATA_ROM:#x}, a0", f"mov {DATA_RAM:#x}, a1", f"mov {DATA_LEN:#x}, d1"):
        assert need in body, (need, body)
    assert "mov 0x502b1e50, a0" in " ; ".join(f"{mn} {o}" for _a, _n, mn, o in insns[:12])


def chain(e):
    """(root, [offsets]) of a normalised expression"""
    offs = []
    while e[0] in ("LOAD", "ADD"):
        offs.append((e[0], e[2]))
        e = e[1]
    return e, offs[::-1]


def routine_of(A, i):
    """index of the entry of the routine holding insns[i]: the nearest call target / export
    word at or before it"""
    insns = A["insns"]
    ents = A["entries"]
    while i > 0 and insns[i][0] not in ents:
        i -= 1
    return i


def table_lines():
    return open(TABLE_S, "rb").read().decode("latin-1").split("\n")


def export_thunks(L):
    """{export offset: base plug-in routine name} for the thunks `mov (KssWorkRam+0xA44), a0;
    mov (N, a0), a0` followed by the call of func_483E856E (or calls (a0))"""
    out = {}
    for i, l in enumerate(L):
        m = re.match(r"# (\w+)  \(CPU (0x[0-9A-F]+)\)", l)
        if not m:
            continue
        body = []
        for x in L[i + 1:i + 30]:
            if x.startswith("# ") and "(CPU" in x:
                break
            if not x.startswith("#"):
                body.append(x.strip())
        for k, x in enumerate(body[:12]):
            if "(KssWorkRam+0xA44), a0" in x and x.startswith("mov") and k + 1 < len(body):
                m2 = re.match(r"mov\s+\((0x[0-9a-f]+|\d+), a0\), a0", body[k + 1])
                if m2 and any("func_483E856E" in y or "calls   (a0)" in y for y in body[k + 2:k + 4]):
                    out[int(m2.group(1), 0)] = m.group(1)
                break
    return out


def base_sources(L):
    """the list sources the base plug-in builds through the .XAP's export slot +0x10:
    [(object, a1 export offset, d1 export offset)]"""
    out = []
    for i, l in enumerate(L):
        if l.strip() == "mov     (0x10, a0), a2" and "(KssWorkRam+0xA44), a0" in L[i - 2]:
            blk = [x.strip() for x in L[i - 2:i + 6]]
            a1 = next(int(re.search(r"\((0x[0-9a-f]+), a0\), a1", x).group(1), 16) for x in blk if ", a0), a1" in x)
            d1 = next(int(re.search(r"\((0x[0-9a-f]+), a0\), d1", x).group(1), 16) for x in blk if ", a0), d1" in x)
            obj = next(re.search(r"mov\s+(\S+), a0", x).group(1) for x in blk if re.match(r"mov\s+KssWorkRam\+", x))
            assert "calls   (a2)" in blk, blk
            out.append((obj, a1, d1))
    return out


def base_export_uses(L):
    """the .XAP export offsets the base plug-in reads after loading (KssWorkRam+0xA44)"""
    used = set()
    for i, l in enumerate(L):
        if "(KssWorkRam+0xA44), a" in l and l.strip().startswith("mov"):
            r = l.split(",")[-1].strip()
            for x in L[i + 1:i + 6]:
                m = re.search(r"\((0x[0-9a-f]+|\d+), %s\)" % r, x)
                if m:
                    used.add(int(m.group(1), 0))
                    break
    return used


def xap_vtable(a, stop=None):
    """the words of a .XAP vtable (its initial .data image), up to the next vtable (stop) or the
    first word that is neither 0 nor a code address"""
    out = []
    while a + 4 * len(out) != stop:
        x = word(a + 4 * len(out))
        if x and not P.BASE <= x < P.BASE + P.CODE_END:
            break
        out.append(x)
    return out


def xap_vtable_stores(insns):
    """the .data addresses the .XAP's code stores at an object's +0 (`mov 0x502b...., rX`,
    then `mov rX, (aY)` within 3 instructions)"""
    out = set()
    for k, (_a, _n, mn, o) in enumerate(insns):
        m = re.fullmatch(r"0x([0-9a-f]{8}), ([ad]\d)", o)
        if mn == "mov" and m and DATA_RAM <= int(m.group(1), 16) < DATA_RAM + DATA_LEN:
            if any(x[2] == "mov" and x[3] == f"{m.group(2)}, (a{d})" for x in insns[k + 1:k + 4] for d in range(4)):
                out.add(int(m.group(1), 16))
    return out


def base_vtables(L):
    """(class, label) of every vtable the base plug-in's code stores at an object's +0; the class
    is the name string that follows the table (StrList, BufStrList) or, for the two the
    probe's CLASSES knows, that name"""
    known = {lbl: c for c, lbl in P.CLASSES.values()}
    out = []
    for i, l in enumerate(L):
        m = re.match(r"\s+mov\s+(ptrs_\w+), (d\d|a\d)$", l)
        if m and any(re.match(r"\s+mov\s+%s, \(a\d\)$" % m.group(2), x) for x in L[i + 1:i + 4]):
            lbl = m.group(1)
            w = P.load_words(lbl)
            if w and w[-1].startswith("Str_"):
                w.pop()
            out.append((known.get(lbl, {"ptrs_5029913C": "BufList", "ptrs_5029916C": "BufStrList"}.get(lbl, lbl)), lbl, w))
    return out


def main():
    A = P.analyse()
    insns, starts, at = A["insns"], A["starts"], A["at"]
    check_data_copy(insns)
    exports = [word(EXPORT + 4 * k) for k in range(0x240 // 4)]
    A["entries"] = {int(m.group(1), 16) for _a, _n, mn, o in insns if mn in ("call", "calls")
                    for m in [re.search(r"0x([0-9a-f]{8})", o)] if m} | set(exports)
    tnames = A["tnames"]
    names = {}
    for line in open("kn7000_sp7001_baseext.sym"):
        m = re.match(r"0x([0-9A-Fa-f]{8})\s+(\S+)", line)
        if m:
            names[int(m.group(1), 16)] = m.group(2)
    nm = lambda a: names.get(a, tnames.get(a, f"0x{a:08X}"))
    vt = {c: P.load_words(lbl) for c, lbl in P.CLASSES.values()}
    L = table_lines()

    left = []
    for i, reg in A["sites"]:
        e = P.norm(P.evaluate(insns, i, reg, starts))
        c, _dt = P.classify(e, A["slots"], A["names"], A["fw"], A["ctx"], tnames, A["objs"])
        if c in ("sp", "arg", "ret", "own"):
            left.append((i, reg, e))
    print(f"{len(left)} sites left by oldbuilds_baseext_indirect_calls.py (sp / arg / ret / own)")

    # list sources: the .XAP's own constructions and the base plug-in's
    src_fns = []
    for k, (a, _n, mn, o) in enumerate(insns):
        if mn == "call" and int(re.search(r"0x([0-9a-f]+)", o).group(1), 16) in (SRC_CTOR, SRC_CTOR + 5):
            a1 = P.evaluate(insns, k, "a1", starts)
            d1 = P.evaluate(insns, k, "d1", starts)
            a0 = P.evaluate(insns, k, "a0", starts)
            assert a1[0] == d1[0] == a0[0] == "CONST", (hex(a), a1, d1, a0)
            src_fns.append((f"0x{a0[1]:08X} (.XAP, built at 0x{a:08X})", a1[1], d1[1]))
    assert exports[0x10 // 4] == SRC_CTOR, hex(exports[4])
    for obj, oa1, od1 in base_sources(L):
        src_fns.append((f"{obj} (base plug-in)", exports[oa1 // 4], exports[od1 // 4]))
    get_set = sorted({g for _o, g, _c in src_fns})
    cnt_set = sorted({c for _o, _g, c in src_fns})
    src_vt, it_vt = xap_vtable(SRC_VT, ITER_VT), xap_vtable(ITER_VT)
    # a method's prologue and its call entry a few bytes in (`movm` 2 + `add -N, sp` 3)
    src_m = {a + d for a in src_vt if a for d in range(6)}
    it_m = {a + d for a in it_vt if a for d in range(6)}
    A["entries"] |= {a for a in src_vt + it_vt if a}       # methods only the vtables name

    # the AcKssList procedure: export slot +0x04
    thunks = export_thunks(L)
    assert thunks.get(4) == "AcKssListProc", thunks.get(4)
    kl_lo = exports[1]
    kl_hi = min(x for x in A["entries"] if x > kl_lo)
    # every `add 0x6c, rN` in it is applied to GetViewInstance's result
    for k in range(at[kl_lo], at[kl_hi]):
        a, _n, mn, o = insns[k]
        if mn == "add" and o.startswith("0x6c,"):
            r = o.split(",")[1].strip()
            v = P.evaluate(insns, k, r, starts)
            j = k - 1
            if v[0] == "LOAD" and v[1] == ("SP",):
                # a stack slot: the store into it that comes last before here
                while not (insns[j][2] == "mov" and insns[j][3].endswith(f", ({v[2]:#x}, sp)")):
                    j -= 1
                v = P.evaluate(insns, j, insns[j][3].split(",")[0], starts)
                j -= 1
            assert v[0] == "RET", (hex(a), v)
            while insns[j][2] not in ("call", "calls"):
                j -= 1
            t = P.norm(P.evaluate(insns, j, re.fullmatch(r"\((a\d)\)", insns[j][3]).group(1), starts))
            c, dt = P.classify(t, A["slots"], A["names"], A["fw"], A["ctx"], tnames, A["objs"])
            assert dt.endswith("GetViewInstance"), (hex(a), dt)
    # every vtable the two plug-ins store at an object's +0, with its length
    vtabs = {f"{c} ({lbl})": w for c, lbl, w in base_vtables(L)}
    vtabs[f"XapListSource (0x{SRC_VT:08X})"] = [f"0x{x:08X}" if x else "0" for x in src_vt]
    vtabs[f"XapListIter (0x{ITER_VT:08X})"] = [f"0x{x:08X}" if x else "0" for x in it_vt]
    assert xap_vtable_stores(insns) == {SRC_VT, ITER_VT}, xap_vtable_stores(insns)

    # the spilled-parameter rule
    def spilled(i, slot):
        """the routine entry whose first instructions spill a0 / a1 to `slot`; an entry
        in between (a call target inside the routine) is passed over, up to 4"""
        r = routine_of(A, i)
        for _try in range(5):
            for k in range(r, min(r + 12, len(insns))):
                m = re.fullmatch(r"(a[01]), \((0x[0-9a-f]+|\d+), sp\)", insns[k][3])
                if insns[k][2] == "mov" and m and int(m.group(2), 0) == slot:
                    return r, m.group(1)
            r = routine_of(A, r - 1)
        return r, None

    used = base_export_uses(L)

    def callers_pass(r, reg, slot):
        vals = set()
        entry = insns[r][0]
        ents = {entry} | {insns[k][0] for k in range(max(0, r - 2), r + 3)}
        # a routine the export table holds must not be one the base plug-in calls
        assert not any(4 * k in used for k, x in enumerate(exports) if x in ents), hex(entry)
        for k, (a, _n, mn, o) in enumerate(insns):
            if mn != "call":
                continue
            t = int(re.search(r"0x([0-9a-f]+)", o).group(1), 16)
            if t not in ents:
                continue
            v = P.norm(P.evaluate(insns, k, reg, starts))
            if routine_of(A, k) == r and v == ("LOAD", ("SP",), slot):
                continue                     # recursion: the same parameter passed on
            vals.add(v)
        return vals

    out = []
    for i, reg, e in left:
        a = insns[i][0]
        root, offs = chain(e)
        r = routine_of(A, i)
        rentry = insns[r][0]
        kind, what = None, None
        if root == ("SP",) and offs and offs[0][0] == "LOAD":
            slot = offs[0][1]
            r0, preg = spilled(i, slot)
            vals = callers_pass(r0, preg, slot) if preg else set()
            if kl_lo <= a < kl_hi:
                pass
            elif vals and all(v[0] == "CONST" for v in vals):
                vs = sorted(v[1] for v in vals)
                rest = [o for _k, o in offs[1:]]
                if not rest and len(vs) == 1:
                    kind, what = "PARAM", f"{preg} of 0x{insns[r0][0]:08X} = {nm(vs[0])} (every caller)"
                elif all(v in A["objs"] for v in vs) and len({A["objs"][v][0] for v in vs}) == 1 \
                        and rest[:1] == [0] and len(rest) == 2:
                    # every caller passes an object of one class: one method
                    cls, words = A["objs"][vs[0]]
                    w = words[rest[1] // 4]
                    kind, what = "PARAM", (f"{preg} of 0x{insns[r0][0]:08X} = {cls} " + "/".join(f"0x{v:08X}" for v in vs)
                                           + f" ({len(vs)} objects): vtbl+{rest[1]:#04x} = {w}")
        if kind is None and root == ("MEM", P.XAPCTX) and [o for _k, o in offs] [:2] == [4, 0]:
            w = A["ctx"][1]
            assert w == "KssWorkRam+0x9EC", w
            for k, l in enumerate(L):
                if l.strip().startswith("mov") and l.strip().endswith(f"{w}, a3"):
                    blk = " ".join(x.strip() for x in L[k:k + 6])
                    assert "mov     a3, a0" in blk and "call    PtrStrListCreate_entry" in blk, blk
                    break
            else:
                raise SystemExit("no PtrStrListCreate of " + w)
            K = offs[2][1]
            kind, what = "CTXOBJ", f"KssContext+0x04 = &{w}, a PtrStrList: vtbl+{K:#04x} = {vt['PtrStrList'][K // 4]}"
        if kind is None and rentry in src_m | it_m:
            o = [x for _k, x in offs]
            if root[0] == "ARG" and root[1] == "a0":
                if rentry in it_m and o[:1] == [0xC]:
                    o = o[1:]
                if o in ([0x10], [0x14]):
                    fs = get_set if o == [0x10] else cnt_set
                    kind = "LISTSRC"
                    what = (f"{'iterator' if rentry in it_m else 'source'} method 0x{rentry:08X}: source+{o[0]:#x} "
                            f"({'get item' if o == [0x10] else 'count'}) = one of " + ", ".join(nm(f) for f in fs))
        if kind is None and kl_lo <= a < kl_hi:
            o = [x for _k, x in offs]
            K = o[-1]
            kind, what = "KSSLIST", K        # finished below, once every slot used is known
        out.append((a, kind or "LEFT", what if what is not None else str(e)))

    # KSSLIST: one object (inst+0x6C -> S -> obj) serves every such call, so its class has a method
    # in every slot they use: the classes whose vtable has all of them
    used_k = sorted({w for _a, k, w in out if k == "KSSLIST"})
    fits = [c for c, w in vtabs.items() if all(K // 4 < len(w) and w[K // 4] not in ("0", "") for K in used_k)]
    print(f"AcKssList list-object slots used: {[hex(k) for k in used_k]}; classes with all of them: "
          + ", ".join(fits))
    # which of them the AcKssList gets: its create path stores PtrStrList+0x2C's result (a new
    # StrList over KssContext+0x04's list) at S+0; message 0x2F60008 (`*S = the message's
    # parameter`) hands it another one: the parameters of every SendEvent / PostEvent of that id
    iters = {}
    for k, (a, _n, mn, o) in enumerate(insns):
        if mn == "call" and int(re.search(r"0x([0-9a-f]+)", o).group(1), 16) == 0x502AB0D9:
            v = P.evaluate(insns, k, "a0", starts)
            if v[0] == "CONST":
                iters[v[1]] = "XapListIter"
    given = collections.Counter()
    for k, (a, _n, mn, o) in enumerate(insns):
        if mn == "mov" and o == f"{SET_LIST:#010x}, d1":
            j = next(x for x in range(k, k + 8) if insns[x][2] == "calls")
            t = P.norm(P.evaluate(insns, j, insns[j][3][1:3], starts))
            _c, dt = P.classify(t, A["slots"], A["names"], A["fw"], A["ctx"], tnames, A["objs"])
            assert dt.endswith(("SendEvent", "PostEvent")), (hex(a), dt)
            st = next(x for x in range(j - 1, k - 12, -1) if insns[x][2] == "mov" and insns[x][3].endswith(", (0x10, sp)"))
            v = P.evaluate(insns, st, insns[st][3].split(",")[0], starts)
            cls = (A["objs"].get(v[1], (None,))[0] or iters.get(v[1], "?")) if v[0] == "CONST" else "not a constant"
            given[cls] += 1
    # the create path: the CTXOBJ call (a new StrList) is stored at S+0 straight away
    mk = [a for a, k, _w in out if k == "CTXOBJ" and kl_lo <= a < kl_hi]
    assert len(mk) == 1, mk
    nxt = [f"{x[2]} {x[3]}" for x in insns[at[mk[0]] + 1:at[mk[0]] + 4]]
    assert nxt == ["mov (a2), a1", "mov (a1), a1", "mov a0, (a1)"], nxt
    assert P.evaluate(insns, at[mk[0]], "a2", starts)[0] == "ADD"          # a2 = inst + 0x6C
    print(f"AcKssList list object: the create path's new StrList; message {SET_LIST:#x} from "
          f"{sum(given.values())} senders hands it: " + ", ".join(f"{c} {n}" for c, n in given.most_common()))
    seen = {"StrList"} | {c for c in given if c in ("StrList", "XapListIter", "BufStrList")}
    fits_seen = [c for c in fits if c.split()[0] in seen]
    out = [(a, k, (f"AcKssList inst+0x6C -> S -> obj, vtbl+{w:#04x}: "
                   + " or ".join(f"{c.split()[0]} {vtabs[c][w // 4]}" for c in fits_seen)) if k == "KSSLIST" else w)
           for a, k, w in out]
    by = collections.Counter(k for _a, k, _w in out)
    print("  " + ", ".join(f"{k} {n}" for k, n in by.most_common()))
    for a, k, w in sorted(out):
        print(f"  0x{a:08X}  {k:8s} {w}")
    print(f"\nlist sources ({len(src_fns)}): source+0x10 (get item, a1) / +0x14 (count, d1)")
    for o, g, c in src_fns:
        print(f"  {o:42s} {nm(g)} / {nm(c)}")
    print(f"source vtbl 0x{SRC_VT:08X}: " + " ".join(f"{x:#x}" for x in src_vt))
    print(f"iterator vtbl 0x{ITER_VT:08X}: " + " ".join(f"{x:#x}" for x in it_vt))
    print(f"AcKssList procedure 0x{kl_lo:08X}..0x{kl_hi:08X}")
    print("vtables stored at an object's +0 (words):")
    for c, w in vtabs.items():
        print(f"  {c:40s} {len(w):3d}")
    print(f"\n.XAP export slots the base plug-in's thunks forward to ({len(thunks)}):")
    for off in sorted(thunks):
        print(f"  +{off:#05x}  0x{exports[off // 4]:08X}  {thunks[off]}")


if __name__ == "__main__":
    main()
