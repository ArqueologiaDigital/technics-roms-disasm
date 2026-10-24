#!/usr/bin/env python3
"""respell_wsa1_macros.py -- WSA1 byte-emitter macro calls -> llvm-mc instructions, proven byte for byte.

QUESTION THIS ANSWERS / JOB IT DOES
  wsa1/include/tlcs900_mem_ops.inc defines ~80 macros that emit TLCS-900 instructions as `.byte`
  runs ("the forms llvm-mc has no encoding for", 2026-08).  The backend has since learned most of
  those forms (wsa1/TOOLCHAIN_VERSION UPDATE 7-10; the KN5000 tree's UPDATE 16-21), so most call
  sites can now be written as instructions.  For every call site this tool:

    1. builds candidate native spellings FROM THE MACRO'S OWN ARGUMENTS (never from unidasm text):
       the prefix argument (MB16, MWD+r6, MXL, RW+r0, RLX, ...) gives the operand size and the
       addressing mode, the remaining arguments give address / displacement / register / bit /
       immediate.  Symbols in the arguments stay symbols in the spelling;
    2. assembles the macro call AND every candidate with the pinned llvm-mc (-filetype=obj, one
       instruction between two labels, so each line's exact byte run is read back from the label
       addresses -- a shorter encoding cannot hide in zero padding).  Symbols are given the values
       the image's linked ELF has for them; a kernel line is checked under BOTH images that
       assemble it (prom_a and prom_c), a maincpu/shared line under prom_a and prom_b;
    3. keeps the FIRST candidate whose bytes equal the macro's bytes under every image;
    4. cross-checks that choice with MAME's unidasm: every register the spelling names must appear
       in unidasm's reading of the same bytes, and the mnemonic must agree (pseudo names such as
       `ldto_lerp`, `ldc_cr16` or `ldir85` are mapped to the mnemonic unidasm prints).  A byte match
       proves the encoding; this guards the NAME -- a parser that accepted the wrong register
       name for the right bytes would otherwise put a false register into the source;
    5. with --apply, writes the chosen lines, rebuilds the images with `make all` (in wsa1/) and
       compares them with the originals; any line that fails to assemble in context (a forward
       reference, say) or whose bytes differ is reverted and the loop repeats until the build is
       byte-identical.  `make gate-wsa1` then proves the whole tree again.

  A call site with no matching candidate is left as a macro and counted under its macro name; the
  summary is the list of backend gaps that remain (recorded in the .inc header and in
  wsa1/notes/llvm/wsa1-macro-respell.md).

  The trailing comment of every rewritten line is kept verbatim (prom_a's `; ADDR  bytes`,
  prom_b's `; ADDR  unidasm-reading`, the kernel's `; A/C  bytes  reading  note`): WSA1 tools read
  the address and bytes, and the comment column is kept where it was.

USAGE
  python3 scripts/converters/respell_wsa1_macros.py --count              # call sites per family
  python3 scripts/converters/respell_wsa1_macros.py --family imm         # dry run, one family
  python3 scripts/converters/respell_wsa1_macros.py --family imm --apply # rewrite + in-context proof
  python3 scripts/converters/respell_wsa1_macros.py --family all --left  # what stays a macro, and why
  python3 scripts/converters/respell_wsa1_macros.py --check              # exit 1 if any call is respellable

  Families: imm bit regmem stack unary memmem branch mx regdirect block (see FAMILY below).
  Needs the images built once (cd wsa1 && make all) for the symbol values.
"""
import argparse
import collections
import os
import re
import subprocess
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
WSA1 = os.path.join(REPO, "wsa1")
INC = os.path.join(WSA1, "include")
MACRO_INC = os.path.join(INC, "tlcs900_mem_ops.inc")
LLVM = os.path.expanduser("~/compartilhado/llvm-project/build/bin")
MC = os.path.join(LLVM, "llvm-mc")
NM = os.path.join(LLVM, "llvm-nm")
OBJCOPY = os.path.join(LLVM, "llvm-objcopy")
UNIDASM = os.path.expanduser("~/compartilhado/tools/unidasm")
SCRATCH = os.environ.get("TMPDIR") or os.path.expanduser("~/compartilhado/tmp")

IMAGES = {  # image -> (ELF, original ROM, rebuilt ROM, base address)
    "a": ("wsa1_prom_a.llvm.elf", "wsa1_prom_a.ic12", "wsa1_prom_a.llvm.rom", 0xF80000),
    "b": ("wsa1_prom_b.llvm.elf", "wsa1_prom_b.ic13", "wsa1_prom_b.llvm.rom", 0xF00000),
    "c": ("wsa1_prom_c.llvm.elf", "wsa1_prom_c.ic28", "wsa1_prom_c.llvm.rom", 0xF80000),
    "d": ("wsa1_prom_d.llvm.elf", "wsa1_prom_d.bin", "wsa1_prom_d.llvm.rom", 0x000000),
}


