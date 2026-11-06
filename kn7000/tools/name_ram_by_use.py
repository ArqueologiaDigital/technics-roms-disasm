#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Names the RAM addresses of an MN10300 MILK program source (gen_image_s.py's output)
# after the named routines that use them.
#
# Question it answers: "which RAM addresses that the code still spells as numbers can
# be named from the routine names the image already has, and by what evidence?"
#
# It reads the generated source (src/program.s), whose instruction operands spell a
# RAM address either as a number (0x50xxxxxx work RAM, 0x90xxxxxx its uncached view,
# 0x84xxxxxx the battery SRAM) or by a name from the symbol files.  A routine is the
# code from one routine label to the next (its `<name>_entry`, `<name>_L<offset>` and
# `loc_<ADDR>` labels belong to it).  Its name counts only when a symbol file gives it
# (a reflection table, a hand name, a ported name): a func_<ADDR> placeholder is no
# evidence.  Two evidence classes, the first wins:
#
#   accessor  a named routine whose whole body (prologue and nop aside) is one access
#             of one RAM address and a return:
#               getter   `mov|movhu|movbu|movh|movb (ADDR), rN` [+ `ext*`] + ret
#               setter   [`ext*`] + `mov|movhu|movbu|movh|movb dN, (ADDR)` + ret
#               address  `mov ADDR, aN|dN` + ret (the routine returns where the
#                        variable is: a name ending in Ptr / Addr / Base, or starting
#                        with Get)
#             and whose name says what it reads: a leading Get / Set / Is / Check or a
#             trailing Get / Set (address: Get / Ptr / Addr / Base) is dropped and the
#             rest names the variable (GetSeqPlySrtR / SetSeqPlySrtR -> SeqPlySrtR).  All
#             the accessors of one address must give one stem.
#   owner     every direct reference to the address lies in ONE named routine R: the
#             address is named R_Ram, R_Ram_2, ... in address order (the data
#             region's convention for its .data variables, gen_data_s.py's labels.sym
#             R_Var, with a suffix of its own so the two never meet when the data region
#             is regenerated).
#             A computed access (base + index) is not seen; the name says only who
#             spells the address.
#
# A name that some symbol, data label or code label already uses gets `_Ram` (accessor
# class) or the next number (owner class).  Names this tool wrote before (--out) are
# read back as RAM references, so a rerun on a regenerated source is a fixed point.
#
# Usage (from a model's directory):
#   name_ram_by_use.py --src src/program.s --sym M.sym M_manual.sym M_ported.sym ... \
#       --taken src/labels.inc src/symbols.inc src/program/data/labels.sym \
#       [--not-ram LO:HI ...] --out M_ram.sym --title "..."
import argparse
import collections
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_image_s as GI  # noqa: E402

RAM_TOPS = (0x50, 0x90, 0x84)
HEX = re.compile(rb"(?<![\w.])0x([0-9a-fA-F]{8})\b")
IDENT = re.compile(rb"(?<![\w.])([A-Za-z_]\w*)\b")
LABEL = re.compile(rb"^([A-Za-z_]\w*):")
LOADS = ("mov", "movhu", "movbu", "movh", "movb")
EXTS = ("ext", "extb", "extbu", "exth", "exthu")
RETS = ("ret", "retf", "rets")


def is_ram(v, not_ram):
    return (v >> 24) in RAM_TOPS and not any(lo <= v < hi for lo, hi in not_ram)


def read_routines(path, routine_label):
    """[(routine label, [(mnemonic, operands)])] of the source, in order."""
    out, cur = [], None
    for ln in open(path, "rb").read().split(b"\n"):
        m = LABEL.match(ln)
        if m:
            nm = m.group(1).decode()
            if routine_label(nm):
                cur = (nm, [])
                out.append(cur)
            continue
        if cur is None or not ln.startswith(b"\t"):
            continue
        s = ln.split(b";", 1)[0].strip()
        if not s or s.startswith((b".", b"#")):
            continue
        p = s.split(None, 1)
        cur[1].append((p[0].decode(), p[1] if len(p) > 1 else b""))
    return out


