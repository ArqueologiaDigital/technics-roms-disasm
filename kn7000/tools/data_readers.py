#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
r"""data_readers.py -- how the converted MN10300 code reads the program's data region.

QUESTION ANSWERED
-----------------
"Which instructions read (or write) each data address, at what width and
signedness, and is it an array of records -- base + index * stride + field
offset -- or a record reached through a pointer loaded from another record's
field?"  tools/gen_data_s.py types struct arrays, pointer-arithmetic tables and
the records a pointer field leads to from this evidence; every macro header it
writes cites the readers found here.

HOW
---
Each function of the converted code (src/<build>/*.s, tools/gen_program_s.py's
output) is walked once, in order, with a small symbolic value per register:

  C(c)            a constant
  A(x)            the address x (a data label, Label+N, or a number)
  S(s)            an unknown index times s (mul / mulu by a constant, asl, asl2,
                  add r, r); S(1) is an unknown index
  I(b, s, o)      b + index * s + o: an element of an array of s-byte records
                  at b (s None: the index is unscaled or not known)
  P(key, o)       a pointer loaded from the 32-bit field `key`, plus o

A load or store through a register holding A / I / P is recorded as an access
of that key at that field offset and width; a 32-bit load gives the target
register P(key).  `extb` / `exth` of a just-loaded register marks the access
signed.  A call clobbers d0, d1, a0, a1 (the compiler's scratch registers; d2,
d3, a2, a3 survive) and records which data pointers it was given (a0, a1, d0,
d1) and the constants in d0 / d1 (the length a strncpy / memcpy takes).  A
label after an unconditional transfer starts with no knowledge; any other
label keeps what falls through into it.  [INFERENCE] the walk is linear, so a
value that differs on another path into a label is not seen; the generator
only uses a stride the bytes agree with.

Keys:
  ("abs", x)              the fixed address x (offset folded in)
  ("rec", b, s)           field o of the s-byte records at b (s None: unscaled)
  ("ptr", parentkey, po)  field o of what the 32-bit field po of parentkey
                          points at

RUN (from kn7000/; needs the converted code and src/<build>/program/data/labels.sym)
    python3 tools/data_readers.py [--profile 941] [--addr 0x4873BEE8]
"""

import collections
import glob
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
KN7 = os.path.dirname(HERE)

REGS = ("d0", "d1", "d2", "d3", "a0", "a1", "a2", "a3")
SCRATCH = ("d0", "d1", "a0", "a1")
WIDTH = {"mov": 4, "movhu": 2, "movbu": 1}
# The C library's string / memory / arithmetic routines: what they read through an argument is
# the bytes of a string or block, not fields of a record, so it is not carried into the caller
LIBC = re.compile(r"(str|mem|sprintf|vsprintf|Lib(Div|Mul|Mod))")

Access = collections.namedtuple("Access", "key off width signed rw func cpu insn extra inner bound")


def C(c):
    return ("C", c)


def A(x):
    return ("A", x)


def S(s, bound=None):
    """An unknown index times s; bound: the index is below it (a `cmp` before it, or a byte)."""
    return ("S", s, bound)


def I(b, s, o, inner=None, bound=None):
    return ("I", b, s, o, inner, bound)


def P(key, o):
    return ("P", key, o)


def D(key, o):
    """A parameter in a data register: a pointer if the code dereferences it, else an index."""
    return ("D", key, o)


def _num(t):
    t = t.strip()
    try:
        return int(t, 0)
    except ValueError:
        return None