def images_of(path):
    """which images assemble this source file (from wsa1/Makefile's prerequisite lists)"""
    rel = os.path.relpath(path, WSA1)
    if rel.startswith("kernel/") or rel.startswith("dsp/"):
        return ["a", "c"]
    if rel.startswith("maincpu/shared/"):
        return ["a", "b"]
    return [rel.split("/")[0][-1]]      # prom_a -> a, prom_b -> b, prom_c -> c


R8 = ["w", "a", "b", "c", "d", "e", "h", "l"]
R16 = ["wa", "bc", "de", "hl", "ix", "iy", "iz", "sp"]
R32 = ["xwa", "xbc", "xde", "xhl", "xix", "xiy", "xiz", "xsp"]
REGS = {"b": R8, "w": R16, "l": R32}
CC = ["f", "lt", "le", "ule", "ov", "mi", "z", "c", "t", "ge", "gt", "ugt", "nov", "pl", "nz", "nc"]
# register-address bytes (s_allreg32/16 and s_allreg8) of the CURRENT bank, as the .inc names them
RA = {0xE0: "wa", 0xE4: "bc", 0xE8: "de", 0xEC: "hl", 0xF0: "ix", 0xF4: "iy", 0xF8: "iz", 0xFC: "sp"}
RB8 = {0xE0: "a", 0xE1: "w", 0xE4: "c", 0xE5: "b", 0xE8: "e", 0xE9: "d", 0xEC: "l", 0xED: "h"}

# FAMILY: the unit the tool is applied in (one family, one gate, one commit)
FAMILY = {}
for _m in ("cp", "and", "or", "xor", "add", "sub"):
    FAMILY["m_%s_mi8" % _m] = FAMILY["m_%s_mi16" % _m] = "imm"
FAMILY["m_ld_mi8"] = FAMILY["m_ld_mi16"] = "imm"
for _m in ("bit", "set", "res", "chg", "stcf"):
    FAMILY["m_" + _m] = "bit"
for _m in ("ld_rm", "cp_rm", "add_rm", "sub_rm", "sbc_rm", "and_rm", "or_rm", "xor_rm",
           "cp_mr", "add_mr", "sub_mr", "and_mr", "or_mr", "xor_mr", "ex_mr",
           "st_mr8", "st_mr16", "st_mr32", "lda16", "lda32", "mul", "muls", "div", "divs"):
    FAMILY["m_" + _m] = "regmem"
for _m in ("push", "pop", "popw"):
    FAMILY["m_" + _m] = "stack"
for _m in ("inc", "dec", "rlc_m", "rrc_m", "rl_m", "rr_m", "sla_m", "sra_m", "sll_m", "srl_m",
           "andcf_a", "orcf_a", "xorcf_a", "ldcf_a", "stcf_a", "rld_am"):
    FAMILY["m_" + _m] = "unary"
for _m in ("ld_mm16", "ldw_mm16", "ld_m16m"):
    FAMILY["m_" + _m] = "memmem"
FAMILY["m_jp_cc"] = FAMILY["m_call_cc"] = "branch"
FAMILY["m_ldir"] = FAMILY["m_ldirw"] = "block"


def family_of(mac):
    if mac in FAMILY:
        return FAMILY[mac]
    if mac.startswith("mx"):
        return "mx"
    if mac.startswith("m_rd_") or mac.startswith("m_ldc_"):
        return "regdirect"
    return "other"


# --------------------------------------------------------------------------------------------
# reading the source
# --------------------------------------------------------------------------------------------
def macro_names():
    names = set()
    for line in open(MACRO_INC, "rb").read().decode("latin-1").split("\n"):
        m = re.match(r"\.macro\s+([a-z0-9_]+)", line.split(";")[0])
        if m and not m.group(1).startswith("_"):
            names.add(m.group(1))
    return names


def inc_symbols():
    """names the .inc itself defines -- the test file includes it, so they must not be redefined"""
    out = set()
    for line in open(MACRO_INC, "rb").read().decode("latin-1").split("\n"):
        m = re.match(r"\s*\.(?:equ|set)\s+([A-Za-z_]\w*)", line)
        if m:
            out.add(m.group(1))
    return out


LINE = re.compile(r"^(?P<pre>\s*(?:[A-Za-z_.$][\w.$]*:)?\s*)(?P<mn>m[x8]*_[a-z0-9_]+)(?P<ws>[ \t]+)"
                  r"(?P<ops>[^;]*?)(?P<sep>[ \t]*)(?P<post>;.*)?$")


def source_files():
    out = []
    for dp, dns, fns in os.walk(WSA1):
        dns[:] = [d for d in dns if not d.startswith(".") and d not in ("rebuilt_ROMs", "notes")]
        for fn in sorted(fns):
            if fn.startswith(".") or not (fn.endswith(".s") or fn.endswith(".inc")):
                continue
            p = os.path.join(dp, fn)
            if p != MACRO_INC:
                out.append(p)
    return sorted(out)