def stem(name, kind):
    """The variable's name from its accessor's, or None when the name does not say."""
    pre = ("Get", "Set", "Is", "Check") if kind != "address" else ("Get",)
    suf = ("Get", "Set") if kind != "address" else ("Ptr", "Addr", "Base")
    out = None
    for p in pre:
        if name.startswith(p) and len(name) > len(p) and name[len(p)].isupper():
            out = name[len(p):]
            break
    rest = out or name
    for s in suf:
        if rest.endswith(s) and len(rest) > len(s) and (out is None or kind == "address"):
            out = rest[:-len(s)].rstrip("_")
            break
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--src", required=True)
    ap.add_argument("--sym", nargs="+", required=True, help="the symbol files whose routine names count")
    ap.add_argument("--taken", nargs="*", default=[], help="files whose names a new name must not reuse "
                    "(.equ lines, or labels.sym rows)")
    ap.add_argument("--not-ram", action="append", default=[], metavar="LO:HI",
                    help="a range in the RAM space that is code, not variables (the KN2400's RAM-linked code)")
    ap.add_argument("--out", required=True)
    ap.add_argument("--report")
    ap.add_argument("--title", required=True)
    a = ap.parse_args()
    not_ram = [tuple(int(x, 0) for x in r.split(":")) for r in a.not_ram]

    own = GI.load_syms([a.out]) if os.path.exists(a.out) else {}
    syms = {cpu: nm for cpu, nm in GI.load_syms(a.sym).items() if nm not in set(own.values())}
    named = set(syms.values())
    ram_name = {nm: cpu for cpu, nm in list(syms.items()) + list(own.items()) if is_ram(cpu, not_ram)}
    known_ram = {cpu for cpu, nm in syms.items() if is_ram(cpu, not_ram)}
    taken = set(syms.values())
    for f in a.taken:
        for ln in open(f, "rb"):
            m = re.match(rb"\.equ\s+(\w+)", ln) or re.match(rb"0x[0-9A-Fa-f]+\s+(\w+)", ln)
            if m:
                taken.add(m.group(1).decode())
    taken -= set(own.values())
    taken_l = {t.lower() for t in taken}

    def routine_label(nm):
        return not (re.search(r"_L[0-9a-f]+_*$", nm) or nm.endswith("_entry") or nm.startswith("loc_"))

    routines = read_routines(a.src, routine_label)
    refs = collections.defaultdict(list)            # RAM address -> [routine label]
    for nm, ins in routines:
        for mnem, ops in ins:
            for h in HEX.findall(ops):
                v = int(h, 16)
                if is_ram(v, not_ram):
                    refs[v].append(nm)
            for idt in IDENT.findall(ops):
                v = ram_name.get(idt.decode())
                if v is not None:
                    refs[v].append(nm)

    def body_of(ins):
        return [(m, o) for m, o in ins if m not in ("movm", "nop")
                and not (m == "add" and re.fullmatch(rb"-0x[0-9a-f]+, sp", o))]

    def ram_of(ops):
        vs = [int(h, 16) for h in HEX.findall(ops) if is_ram(int(h, 16), not_ram)]
        vs += [ram_name[i.decode()] for i in IDENT.findall(ops) if i.decode() in ram_name]
        return vs

    # ---- accessors -------------------------------------------------------------
    acc = collections.defaultdict(list)             # address -> [(routine, kind, stem)]
    for nm, ins in routines:
        if nm not in named:
            continue
        b = body_of(ins)
        if not b or b[-1][0] not in RETS:
            continue
        core = [x for x in b[:-1] if x[0] not in EXTS]
        if len(core) != 1 or len(b) - 1 - len(core) > 1:
            continue
        mnem, ops = core[0]
        vs = ram_of(ops)
        if len(vs) != 1 or mnem not in LOADS:
            continue
        if re.fullmatch(rb"\(\w+\), [ad]\d", ops):
            kind = "getter"
        elif re.fullmatch(rb"d\d, \(\w+\)", ops):
            kind = "setter"
        elif re.fullmatch(rb"\w+, [ad]\d", ops) and mnem == "mov":
            kind = "address"
        else:
            continue
        st = stem(nm, kind)
        if st:
            acc[vs[0]].append((nm, kind, st))

    rows, why = {}, collections.Counter()
    used = set()

    def free(n):
        return n not in taken and n.lower() not in taken_l and n not in used

    for v, lst in sorted(acc.items()):
        if v in known_ram:
            why["accessor of an address a symbol file names already"] += 1
            continue
        stems = {s.lower() for _n, _k, s in lst}
        if len(stems) != 1:
            why["accessors that give one address two stems"] += 1
            continue
        st = sorted(lst, key=lambda x: (x[1] != "getter", x[0]))[0][2]
        nm = st if free(st) else st + "_Ram"
        if not free(nm):
            why["accessor stem taken, and its _Ram too"] += 1
            continue
        used.add(nm)
        rows[v] = (nm, "accessor", ", ".join(f"{n} ({k})" for n, k, _s in sorted(lst)))

    # ---- owners ----------------------------------------------------------------
    by_owner = collections.defaultdict(list)
    for v, users in refs.items():
        if v in rows or v in known_ram:
            continue
        u = set(users)
        if len(u) == 1 and next(iter(u)) in named:
            by_owner[next(iter(u))].append(v)
        elif len(u) == 1:
            why["one user, a func_ placeholder"] += 1
        else:
            why["several users"] += 1
    for owner, vs in sorted(by_owner.items()):
        k = 1
        for v in sorted(vs):
            while True:
                nm = f"{owner}_Ram" + ("" if k == 1 else f"_{k}")
                k += 1
                if free(nm):
                    break
            used.add(nm)
            rows[v] = (nm, "owner", f"{len(refs[v])} references, all in {owner}")

    n_ops = {cls: sum(len(refs[v]) for v, r in rows.items() if r[1] == cls) for cls in ("accessor", "owner")}
    with open(a.out, "w") as f:
        f.write(f"; {a.title}\n")
        f.write("; GENERATED by kn7000/tools/name_ram_by_use.py -- do not edit; its header gives the two\n")
        f.write("; evidence classes (accessor: a named Get/Set/Is routine's only variable; owner: every\n")
        f.write("; direct reference lies in one named routine).  Columns: RAM address, name, ; class, evidence.\n;\n")
        f.write(f"; {sum(1 for r in rows.values() if r[1] == 'accessor')} accessor names over {n_ops['accessor']} "
                f"operands, {sum(1 for r in rows.values() if r[1] == 'owner')} owner names over {n_ops['owner']} "
                f"operands; {len(refs)} RAM addresses referenced\n")
        for v, (nm, cls, ev) in sorted(rows.items()):
            f.write(f"0x{v:08X}  {nm}\t; {cls}: {ev}\n")
    if a.report:
        with open(a.report, "w") as f:
            f.write(f"# {a.title}\n\n")
            f.write(f"- RAM addresses referenced: {len(refs)}, operands {sum(len(x) for x in refs.values())}\n")
            for cls in ("accessor", "owner"):
                f.write(f"- {cls}: {sum(1 for r in rows.values() if r[1] == cls)} addresses, {n_ops[cls]} operands\n")
            f.write("- not named:\n")
            for w, n in why.most_common():
                f.write(f"  - {n:6d} {w}\n")
    print(f"name_ram_by_use: {len(rows)} RAM names -> {a.out} "
          f"({n_ops['accessor']} + {n_ops['owner']} operands, accessor + owner)")


if __name__ == "__main__":
    main()