class Reader:
    """The accesses of one program build's converted code."""

    def __init__(self, src_glob, labels, in_data):
        self.in_data = in_data          # CPU address -> bool
        self.labels = labels            # name -> CPU address (data and code)
        self.accesses = []
        self.calls = collections.Counter()
        for f in sorted(glob.glob(src_glob)):
            self.walk(open(f, encoding="latin-1").read().split("\n"))
        self.resolve_params()
        # what is left relative to a parameter nobody passes a data address in is not data evidence
        self.accesses = [a for a in self.accesses if not self.rooted(a.key)]

    @staticmethod
    def rooted(key):
        """True when key is relative to a function parameter."""
        while key[0] == "ptr":
            p = key[1]
            if p[0] == "param":
                return True
            key = p[1]
        return False

    @staticmethod
    def norm(k, o):
        return (("abs", k[1] + o), 0) if k[0] == "abs" else (k, o)

    def rebase(self, key, off, root, nk, no):
        """key / off, relative to parameter root, for a call that passed nk / no in it."""
        if key == ("ptr", root):
            return self.norm(nk, no + off)
        if key[0] == "ptr" and key[1][0] == "fld":
            inner = self.rebase(key[1][1], key[1][2], root, nk, no)
            if inner is None:
                return None
            return ("ptr", ("fld", inner[0], inner[1])), off
        return None

    def root_of(self, key):
        while key[0] == "ptr":
            p = key[1]
            if p[0] == "param":
                return p
            key = p[1]
        return None

    def resolve_params(self, rounds=4):
        """A callee's accesses through a parameter are accesses of what each caller
        passes in it (one level per round: a caller's own parameter passed on is
        resolved in the next)."""
        done = set()
        for _r in range(rounds):
            by_root = collections.defaultdict(list)
            for a in self.accesses:
                rt = self.root_of(a.key)
                if rt is not None:
                    by_root[rt].append(a)
            new = []
            for i, c in enumerate(self.accesses):
                if not c.rw.startswith("arg") or not c.extra:
                    continue
                if LIBC.match(c.extra[0]):
                    continue        # a C library routine: its argument is the evidence (a string, a block)
                root = ("param", c.extra[0], c.rw.split()[1])
                for x in by_root.get(root, ()):
                    k = (i, id(x))
                    if k in done:
                        continue
                    done.add(k)
                    r = self.rebase(x.key, x.off, root, c.key, c.off)
                    if r is None:
                        continue
                    new.append(x._replace(key=r[0], off=r[1],
                                          extra=x.extra if x.rw.startswith("arg") else ("via", c.func, c.cpu)))
            if not new:
                break
            self.accesses += new

    # -- operands ----------------------------------------------------------------
    def addr_of(self, tok):
        """A data address named by `tok` (Label, Label+N, Label-N or a number), or None."""
        tok = tok.strip()
        m = re.fullmatch(r"([A-Za-z_]\w*)\s*([+-]\s*(?:0x[0-9a-fA-F]+|\d+))?", tok)
        if m:
            a = self.labels.get(m.group(1))
            if a is None:
                return None
            if m.group(2):
                a += int(m.group(2).replace(" ", ""), 0)
            return a if self.in_data(a) else None
        v = _num(tok)
        if v is not None and self.in_data(v & 0xFFFFFFFF):
            return v & 0xFFFFFFFF
        return None

    def imm(self, tok):
        a = self.addr_of(tok)
        if a is not None:
            return A(a)
        v = _num(tok)
        return C(v) if v is not None else None

    # -- arithmetic ----------------------------------------------------------------
    @staticmethod
    def add(x, y):
        """x + y on symbolic values."""
        x = None if x is not None and x[0] == "D" else x
        y = None if y is not None and y[0] == "D" else y
        if x is None or y is None:
            # an address plus an unknown register: an index with no known stride
            for p, q in ((x, y), (y, x)):
                if p is not None and q is None and p[0] == "A":
                    return I(p[1], None, 0)
                if p is not None and q is None and p[0] == "I":
                    return I(p[1], p[2], p[3], p[4] if p[2] is None else (p[4] or 1))
            return None
        if x[0] == "C" and y[0] == "C":
            return C(x[1] + y[1])
        for p, q in ((x, y), (y, x)):
            if q[0] == "C":
                if p[0] == "A":
                    return A(p[1] + q[1])
                if p[0] == "I":
                    return I(p[1], p[2], p[3] + q[1], p[4], p[5])
                if p[0] == "P":
                    return P(p[1], p[2] + q[1])
                if p[0] == "S":
                    return None
            if q[0] == "S":
                if p[0] == "A":
                    return I(p[1], q[1], 0, None, q[2])
                if p[0] == "I":
                    # a second index: the record stride is the larger, the other an array in the record
                    s = p[2]
                    if s is None:
                        return I(p[1], q[1], p[3], None, q[2])
                    if q[1] > s:
                        return I(p[1], q[1], p[3], s, q[2])
                    return I(p[1], s, p[3], q[1], p[5])
                if p[0] == "P":
                    return P(p[1], p[2])
                if p[0] == "S":
                    return S(min(p[1], q[1]))
        return None

    @staticmethod
    def scale(x, k, bound=None):
        if x is not None and x[0] in "DP":
            x = None
        if x is None:
            return S(k, bound)
        if x[0] == "C":
            return C(x[1] * k)
        if x[0] == "S":
            return S(x[1] * k, x[2] or bound)
        return None

    # -- the walk ------------------------------------------------------------------
    MEM = re.compile(r"^\((?:(?P<off>-?(?:0x[0-9a-fA-F]+|\d+))\s*,\s*)?(?P<base>[ad][0-3]|sp)\)$|"
                     r"^\((?P<idx>d[0-3])\s*,\s*(?P<base2>a[0-3])\)$|^\((?P<abs>[^,()]+)\)$")

    def walk(self, lines):
        st = {}
        func, cpu = None, None
        dead = False             # the previous instruction never falls through
        last_load = {}           # register -> index into self.accesses of the load that set it
        for ln in lines:
            code = ln.split("#", 1)[0].rstrip()
            mh = re.match(r"# (\S+)\s+\((?:lib )?CPU (0x[0-9a-fA-F]+)", ln)
            if mh:
                cpu = int(mh.group(2), 16)
            if not code.strip():
                continue
            ml = re.match(r"^([A-Za-z_.$][\w.$]*):", code)
            if ml:
                n = ml.group(1)
                if not n.startswith("loc_") and not n.endswith("_entry"):
                    func, last_load = n, {}
                    # the arguments: a pointer in a0 / a1 / d0 / d1 is followed into the
                    # callers (resolve_params)
                    # (a data register may as well hold an index: "D", a pointer only when used as one)
                    st = {r: (P if r[0] == "a" else D)(("param", n, r), 0) for r in ("a0", "a1", "d0", "d1")}
                    a = self.labels.get(n)
                    cpu = a if a is not None else cpu
                elif dead:
                    st, last_load = {}, {}
                dead = False
                code = code[ml.end():].strip()
                if not code:
                    continue
            parts = code.split(None, 1)
            op = parts[0]
            args = [x.strip() for x in self.split_args(parts[1])] if len(parts) > 1 else []
            dead = op in ("bra", "jmp", "ret", "retf", "rets", "rti")
            self.step(op, args, st, last_load, func, cpu, code.strip())

    @staticmethod
    def split_args(s):
        out, depth, cur = [], 0, ""
        for ch in s:
            if ch in "([":
                depth += 1
            elif ch in ")]":
                depth -= 1
            if ch == "," and depth == 0:
                out.append(cur)
                cur = ""
            else:
                cur += ch
        out.append(cur)
        return out

    def mem(self, tok, st):
        """(key, offset) of a memory operand, or None."""
        m = self.MEM.match(tok)
        if not m:
            return None
        if m.group("abs") is not None:
            a = self.addr_of(m.group("abs"))
            return (("abs", a), 0, None, None) if a is not None else None
        if m.group("idx"):
            v = self.add(st.get(m.group("base2")), st.get(m.group("idx")))
            off = 0
        else:
            if m.group("base") == "sp":
                return None
            v = st.get(m.group("base"))
            off = int(m.group("off"), 0) if m.group("off") else 0
        if v is None:
            return None
        if v[0] == "A":
            return ("abs", v[1] + off), 0, None, None
        if v[0] == "I":
            return ("rec", v[1], v[2]), v[3] + off, v[4], v[5]
        if v[0] in "PD":
            return ("ptr", v[1]), v[2] + off, None, None
        return None

    def record(self, key, off, w, rw, func, cpu, insn, extra=None, inner=None, bound=None):
        if key[0] == "abs":
            key, off = ("abs", key[1] + off), 0
        self.accesses.append(Access(key, off, w, False, rw, func, cpu, insn, extra, inner, bound))
        return len(self.accesses) - 1

    LESS = {"blt": 0, "bcs": 0, "bge": 0, "bcc": 0, "llt": 0, "lcs": 0, "lge": 0, "lcc": 0,
            "ble": 1, "bls": 1, "bgt": 1, "bhi": 1, "lle": 1, "lls": 1, "lgt": 1, "lhi": 1}

    def step(self, op, args, st, last_load, func, cpu, insn):
        R = lambda t: t in REGS     # noqa: E731
        pc = st.pop("#cmp", None)
        if op == "cmp" and len(args) == 2 and R(args[1]) and _num(args[0]) is not None and 0 < _num(args[0]) < 65536:
            st["#cmp"] = (args[1], _num(args[0]))
            return
        if pc and op in self.LESS:
            st["#b" + pc[0]] = pc[1] + self.LESS[op]
            return
        if op in WIDTH and len(args) == 2:
            src, dst = args
            w = WIDTH[op]
            if R(dst) and src.startswith("("):
                mk = self.mem(src, st)
                if mk:
                    key, off, inner, bound = mk
                    i = self.record(key, off, w, "ld", func, cpu, insn, inner=inner, bound=bound)
                    last_load[dst] = i
                    st.pop("#b" + dst, None)
                    if w == 1:
                        st["#b" + dst] = 256      # a byte: an index below 256
                    k2 = self.accesses[i].key
                    o2 = self.accesses[i].off
                    st[dst] = P(("fld", k2, o2), 0) if w == 4 else None
                else:
                    st[dst] = None
                    last_load.pop(dst, None)
                return
            if dst.startswith("(") and (R(src) or src.startswith("-") or _num(src) is not None):
                mk = self.mem(dst, st)
                if mk:
                    self.record(mk[0], mk[1], w, "st", func, cpu, insn, inner=mk[2], bound=mk[3])
                return
            if R(dst) and op == "mov":
                st[dst] = st.get(src) if R(src) else (self.imm(src) if src not in ("sp", "mdr", "psw") else None)
                if R(src) and ("#b" + src) in st:
                    st["#b" + dst] = st["#b" + src]
                else:
                    st.pop("#b" + dst, None)
                last_load.pop(dst, None)
                return
            if R(dst):
                st[dst] = None
            return
        if op in ("extb", "exth") and args and args[0] in last_load:
            i = last_load.pop(args[0])
            a = self.accesses[i]
            if (op == "extb" and a.width == 1) or (op == "exth" and a.width == 2):
                self.accesses[i] = a._replace(signed=True)
            return
        if op in ("extbu", "exthu", "extb", "exth", "ext"):
            if args and st.get(args[0]) is not None and st[args[0]][0] in "DP":
                st[args[0]] = None       # a byte / half-word is an index, not a pointer
            return
        if op == "clr" and args:
            st[args[0]] = C(0)
            return
        if op in ("add", "sub") and len(args) == 2 and R(args[1]):
            src, dst = args
            if R(src):
                if src == dst and op == "add":
                    st[dst] = self.scale(st.get(dst), 2, st.get("#b" + dst))
                elif op == "add":
                    st[dst] = self.add(st.get(dst), st.get(src))
                else:
                    st[dst] = None
            else:
                v = self.imm(src)
                if op == "sub" and v and v[0] == "C":
                    v = C(-v[1])
                elif op == "sub":
                    v = None
                if v is not None and v[0] == "A" and st.get(dst) is not None and st[dst][0] == "C":
                    st[dst] = None if op == "sub" else A(v[1] + st[dst][1])
                else:
                    st[dst] = self.add(st.get(dst), v) if v is not None else None
            last_load.pop(dst, None)
            return
        if op in ("inc", "inc4") and args:
            st[args[0]] = self.add(st.get(args[0]), C(1 if op == "inc" else 4))
            return
        if op in ("mul", "mulu") and len(args) == 2:
            a, b = st.get(args[0]), st.get(args[1])
            a = None if a is not None and a[0] in "DP" else a
            b = None if b is not None and b[0] in "DP" else b
            if a and a[0] == "C" and (b is None or b[0] in "SC"):
                st[args[1]] = self.scale(b, a[1], st.get("#b" + args[1]))
            elif b and b[0] == "C" and (a is None or a[0] == "S"):
                st[args[1]] = self.scale(a, b[1], st.get("#b" + args[0])) if a else S(b[1], st.get("#b" + args[0]))
            else:
                st[args[1]] = None
            return
        if op == "asl2" and args:
            st[args[0]] = self.scale(st.get(args[0]), 4, st.get("#b" + args[0]))
            return
        if op == "asl" and len(args) == 2:
            k = _num(args[0])
            st[args[1]] = self.scale(st.get(args[1]), 1 << k, st.get("#b" + args[1])) if k is not None and k < 16 else None
            return
        if op in ("call", "calls"):
            tgt = args[0] if args else "?"
            tgt = re.sub(r"_entry$", "", tgt)
            self.calls[tgt] += 1
            consts = {r: st[r][1] for r in ("d0", "d1") if st.get(r) and st[r][0] == "C"}
            for r in ("a0", "a1", "d0", "d1"):
                v = st.get(r)
                if v is None or v[0] not in "AIPD":
                    continue
                mk = self.mem(f"({r})" if r[0] == "a" else "(0, a0)", {"a0": v} if r[0] == "d" else st)
                if mk:
                    self.record(mk[0], mk[1], 0, f"arg {r}", func, cpu, insn, (tgt, consts), mk[2], mk[3])
            for r in SCRATCH:
                st[r] = None
                last_load.pop(r, None)
            return
        if op in ("movm", "ret", "retf", "rets", "rti"):
            return
        # anything else that writes its last register operand: unknown
        if args and R(args[-1]) and op not in ("cmp", "btst", "bset", "bclr") and not op.startswith(("b", "l")):
            st[args[-1]] = None
            last_load.pop(args[-1], None)