def call_sites(known):
    sites, texts = [], {}
    for f in source_files():
        L = open(f, "rb").read().decode("latin-1").split("\n")
        texts[f] = L
        for i, l in enumerate(L):
            m = LINE.match(l)
            if m and m.group("mn") in known:
                args = [a.strip() for a in m.group("ops").split(",")]
                sites.append({"file": f, "idx": i, "m": m, "mac": m.group("mn"), "args": args})
    return sites, texts


# --------------------------------------------------------------------------------------------
# native candidates, from the macro arguments
# --------------------------------------------------------------------------------------------
def num(s):
    try:
        return int(s, 0)
    except (TypeError, ValueError):
        return None


def regidx(s):
    m = re.fullmatch(r"r?([0-7])", s.strip())
    return int(m.group(1)) if m else None


def parse_pfx(p):
    p = p.replace(" ", "")
    m = re.fullmatch(r"M([BWLD])(8|16|24)", p)
    if m:
        return {"kind": "direct", "size": m.group(1).lower(), "width": int(m.group(2))}
    m = re.fullmatch(r"M([BWLD])([ID])\+r?([0-7])", p)
    if m:
        return {"kind": "ind" if m.group(2) == "I" else "disp", "size": m.group(1).lower(),
                "reg": int(m.group(3))}
    m = re.fullmatch(r"MX([BWLD])", p)
    if m:
        return {"kind": "idx", "size": m.group(1).lower()}
    m = re.fullmatch(r"R([BWL])\+r?([0-7])", p)
    if m:
        return {"kind": "rd", "size": m.group(1).lower(), "reg": int(m.group(2))}
    m = re.fullmatch(r"R([BWL])X", p)
    if m:
        return {"kind": "rdx", "size": m.group(1).lower()}
    return None


def mem_ops(pf, addr):
    """operand spellings for a direct / (Rn) / (Rn+d8) memory operand, most natural first"""
    if pf is None:
        return []
    if pf["kind"] == "direct":
        return ["(%s:%d)" % (addr, pf["width"])]
    if pf["kind"] == "ind":
        return ["(%s)" % R32[pf["reg"]]]
    if pf["kind"] == "disp":
        xr = R32[pf["reg"]]
        v = num(addr)
        if v is None:
            return ["(%s+%s:8)" % (xr, addr)]
        if 0x80 <= v <= 0xFF:          # the macro's argument is the RAW displacement byte
            v -= 0x100
        if not -128 <= v <= 127:
            return []
        if v == 0:
            return ["(%s+0:8)" % xr]
        return ["(%s%+d)" % (xr, v), "(%s%+d:8)" % (xr, v)]
    return []


def idx_op(base, idx, eight=False):
    b, i = num(base), num(idx)
    if b is None:
        b = SYMS_INC.get(base)
    if i is None:
        i = SYMS_INC.get(idx)
    if b not in RA or i is None:
        return None
    ii = (RB8 if eight else RA).get(i)
    return None if ii is None else "(x%s+%s)" % (RA[b], ii)


def sized(mn, size, byte_suffix=True):
    """memory-only mnemonic for the operand size the prefix chose"""
    if size == "b":
        return [mn, mn + "b"] if byte_suffix else [mn]
    if size == "w":
        return [mn + "w"]
    if size == "l":
        return [mn + "l"]
    return [mn]


def reg_of(size, r):
    k = regidx(r)
    if k is None:
        return None
    return REGS.get("l" if size == "d" else size, R8)[k]


def mul_regs(size, r):
    """MUL/DIV name a register PAIR: byte form -> the 16-bit register whose low byte the field
    names (1=WA, 3=BC, 5=DE, 7=HL), word form -> the 32-bit register"""
    k = regidx(r)
    if k is None:
        return []
    if size == "b":
        return [R16[k >> 1]] if k & 1 else []
    if size == "w":
        return [R32[k]]
    return []


def candidates(mac, a):
    out = []
    fam = family_of(mac)
    try:
        if fam == "imm":
            pf = parse_pfx(a[0])
            op = mac[2:].split("_")[0]
            if mac in ("m_ld_mi8", "m_ld_mi16"):
                mns = ["ld", "ldb"] if mac == "m_ld_mi8" else ["ldw"]
            else:
                mns = sized(op, pf["size"])
            for o in mem_ops(pf, a[1]):
                for mn in mns:
                    out.append("%s\t%s, %s" % (mn, o, a[2]))
        elif fam == "bit":
            pf = parse_pfx(a[1])
            op = mac[2:]
            for o in mem_ops(pf, a[2]):
                out.append("%s\t%s, %s" % (op, a[0], o))
        elif fam == "regmem":
            pf = parse_pfx(a[0])
            op = mac[2:]
            ops = mem_ops(pf, a[1])
            if op in ("mul", "muls", "div", "divs"):
                for o in ops:
                    for r in mul_regs(pf["size"], a[2]):
                        out.append("%s\t%s, %s" % (op, r, o))
            elif op.endswith("_rm"):
                r = reg_of(pf["size"], a[2])
                for o in ops:
                    out.append("%s\t%s, %s" % (op[:-3], r, o))
            elif op.startswith("st_mr"):
                w = {"8": "b", "16": "w", "32": "l"}[op[5:]]
                r = REGS[w][regidx(a[2])]
                for o in ops:
                    out.append("ld\t%s, %s" % (o, r))
            elif op.endswith("_mr"):
                r = reg_of(pf["size"], a[2])
                for o in ops:
                    out.append("%s\t%s, %s" % (op[:-3], o, r))
            elif op in ("lda16", "lda32"):
                r = (R16 if op == "lda16" else R32)[regidx(a[2])]
                for o in ops:
                    out.append("lda\t%s, %s" % (r, o))
        elif fam == "stack":
            pf = parse_pfx(a[0])
            op = mac[2:]
            mns = {"push": {"b": ["push"], "w": ["pushw"]}.get(pf["size"], []),
                   "pop": ["pop"], "popw": ["popw"]}[op]
            for o in mem_ops(pf, a[1]):
                for mn in mns:
                    out.append("%s\t%s" % (mn, o))
        elif fam == "unary":
            op = mac[2:]
            if op in ("inc", "dec"):
                pf = parse_pfx(a[1])
                for o in mem_ops(pf, a[2]):
                    for mn in sized(op, pf["size"]):
                        out.append("%s\t%s, %s" % (mn, a[0], o))
            elif op.endswith("cf_a") or op == "rld_am":
                pf = parse_pfx(a[0])
                mn = op[:-2] if op.endswith("cf_a") else "rld"
                for o in mem_ops(pf, a[1]):
                    out.append("%s\ta, %s" % (mn, o))
            else:                                       # the eight shifts/rotates
                pf = parse_pfx(a[0])
                for o in mem_ops(pf, a[1]):
                    for mn in sized(op[:-2], pf["size"]):
                        out.append("%s\t%s" % (mn, o))
        elif fam == "memmem":
            pf = parse_pfx(a[0])
            if mac == "m_ld_m16m":                      # prefix = SOURCE, trailing = destination
                mn = {"b": "ld", "w": "ldw"}.get(pf["size"])
                for o in mem_ops(pf, a[1]):
                    out.append("%s\t(%s), %s" % (mn, a[2], o))
                    out.append("%s\t(%s:16), %s" % (mn, a[2], o))
            else:                                       # prefix = DESTINATION, trailing = source
                mn = "ld" if mac == "m_ld_mm16" else "ldw"
                for o in mem_ops(pf, a[1]):
                    out.append("%s\t%s, (%s)" % (mn, o, a[2]))
                    out.append("%s\t%s, (%s:16)" % (mn, o, a[2]))
        elif fam == "branch":
            pf = parse_pfx(a[0])
            cc = num(a[2])
            mn = mac[2:].split("_")[0]
            for o in mem_ops(pf, a[1]):
                out.append("%s\t%s, %s" % (mn, CC[cc & 15], o))
        elif fam == "mx":
            out = mx_candidates(mac, a)
        elif fam == "regdirect":
            out = rd_candidates(mac, a)
        elif fam == "block":
            p = num(a[0])
            if p is not None:
                base = "ldir" if mac == "m_ldir" else "ldirw"
                out = ["%s%02x" % (base, p), base]
    except (TypeError, KeyError, IndexError, ValueError):
        return []
    return [c for c in out if c and "None" not in c]


def mx_candidates(mac, a):
    out = []
    eight = mac.startswith("mx8_")
    op = mac.split("_", 1)[1]
    if op in ("res", "set", "bit"):
        n, pfx, base, idx = a[0], a[1], a[2], a[3]
        o = idx_op(base, idx, eight)
        return ["%s\t%s, %s" % (op, n, o)]
    pfx, base, idx = a[0], a[1], a[2]
    size = parse_pfx(pfx)["size"]
    o = idx_op(base, idx, eight)
    if o is None:
        return []
    last = a[3] if len(a) > 3 else None
    if op == "ld_rm" or op in ("and_rm", "or_rm", "add_rm", "sub_rm", "cp_rm"):
        out.append("%s\t%s, %s" % (op[:-3], reg_of(size, last), o))
    elif op in ("or_mr", "cp_mr"):
        out.append("%s\t%s, %s" % (op[:-3], o, reg_of(size, last)))
    elif op.startswith("st_mr"):
        w = {"8": "b", "16": "w", "32": "l"}[op[5:]]
        out.append("ld\t%s, %s" % (o, REGS[w][regidx(last)]))
    elif op in ("lda32", "lda16"):
        out.append("lda\t%s, %s" % ((R32 if op == "lda32" else R16)[regidx(last)], o))
    elif op == "ld_mi8":
        out += ["ld\t%s, %s" % (o, last), "ldb\t%s, %s" % (o, last)]
    elif op == "ld_mi16":
        out.append("ldw\t%s, %s" % (o, last))
    elif op in ("cp_mi8", "and_mi8", "or_mi8"):
        for mn in sized(op[:-4], size):
            out.append("%s\t%s, %s" % (mn, o, last))
    elif op == "jp_cc":
        out.append("jp\t%s, %s" % (CC[num(last) & 15], o))
    elif op == "ld_mm16":
        out += ["ld\t%s, (%s)" % (o, last), "ld\t%s, (%s:16)" % (o, last)]
    return out