def load(profile="941"):
    """The Reader of a program build, with gen_data_s's layout for it."""
    sys.path.insert(0, HERE)
    import gen_data_s as G
    G.configure(profile)
    labels = {}
    lab = os.path.join(KN7, G.P["labels"])
    for line in open(lab):
        n, v = line.split()
        labels[n] = int(v, 16)
    sym = os.path.join(KN7, G.OUTDIR, "labels.sym")
    if os.path.exists(sym):
        for line in open(sym):
            if not line.startswith(";"):
                a, n, _ = line.split()
                labels[n] = int(a, 16)
    return Reader(os.path.join(KN7, G.P["src"], "*.s"), labels, G.Gen.in_data)


def main():
    import argparse
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--profile", default="941")
    ap.add_argument("--addr", type=lambda s: int(s, 0))
    a = ap.parse_args()
    os.chdir(KN7)
    r = load(a.profile)
    by = collections.Counter(acc.key[0] for acc in r.accesses)
    print(f"data_readers: {len(r.accesses)} accesses; " + ", ".join(f"{k} {v}" for k, v in by.most_common()))
    if a.addr is not None:
        for acc in r.accesses:
            k = acc.key
            if (k[0] == "abs" and k[1] == a.addr) or (k[0] == "rec" and k[1] == a.addr) or \
                    (k[0] == "ptr" and f"{a.addr}" in repr(k)):
                print(acc)


if __name__ == "__main__":
    main()