def rd_candidates(mac, a):
    """register-direct operand.  Real mnemonics first; then the spellings the backend gives the
    forms it has no real-mnemonic syntax for -- the same ones the KN5000 tree is written in
    (ldto_*/ldfr_* erp, push_lerp, ldc_cr16, stcf_a_16 ...; CLAUDE.md encoding table)."""
    out = []
    op = mac[len("m_rd_"):] if mac.startswith("m_rd_") else mac[2:]
    pf = parse_pfx(a[0])
    sz = pf["size"]
    if pf["kind"] == "rd":
        R = REGS[sz][pf["reg"]]
        if op in ("push", "pop"):
            out.append("%s\t%s" % (op, R))
        elif op.endswith("cf_a"):
            mn = op[:-2]
            out += ["%s\ta, %s" % (mn, R), "%s_a_%d\t%s" % (mn, {"b": 8, "w": 16, "l": 32}[sz], R)]
        elif op in ("add_rr", "ld_rr"):
            r = REGS[sz][regidx(a[1])]
            out.append("%s\t%s, %s" % (op[:-3], r, R))
        elif op == "ld_rr2":
            r = REGS[sz][regidx(a[1])]
            out.append("ld\t%s, %s" % (R, r))
        elif op in ("ldc_cr_reg", "ldc_reg_cr"):
            bits = {"b": 8, "w": 16, "l": 32}[sz]
            cr = a[1]
            if op == "ldc_cr_reg":
                out += ["ldc\t%s, %s" % (cr, R), "ldc_cr%d\t%s, %s" % (bits, R, cr)]
            else:
                out += ["ldc\t%s, %s" % (R, cr), "ldc_%d_cr\t%s, %s" % (bits, R, cr)]
    elif pf["kind"] == "rdx":
        reg = a[1]
        e = {"b": "b", "w": "w", "l": "l"}[sz]
        if op in ("pushx", "popx"):
            base = op[:-1]
            out += ["%s_%serp\t%s" % (base, e, reg), "%s%s_erp\t%s" % (base, "w" if e == "w" else e, reg)]
            if e == "l":
                out.insert(0, "%s_lerp\t%s" % (base, reg))
        elif op.endswith("cf_ax"):
            mn = op[:-3]
            out += ["%s%s_erp\t%s" % (mn, e, reg), "%s_%serp\t%s" % (mn, e, reg)]
        elif op == "ld_rrx":
            out.append("ldto_%serp\t%s, %s" % (e, REGS[sz][regidx(a[2])], reg))
        elif op == "ld_rr2x":
            out.append("ldfr_%serp\t%s, %s" % (e, REGS[sz][regidx(a[2])], reg))
        elif op == "add_rrx":
            out += ["add%s_erp\t%s, %s" % (e, REGS[sz][regidx(a[2])], reg),
                    "add_%serp\t%s, %s" % (e, REGS[sz][regidx(a[2])], reg)]
    return out


# --------------------------------------------------------------------------------------------
# assembling
# --------------------------------------------------------------------------------------------
SYMS_INC = {}


def elf_symbols(img):
    elf = os.path.join(WSA1, "rebuilt_ROMs", IMAGES[img][0])
    if not os.path.exists(elf):
        sys.exit("%s missing: run `make all` in wsa1/ first" % elf)
    r = subprocess.run([NM, elf], capture_output=True, text=True, check=True)
    out = {}
    for l in r.stdout.split("\n"):
        p = l.split()
        if len(p) == 3 and re.fullmatch(r"[A-Za-z_][\w]*", p[2]):
            out[p[2]] = int(p[0], 16)
    return out


def preamble(syms, skip):
    return "".join(".equ %s, 0x%x\n" % (k, v) for k, v in sorted(syms.items()) if k not in skip)


def assemble(lines, pre, tmp):
    """-> list of bytes (None for a line llvm-mc refused), one per line.  Each line sits between
    labels S<i>/E<i>; its bytes are exactly .text[S_i:E_i], whatever its length."""
    res = [None] * len(lines)
    live = list(range(len(lines)))
    for _round in range(8):
        if not live:
            break
        body = []
        for k, i in enumerate(live):
            body.append("__rsS%d:\t%s\n__rsE%d:\t.balign 16, 0x00\n" % (k, lines[i], k))
        head = '.include "tlcs900_mem_ops.inc"\n' + pre + ".text\n"
        hl = head.count("\n")
        s, o = os.path.join(tmp, "t.s"), os.path.join(tmp, "t.o")
        open(s, "w", encoding="latin-1").write(head + "".join(body))
        r = subprocess.run([MC, "-triple=tlcs900", "-filetype=obj", "-I", INC, "-o", o, s],
                           capture_output=True, text=True, encoding="latin-1")
        bad = set()
        for m in re.finditer(r"t\.s:(\d+):\d+: error", r.stderr):
            k = (int(m.group(1)) - hl - 1) // 2
            if 0 <= k < len(live):
                bad.add(k)
        if r.returncode != 0:
            if not bad:
                sys.exit("llvm-mc failed with no attributable line:\n" + r.stderr[:2000])
            live = [i for k, i in enumerate(live) if k not in bad]
            continue
        b = os.path.join(tmp, "t.bin")
        subprocess.run([OBJCOPY, "-O", "binary", "--only-section=.text", o, b], check=True)
        data = open(b, "rb").read()
        nm = subprocess.run([NM, o], capture_output=True, text=True).stdout
        addr = {}
        for l in nm.split("\n"):
            p = l.split()
            if len(p) == 3 and re.fullmatch(r"__rs[SE]\d+", p[2]):
                addr[p[2]] = int(p[0], 16)
        for k, i in enumerate(live):
            res[i] = data[addr["__rsS%d" % k]:addr["__rsE%d" % k]]
        break
    return res


def unidasm(seqs, tmp):
    blob, offs = b"", []
    for s in seqs:
        offs.append(len(blob))
        blob += s
    p = os.path.join(tmp, "u.bin")
    open(p, "wb").write(blob)
    r = subprocess.run([UNIDASM, p, "-arch", "tlcs900", "-basepc", "0"], capture_output=True,
                       text=True, encoding="latin-1").stdout
    at = {}
    for l in r.split("\n"):
        m = re.match(r"^\s*([0-9a-fA-F]+):\s+((?:[0-9a-f]{2} )+)\s*(.*)$", l)
        if m:
            at[int(m.group(1), 16)] = (len(m.group(2).split()), m.group(3).strip())
    return [at[o][1] if o in at and at[o][0] == len(s) else None for s, o in zip(seqs, offs)]


ALLREGS = set(R8 + R16 + R32)
PSEUDO = [(r"^ldto_[bwl]erp$|^ldfr_[bwl]erp$", "ld"), (r"^push_?[bwl]?_?erp$|^push_lerp$", "push"),
          (r"^pop_?[bwl]?_?erp$|^pop_lerp$", "pop"), (r"^ldc_", "ldc"), (r"^ldirw\w+$", "ldir"),
          (r"^ldir\w+$", "ldir"), (r"^(\w+cf)_a_\d+$", r"\1"), (r"^(\w+cf)[bwl]?_erp$", r"\1"),
          (r"^add[bwl]?_erp$|^add_[bwl]erp$", "add")]


def canon_mn(mn):
    mn = mn.lower()
    for pat, rep in PSEUDO:
        if re.search(pat, mn):
            mn = re.sub(r"^.*$", rep, mn) if "\\1" not in rep else re.sub(pat, rep, mn)
            break
    if mn in ("ldirw",):
        mn = "ldir"
    if mn not in ("ldcf", "stcf", "andcf", "orcf", "xorcf", "sll", "srl", "rl", "call", "bit",
                  "rlc", "rrc", "rr", "sla", "sra", "ld", "add", "sub", "and", "or", "xor", "cp",
                  "push", "pop", "inc", "dec", "chg", "set", "res", "ex", "lda", "mul", "muls",
                  "div", "divs", "jp", "ldc", "ldir"):
        mn = re.sub(r"[bwl]$", "", mn)
    return mn


def names_agree(native, reading):
    """does unidasm's reading of the bytes agree with the spelling's mnemonic and registers?"""
    if not reading:
        return False
    nm, _, nops = native.partition("\t")
    um, _, uops = reading.partition(" ")
    if canon_mn(nm) != canon_mn(um):
        return False
    utoks = set(re.findall(r"[a-z]+\d?", uops.lower()))
    for t in re.findall(r"(?<![\w:])[a-z]+\b", nops.lower()):
        if t in ALLREGS and t not in utoks:
            return False
    return True


def addresses_agree(native, reading, syms):
    """two DIRECT addresses in one instruction (ld (mem),(mem)): llvm-mc decides from the width tag
    which one goes into the prefix, so the byte match alone cannot tell the operands apart.  The
    addresses the spelling names, in order, must be the ones unidasm reads, in order."""
    ops = [o for o in re.findall(r"\(([A-Za-z_]\w*|0x[0-9a-fA-F]+|\d+)(?::\d+)?\)", native)
           if o.lower() not in ALLREGS]
    if len(ops) < 2:
        return True
    val = [num(o) if num(o) is not None else syms.get(o) for o in ops]
    got = [int(x, 16) for x in re.findall(r"\(0x([0-9a-f]+)\)", reading or "")]
    return len(got) == len(val) and all(v is not None and (v & 0xFFFFFF) == g for v, g in zip(val, got))


# --------------------------------------------------------------------------------------------
def choose(sites, fams, tmp):
    """-> {site index: native text}, plus Counter of reasons for the rest"""
    skip = inc_symbols()
    global SYMS_INC
    SYMS_INC = {}
    for line in open(MACRO_INC, "rb").read().decode("latin-1").split("\n"):
        m = re.match(r"\s*\.equ\s+([A-Za-z_]\w*)\s*,\s*(0x[0-9a-fA-F]+|\d+)", line)
        if m:
            SYMS_INC[m.group(1)] = int(m.group(2), 0)
    sel = [k for k, s in enumerate(sites) if family_of(s["mac"]) in fams]
    cands = {k: candidates(sites[k]["mac"], sites[k]["args"]) for k in sel}
    imgs = sorted({i for k in sel for i in images_of(sites[k]["file"])})
    symv = {i: elf_symbols(i) for i in imgs}
    pres = {i: preamble(symv[i], skip) for i in imgs}
    macro_bytes = {}                                    # (k, img) -> bytes
    cand_bytes = {}                                     # (k, j, img) -> bytes
    for img in imgs:
        ks = [k for k in sel if img in images_of(sites[k]["file"])]
        lines = ["%s %s" % (sites[k]["mac"], ", ".join(sites[k]["args"])) for k in ks]
        for k, b in zip(ks, assemble(lines, pres[img], tmp)):
            macro_bytes[(k, img)] = b
        cl, own = [], []
        for k in ks:
            for j, c in enumerate(cands[k]):
                cl.append(c)
                own.append((k, j))
        for (k, j), b in zip(own, assemble(cl, pres[img], tmp) if cl else []):
            cand_bytes[(k, j, img)] = b
    best, why = {}, collections.Counter()
    for k in sel:
        s = sites[k]
        ii = images_of(s["file"])
        if any(macro_bytes.get((k, i)) is None for i in ii):
            why[(s["mac"], "macro call does not assemble standalone")] += 1
            continue
        if not cands[k]:
            why[(s["mac"], "no native spelling built from these arguments")] += 1
            continue
        for j, c in enumerate(cands[k]):
            if all(cand_bytes.get((k, j, i)) == macro_bytes[(k, i)] for i in ii):
                best[k] = c
                break
        else:
            got = [cand_bytes.get((k, j, ii[0])) for j in range(len(cands[k]))]
            why[(s["mac"], "refused by llvm-mc" if all(g is None for g in got)
                 else "assembles, but to different bytes")] += 1
    # the NAME check: unidasm over the chosen bytes
    ks = sorted(best)
    seqs = [macro_bytes[(k, images_of(sites[k]["file"])[0])] for k in ks]
    for k, rd in zip(ks, unidasm(seqs, tmp)):
        img0 = images_of(sites[k]["file"])[0]
        if not names_agree(best[k], rd) or not addresses_agree(best[k], rd, symv[img0]):
            why[(sites[k]["mac"], "bytes match but unidasm reads other names: %s | %s"
                 % (best[k].replace("\t", " "), rd))] += 1
            del best[k]
    return sel, best, why


def rewrite(site, native):
    m = site["m"]
    code_old = m.group("pre") + m.group("mn") + m.group("ws") + m.group("ops")
    # CLAUDE.md "Lowercase Hex": a number copied from the macro's arguments may be `0x3C`; a hex
    # digit inside a symbol name (`_0x5D`) is not at a word boundary and keeps its case
    native = re.sub(r"\b0[xX][0-9A-Fa-f]+\b", lambda x: x.group(0).lower(), native)
    code_new = m.group("pre") + native
    post = m.group("post")
    if not post:
        return code_new
    sep = m.group("sep")
    if sep and "\t" not in sep:                         # spaces padding the comment to a column
        col = len((code_old + sep).expandtabs(8))
        sep = " " * max(1, col - len(code_new.expandtabs(8)))
    elif not sep:
        sep = " "
    return code_new + sep + post


def build_and_compare():
    """-> (errors {(file, idx)}, diff {img: [rom addresses]}) after `make all` in wsa1/"""
    r = subprocess.run(["make", "all"], cwd=WSA1, capture_output=True, text=True, encoding="latin-1")
    errs = set()
    for m in re.finditer(r"^([^\s:]+\.(?:s|inc)):(\d+):\d+: error", r.stderr, re.M):
        errs.add((os.path.normpath(os.path.join(WSA1, m.group(1))), int(m.group(2)) - 1))
    if r.returncode != 0:
        return errs or {("?", -1)}, {}
    diffs = {}
    for img, (_e, orig, built, base) in IMAGES.items():
        a = open(os.path.join(WSA1, "original_ROMs", orig), "rb").read()
        b = open(os.path.join(WSA1, "rebuilt_ROMs", built), "rb").read()
        if a != b:
            diffs[img] = [base + i for i, (x, y) in enumerate(zip(a, b)) if x != y][:200] or [base]
    return errs, diffs


def site_addrs(site):
    """ROM addresses from the trailing comment (`; F80000 ...`, `; F8568F/F981F4 ...`)"""
    post = site["m"].group("post") or ""
    m = re.match(r";\s*([0-9A-F]{6})(?:/([0-9A-F]{6}))?\b", post)
    return [int(x, 16) for x in m.groups() if x] if m else []


def write_files(texts, files):
    for f in files:
        data = "\n".join(texts[f]).encode("latin-1")
        with open(f + ".tmp", "wb") as fh:
            fh.write(data)
        os.replace(f + ".tmp", f)


def apply(sites, texts, best):
    orig = {f: list(L) for f, L in texts.items()}
    live = dict(best)
    touched = sorted({sites[k]["file"] for k in live})
    for _round in range(40):
        for f in touched:
            texts[f] = list(orig[f])
        for k, nat in live.items():
            texts[sites[k]["file"]][sites[k]["idx"]] = rewrite(sites[k], nat)
        write_files(texts, touched)
        errs, diffs = build_and_compare()
        if not errs and not diffs:
            return live
        drop = set()
        if errs:
            for k in live:
                if (sites[k]["file"], sites[k]["idx"]) in errs:
                    drop.add(k)
        else:
            for img, addrs in diffs.items():
                for k in live:
                    if img not in images_of(sites[k]["file"]):
                        continue
                    for a0 in site_addrs(sites[k]):
                        if any(a0 <= x < a0 + 8 for x in addrs):
                            drop.add(k)
            if not drop:                                # cannot attribute: halve the set
                ks = sorted(live)
                drop = set(ks[len(ks) // 2:])
                print("  !! a byte difference no comment address explains: bisecting (%d dropped)"
                      % len(drop))
        if not drop:
            break
        print("  in-context: reverting %d line(s) (%s)" % (len(drop), "assembly error" if errs else "bytes differ"))
        for k in drop:
            live.pop(k)
    for f in touched:
        texts[f] = list(orig[f])
    write_files(texts, touched)
    sys.exit("in-context verification did not converge; sources restored")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--family", default="all")
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--count", action="store_true")
    ap.add_argument("--left", action="store_true", help="list why sites stay macros")
    ap.add_argument("--check", action="store_true",
                    help="exit 1 if any macro call has a byte-proven native spelling (run after a merge)")
    a = ap.parse_args()
    known = macro_names()
    sites, texts = call_sites(known)
    if a.count:
        fam = collections.Counter(family_of(s["mac"]) for s in sites)
        mac = collections.Counter(s["mac"] for s in sites)
        per = collections.Counter(os.path.relpath(s["file"], WSA1).split("/")[0] for s in sites)
        print("%d macro call sites" % len(sites))
        print("  by tree:   " + ", ".join("%s %d" % kv for kv in sorted(per.items())))
        print("  by family: " + ", ".join("%s %d" % kv for kv in fam.most_common()))
        for m, n in mac.most_common():
            print("    %-16s %-9s %6d" % (m, family_of(m), n))
        return 0
    fams = set(FAMILY.values()) | {"mx", "regdirect"} if a.family == "all" else set(a.family.split(","))
    os.makedirs(SCRATCH, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=SCRATCH) as tmp:
        sel, best, why = choose(sites, fams, tmp)
    print("families %s: %d call sites, %d respellable, %d stay macros"
          % (",".join(sorted(fams)), len(sel), len(best), len(sel) - len(best)))
    bym = collections.Counter(sites[k]["mac"] for k in sel)
    okm = collections.Counter(sites[k]["mac"] for k in best)
    for m, n in bym.most_common():
        print("  %-16s %6d sites  %6d respelled  %6d left" % (m, n, okm[m], n - okm[m]))
    if a.left or not a.apply:
        for (m, r), n in sorted(why.items(), key=lambda x: -x[1]):
            print("  left %5d  %-16s %s" % (n, m, r))
    if a.check:
        print("check: %s" % ("PASS -- no macro call has a native spelling" if not best else
                             "FAIL -- %d macro call(s) can be respelled: run --apply" % len(best)))
        return 1 if best else 0
    if a.apply and best:
        live = apply(sites, texts, best)
        print("applied: %d lines rewritten in-context, images byte-identical (%d reverted)"
              % (len(live), len(best) - len(live)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
