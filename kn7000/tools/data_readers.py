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

CALLEE (Reader(callee=True), lane callee-walk 2026-10-30; profile key `readers_callee`)
  The arguments: the compiler passes pointers in a0 / a1 and numbers in d0 / d1 (a function spills
  them to (frame + 8, sp) / (frame + 12, sp) when it needs them later: DrawString_entry's
  `mov a1, (0x3c, sp)` / `mov a0, (0x38, sp)` with a 0x30 frame), and the rest on the stack: the
  caller stores word N at (N, sp) of its own frame (N = 16, 20, ...; DrawString's string at
  (0x10, sp), SetApTimer's message argument at (0x18, sp)), and the callee reads it at
  (N + its frame, sp), its frame being what its prologue (`movm [regs], (sp)`: 4 bytes a register;
  `add -K, sp`) or the call's own frame field (`call F_entry, [regs], K`) sets up.  So:
    * a call records each word of the caller's frame that holds a data address or a parameter as
      an argument `spN` (beside a0, a1, d0, d1), and a function reading (N + frame, sp) before it
      wrote there reads its parameter spN; the frame's slots are followed (ext's stack-slot rule;
      without ext, the siblings', a slot gives back only a data address or a parameter);
    * without ext, a label two paths reach with different data addresses holds one of them (ext's
      T join), and a function's return value one of a set (ext's return rule), so a switch that
      selects a record and returns it is followed into its callers;
    * a label nothing branches to after a computed jump (`jmp (a0)`, a jump table's case) takes the
      addresses and parameters the dispatch held [INFERENCE];
    * a branch to a named label that is no function (`bne DrawString_DrawNow`) is a branch inside
      the function (ext would start a new function there, losing the parameters);
    * a pointer parameter stepped (`inc a0`, `add 2, a0`) between a label and a branch back to it
      (or a setlb .. Lcc loop) is stepped by a loop: param_steps;
    * resolve_params carries each callee's accesses through a parameter into the parameters its
      callers pass on (4 rounds: the depth limit), and collect_arg_layouts() keeps, per (function,
      parameter), arg_layout -- every access relative to the parameter, the routine's own and its
      callees', keyed ("ptr", ("arg", F, slot)) -- and arg_calls -- the calls passing a fixed data
      address in it.  tools/gen_data_s.py arg_kinds() types each such block as a record of that
      layout (ptr_records(only_arg=True)), unless the routine is a library one, reads nothing at a
      fixed offset, reads it byte by byte in a loop, or reads only its first field.

TYPER (lane mn10300-typer 2026-10-31; flags of Reader, set from gen_data_s.FEATURES)
  * array_end: `cmp End, aN` and a branch back (bcs / blt / bne, or the Lcc of a setlb loop) taken while
    aN is below End, aN holding data address B at the loop head and B + s at the compare: a ("bound", B)
    access, off End - B, width s (loop_bound); `cmp aM, aN` within one parameter's block gives the
    parameter's record count (param_count);
  * loop_index: a constant c in a data register the loop writes (loop_scan) is an induction variable at
    the head (loop_head): unknown (c = 0), or S(1) starting at c, which keeps the first element's offset;
    a pointer plus a scaled index keeps the scale (an access's bound for a parameter's indexed array);
    `cmp N, dR` before the branch back, dR from c, one `inc dR` in the loop: N - c iterations (loop_count);
  * mem_ptrs: a slot (a fixed word, a field of a record a pointer field leads to, a field of a block a
    parameter points at) that every store fills with data addresses, NULL or the storing function's own
    parameter (standing for what its callers pass) gives a load from it those addresses (memory_slots;
    field_stores for a field gen_data_s keys, a T value otherwise);
  * chains: an address register holding P(K) at a loop head and P(field f of it) at the branch back walks
    a chain of records of kind K through f (loop_close): a "chain" access.

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

# A local label: loc_<ADDR> (the KN7000 programs' gen_program_s.py), <function>_L<hex> (the siblings'
# gen_image_s.py: KN6000, KN6500, KN2400, the HD-SX3 plug-in); a function's own labels, not functions.
LOCAL = re.compile(r"^loc_|_L[0-9a-f]+_*$")
SIB_LOCAL = re.compile(r"_L[0-9a-f]+_*$")

# pos (lane mn10300-rest): where the instruction is, (file index in the sorted code glob, line index in
# that file), so tools/data_field_uses.py follows the loaded register from that very place
Access = collections.namedtuple("Access", "key off width signed rw func cpu insn extra inner bound pos",
                                defaults=(None,))


def C(c):
    return ("C", c)


def A(x):
    return ("A", x)


def S(s, bound=None, start=0):
    """An unknown index times s; bound: the index is below it (a `cmp` before it, or a byte); start
    (loop_index): the bytes the index's first value contributes -- a loop counter that starts at a
    constant c gives start c * s, the offset of the first element the loop reaches."""
    return ("S", s, bound) if not start else ("S", s, bound, start)


def s_start(v):
    return v[3] if v is not None and v[0] == "S" and len(v) > 3 else 0


def I(b, s, o, inner=None, bound=None):
    return ("I", b, s, o, inner, bound)


def P(key, o, dyn=False):
    """A pointer loaded from field `key`, plus o; dyn: plus an index the walk does not know."""
    return ("P", key, o, dyn)


def D(key, o):
    """A parameter in a data register: a pointer if the code dereferences it, else an index."""
    return ("D", key, o)


def T(addrs):
    """(ext) a pointer to one of the data addresses `addrs`: what reaches a label from several
    paths that load different addresses (a switch selecting a record), a stack slot that holds
    one of them, or what a function returns in a0 when every path returns one of them."""
    return P(("tgt", frozenset(addrs)), 0)


def addrs_of(v):
    """The data addresses value v is one of (an A, or a T), else None."""
    if v is None:
        return None
    if v == ("C", 0):
        return set()           # NULL: a path that selects no record
    if v[0] == "A":
        return {v[1]}
    if v[0] == "P" and v[1][0] == "tgt" and v[2] == 0 and not v[3]:
        return set(v[1][1])
    return None


TGT_MAX = 512        # (ext) the most addresses a T value holds; a larger join is dropped


def join(a, b):
    """(ext) the value at a label two paths reach with a and b."""
    if a == b:
        return a
    for p, q in ((a, b), (b, a)):
        if p == ("C", 0) and q is not None and q[0] == "P" and q[1][0] == "fld":
            return q            # NULL on one path, a pointer from a field on the other
    sa, sb = addrs_of(a), addrs_of(b)
    if sa is not None and sb is not None and sa | sb and len(sa | sb) <= TGT_MAX:
        return T(sa | sb)
    return None


def _num(t):
    t = t.strip()
    try:
        return int(t, 0)
    except ValueError:
        return None


class Reader:
    """The accesses of one program build's converted code."""
    DYN_STRIDE = False       # (loop_index) a pointer plus a scaled index keeps the scale (add())

    def __init__(self, src_glob, labels, in_data, distinct=False, ext=False, callee=False, array_end=False,
                 mem_ptrs=False, loop_index=False, chains=False, word=None, top_tested=False,
                 fld_slots=False):
        self.in_data = in_data          # CPU address -> bool
        self.distinct = distinct
        self.labels = labels            # name -> CPU address (data and code)
        self.accesses = []
        self.calls = collections.Counter()
        self.rets = collections.defaultdict(list)     # function -> its a0 at each return
        self.ret_val = {}
        # ext (lane kn7000-final): also follow values through the function's stack slots
        # (`mov aN, (8, sp)` ... `mov (8, sp), a0`), join the data addresses different paths
        # bring to a label into a T value (one of them), and give a call's a0 what the callee
        # returns there (a first walk collects each function's returned addresses)
        self.ext, self.returns, self.tgt_origin, self.returns_p = ext, {}, {}, {}
        # callee (lane callee-walk): the arguments a call passes on the stack (`mov aN, (0x18, sp)`
        # ... `call F`) are F's parameters sp24 ..., read in F as (0x18 + F's frame, sp); the frame's
        # slots are followed (the stack-slot rule of ext, also without the rest of ext); and each
        # (function, parameter) keeps the accesses through it: arg_layout / arg_calls below
        self.callee = callee
        self.slots = ext or callee
        self._frame, self._spd, self._func = 0, 0, None
        # (callee) the steps a loop adds to a parameter pointer: {(function, slot): {step}}
        self.param_steps = collections.defaultdict(set)
        self._lab_line, self._psteps, self._line = {}, [], 0
        self._pos = (0, 0)            # (file index, line index) of the instruction being walked
        # (array_end) the address registers at each label / setlb of the function, and a pending
        # `cmp Addr, aN` (register, Addr, aN's address) for the instruction after it
        self.array_end = array_end
        self._lab_state, self._cmpa = {}, None
        # (top_tested, lane mn10300-rest; gen_data_s.FEATURES) a pointer loop that tests at its head
        # ends its array too: {head label: (register, End, B, the compare)} of the function
        self.top_tested = array_end and top_tested
        self._toptest = {}
        # (lane mn10300-typer) mem_ptrs: a data address stored to a RAM global, a zero-initialised data
        # word or a field of a record reached from one, and loaded back (memslots below); loop_index: a
        # constant in a data register the loop writes is its induction variable at the loop head, not
        # that constant; chains: a pointer a loop advances through its own field (a list); word(a): the
        # initial 32-bit value of data address a (the image's), or None
        self.mem_ptrs, self.loop_index, self.chains, self.word = mem_ptrs, loop_index, chains, word
        Reader.DYN_STRIDE = loop_index
        self.mem_ptr = {}             # slot -> frozenset of the data addresses stored there
        # (fld_slots, lane mn10300-rest) slot -> the pointer every store put there, when that is one
        # pointer loaded from a typed field (P(("fld", key, off))): a load gives the field's targets back
        self.mem_fld = {}
        self.fld_slots = mem_ptrs and fld_slots
        self._mfld, self._mbad_nf = collections.defaultdict(set), set()
        self.field_stores = {}        # a pointer field ("fld", key, off) -> the data addresses stored in it
        self._mstore, self._mbad = collections.defaultdict(set), set()
        self._mparam, self._pvals = collections.defaultdict(set), collections.defaultdict(set)
        self.mem_origin = {}          # frozenset -> the first function storing it (gen_data_s names the kind)
        self._mfunc = {}
        self.param_count = collections.defaultdict(set)   # (function, slot) -> {(step, count)}
        self._scan_memo = {}
        self._lab_dpre = {}
        files = [open(f, encoding="latin-1").read().split("\n") for f in sorted(glob.glob(src_glob))]
        # (callee) the functions: what a `call` names, or a `# Name  (CPU ...)` header; a branch to any
        # other named label (`bne DrawString_DrawNow`) is a branch inside the function, whose state the
        # label takes (ext would otherwise start a new function there, losing the parameters)
        self.funcs = set()
        if callee:
            cx = re.compile(r"^\s+calls?\s+([A-Za-z_]\w*)|^# (\S+)\s+\((?:lib )?CPU 0x", re.M)
            for self._fidx, lines in enumerate(files):
                for mo in cx.finditer("\n".join(lines)):
                    self.funcs.add(re.sub(r"_entry$", "", mo.group(1) or mo.group(2)))
        # (two collecting walks: a wrapper returns what the function it calls returns)
        # (callee without ext: the siblings) the return-value rule too, for one of a set of addresses
        self.rets_t = ext or callee
        for _round in range(2 if self.rets_t else 0):
            self._ret, self._retbad = collections.defaultdict(set), set()
            self._retv = collections.defaultdict(set)
            self._mstore, self._mbad, self._mfunc = collections.defaultdict(set), set(), {}
            self._mfld, self._mbad_nf = collections.defaultdict(set), set()
            self._mparam, self._pvals = collections.defaultdict(set), collections.defaultdict(set)
            for self._fidx, lines in enumerate(files):
                self.walk(lines)
            if self.mem_ptrs:
                self.mem_ptr = self.memory_slots()
                if self.fld_slots:
                    # every store a pointer from one and the same typed field, and nothing else
                    self.mem_fld = {k: next(iter(v)) for k, v in self._mfld.items()
                                    if len(v) == 1 and k not in self._mbad_nf and k not in self._mstore
                                    and k not in self._mparam}
                # a slot that is a field the walk keys (a data word, a field of a record a pointer leads
                # to): its stored addresses are more targets of that field (gen_data_s field_targets)
                self.field_stores = {}
                for k, v in self.mem_ptr.items():
                    if k[0] == "g" and self.in_data(k[1]):
                        self.field_stores[("fld", ("abs", k[1]), 0)] = v
                    elif k[0] == "p":
                        self.field_stores[("fld", ("ptr", k[1]), k[2])] = v
                self.mem_origin = {}
                for k, v in sorted(self.mem_ptr.items(), key=repr):
                    self.mem_origin.setdefault(v, self._mfunc.get(k))
            self.accesses, self.calls = [], collections.Counter()
            self.rets = collections.defaultdict(list)
            self.returns = {f: a for f, a in self._ret.items() if a and f not in self._retbad
                            and len(a) <= TGT_MAX}
            # the function a set of records is the result of (gen_data_s names their kind after it)
            self.tgt_origin = {frozenset(a): f for f, a in sorted(self.returns.items())}
            self.returns_p = {f: next(iter(vs)) for f, vs in self._retv.items()
                              if len(vs) == 1 and None not in vs and f not in self.returns}
        for self._fidx, lines in enumerate(files):
            self.walk(lines)
        if distinct:
            # (siblings) a function that returns the same record address in a0 on every path
            # (an accessor: `mov 0x18, d0 / mulu d2, d0 / add Table, a0 / ret`) gives its callers
            # that value: walk again with it
            # (or one of a few: func_48641CCD picks one of the KN2400's two style tables; the
            # callers' reads through it are then reads of each, "U" below)
            self.ret_val = {}
            for f, v in self.rets.items():
                alts = tuple(sorted(set(v), key=repr))
                if alts and all(x is not None and x[0] in "AI" for x in alts) and len(alts) <= 4:
                    self.ret_val[f] = alts[0] if len(alts) == 1 else ("U", alts)
            if self.ret_val:
                self.accesses, self.calls = [], collections.Counter()
                for self._fidx, lines in enumerate(files):
                    self.walk(lines)
        if distinct:
            self.resolve_params_distinct()
        else:
            self.resolve_params()
        if callee:
            self.collect_arg_layouts()
        # what is left relative to a parameter nobody passes a data address in is not data evidence
        self.accesses = [a for a in self.accesses if not self.rooted(a.key)]

    def collect_arg_layouts(self):
        """(callee) For each (function, parameter): arg_layout, the accesses through the parameter
        (the function's own and, resolve_params having carried them in, those of the routines it
        passes the parameter on to, up to its rounds), keyed relative to ("arg", function, slot);
        and arg_calls, the calls that pass a data address (a fixed one, or one of a T set) in it."""
        self.arg_layout = collections.defaultdict(list)
        self.arg_calls = collections.defaultdict(list)
        seen = set()
        for a in self.accesses:
            rt = self.root_of(a.key)
            if rt is not None:
                if not (a.width or a.rw.startswith("arg")):
                    continue
                b = a._replace(key=self.reroot(a.key, rt))
                sg = (b.key, b.off, b.width, b.signed, b.rw, b.func, b.cpu, b.insn, b.inner)
                if sg not in seen:
                    seen.add(sg)
                    self.arg_layout[(rt[1], rt[2])].append(b)
            elif a.rw.startswith("arg") and a.extra and a.extra[0] != "via" and not LIBC.match(str(a.extra[0])):
                if a.key[0] == "abs" or (a.key[0] == "ptr" and a.key[1][0] == "tgt" and a.inner is None):
                    self.arg_calls[(re.sub(r"_entry$", "", a.extra[0]), a.rw.split()[1])].append(a)
        # a parameter handed on (at +0) to a routine that steps its own through a loop is stepped too
        for _r in range(4):
            grew = False
            for k, lay in self.arg_layout.items():
                for b in lay:
                    if b.rw.startswith("arg") and b.key == ("ptr", ("arg",) + k) and b.off == 0 and b.extra \
                            and b.extra[0] != "via":
                        inner = self.param_steps.get((re.sub(r"_entry$", "", str(b.extra[0])), b.rw.split()[1]))
                        if inner and not inner <= self.param_steps[k]:
                            self.param_steps[k] |= inner
                            grew = True
            if not grew:
                break

    @classmethod
    def reroot(cls, key, root):
        """key with its parameter root ("param", f, r) written ("arg", f, r)."""
        if key == ("ptr", root):
            return ("ptr", ("arg",) + root[1:])
        p = key[1]
        return ("ptr", ("fld", cls.reroot(p[1], root), p[2]))

    @staticmethod
    def rooted(key):
        """True when key is relative to a function parameter."""
        while key[0] == "ptr":
            p = key[1]
            if p[0] == "param":
                return True
            if p[0] != "fld":
                return False
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
            if p[0] != "fld":
                return None
            key = p[1]
        return None

    def resolve_params(self, rounds=4):
        """A callee's accesses through a parameter are accesses of what each caller
        passes in it (one level per round: a caller's own parameter passed on is
        resolved in the next)."""
        done = set()
        # (ext) one access per (key, field, width, kind, instruction): a callee's read seen through
        # many call sites that pass the same thing is one piece of evidence, and without this the
        # rounds multiply (stack-slot tracking keeps the callees' spilled parameters)
        seen = {(a.key, a.off, a.width, a.rw, a.insn, a.cpu) for a in self.accesses} if self.ext else None
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
                    if seen is not None:
                        sk = (r[0], r[1], x.width, x.rw, x.insn, x.cpu, c.func)
                        if sk in seen:
                            continue
                        seen.add(sk)
                    new.append(x._replace(key=r[0], off=r[1],
                                          extra=x.extra if x.rw.startswith("arg") else ("via", c.func, c.cpu)))
            if not new:
                break
            self.accesses += new

    @staticmethod
    def sig(a):
        """An access without its call constants (a dict): what makes two of them the same."""
        return (a.key, a.off, a.width, a.signed, a.rw, a.func, a.cpu, a.insn,
                a.extra if a.extra is None or a.extra[0] == "via" else a.extra[0], a.inner, a.bound)

    def resolve_params_distinct(self, rounds=4):
        """resolve_params, keeping each resulting access once and joining only what the last
        round added (new calls with every callee access, every call with the new callee
        accesses).  The siblings' converted code (KN2400 above all) passes parameters on through
        so many calls that the pairwise version does not fit in memory."""
        seen = {self.sig(a) for a in self.accesses}
        all_roots = collections.defaultdict(list)
        all_calls = []

        def split(accs):
            roots, calls = collections.defaultdict(list), []
            for a in accs:
                rt = self.root_of(a.key)
                if rt is not None:
                    roots[rt].append(a)
                if a.rw.startswith("arg") and a.extra and a.extra[0] != "via" and not LIBC.match(a.extra[0]):
                    calls.append(a)
            return roots, calls
        new_roots, new_calls = split(self.accesses)
        for _r in range(rounds):
            for k, v in new_roots.items():
                all_roots[k] += v
            all_calls += new_calls
            out = []
            for calls, roots in ((new_calls, all_roots), (all_calls, new_roots)):
                for c in calls:
                    root = ("param", c.extra[0], c.rw.split()[1])
                    for x in roots.get(root, ()):
                        r = self.rebase(x.key, x.off, root, c.key, c.off)
                        if r is None:
                            continue
                        y = x._replace(key=r[0], off=r[1],
                                       extra=x.extra if x.rw.startswith("arg") else ("via", c.func, c.cpu))
                        sg = self.sig(y)
                        if sg not in seen:
                            seen.add(sg)
                            out.append(y)
            if not out:
                break
            self.accesses += out
            new_roots, new_calls = split(out)

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
        for p, q in ((x, y), (y, x)):
            if p is not None and p[0] == "P" and (q is None or q[0] == "S"):
                # (dyn: the index's scale when the walk knows it -- an array of that many bytes a
                # record or a parameter holds, read with an index: mem() keeps it as the access's bound)
                return P(p[1], p[2] + s_start(q), q[1] if Reader.DYN_STRIDE and q is not None and q[1] >= 2
                         and p[3] in (False, q[1]) else True)
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
                    return P(p[1], p[2] + q[1], p[3])
                if p[0] == "S":
                    return S(p[1], p[2], s_start(p) + q[1]) if s_start(p) else None
            if q[0] == "S":
                st0 = s_start(q)
                if p[0] == "A":
                    # (loop_index) the array is at Base; the loop's first element at +start (a field
                    # offset of start modulo the stride: a counter from 1 reads element 1 first)
                    return I(p[1], q[1], st0, None, q[2])
                if p[0] == "I":
                    # a second index: the record stride is the larger, the other an array in the record
                    s = p[2]
                    if s is None:
                        return I(p[1], q[1], p[3] + st0, None, q[2])
                    if q[1] > s:
                        return I(p[1], q[1], p[3] + st0, s, q[2])
                    return I(p[1], s, p[3] + st0, q[1], p[5])
                if p[0] == "P":
                    return P(p[1], p[2])
                if p[0] == "S":
                    return S(min(p[1], q[1]), None, s_start(p) + st0)
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
            return S(x[1] * k, x[2] or bound, s_start(x) * k)
        return None

    # -- the walk ------------------------------------------------------------------
    MEM = re.compile(r"^\((?:(?P<off>-?(?:0x[0-9a-fA-F]+|\d+))\s*,\s*)?(?P<base>[ad][0-3]|sp)\)$|"
                     r"^\((?P<idx>d[0-3])\s*,\s*(?P<base2>a[0-3])\)$|^\((?P<abs>[^,()]+)\)$")

    def walk(self, lines):
        if not hasattr(self, "_ret"):
            self._ret, self._retbad = collections.defaultdict(set), set()
            self._retv = collections.defaultdict(set)
        st = {}
        pending = {}             # forward-branch target -> the state the branches carried there
        func, cpu, header = None, None, None
        site = None              # (siblings) the label an access is cited under: the function or its _L<hex>
        dead = False             # the previous instruction never falls through
        last_load = {}           # register -> index into self.accesses of the load that set it
        ijmp = None              # (callee) the state at the function's computed jump
        heads = self.loop_scan(lines) if (self.loop_index or self.callee) else {}
        for k_line, ln in enumerate(lines):
            self._line += 1
            self._pos = (getattr(self, "_fidx", 0), k_line)
            code = ln.split("#", 1)[0].rstrip()
            mh = re.match(r"# (\S+)\s+\((?:lib )?CPU (0x[0-9a-fA-F]+)", ln)
            if mh:
                cpu = int(mh.group(2), 16)
                header = mh.group(1)
            if not code.strip():
                continue
            ml = re.match(r"^([A-Za-z_.$][\w.$]*):", code)
            if ml:
                n = ml.group(1)
                if SIB_LOCAL.search(n):
                    # (a sibling's local label) cited under its own name and address
                    site = n
                    a = self.labels.get(n)
                    cpu = a if a is not None else cpu
                # (ext) a named label inside a function (`DrawIcons_Impl_RowLoop:`, fallen into) is a
                # branch label too: a function starts at a label its `# Name  (CPU ...)` header names,
                # or one nothing falls into and no branch above reaches
                fstart = not LOCAL.search(n) and not n.endswith("_entry")
                if fstart and self.ext and header != n and not (dead and n not in pending):
                    fstart = False
                header = None
                if fstart:
                    func, last_load = n, {}
                    site = n
                    ijmp = None
                    self._func = n            # (step's `func` is the site: a sibling's _L<hex> label)
                    # (callee) the frame the prologue (`movm [..], (sp)`, `add -N, sp`) sets up
                    self._spd, self._frame = 0, None
                    self._lab_line, self._psteps = {}, []
                    self._lab_state, self._cmpa = {}, None
                    self._toptest = {}
                    # the arguments: a pointer in a0 / a1 / d0 / d1 is followed into the
                    # callers (resolve_params)
                    # (a data register may as well hold an index: "D", a pointer only when used as one)
                    st = {r: (P if r[0] == "a" else D)(("param", n, r), 0) for r in ("a0", "a1", "d0", "d1")}
                    a = self.labels.get(n)
                    cpu = a if a is not None else cpu
                    pending = {}
                else:
                    # what the forward branches to this label carried: a label reached only by
                    # jumps takes their common state, one also reached by falling in keeps only
                    # what agrees with it
                    came = pending.pop(n, None)
                    if dead and came is None and self.callee and ijmp is not None:
                        # (callee) reached by no branch the walk sees, after the function's computed jump
                        # (`mov (d0, a0), a0` / `jmp (a0)`): a case of its jump table, entered with the
                        # addresses and parameters the dispatch held [INFERENCE: a label a loop reaches
                        # backwards takes them too]
                        st, last_load = dict(ijmp), {}
                    elif dead and came is None and self.ext:
                        # reached only by a backward branch (a loop body the compiler puts before its
                        # test): the frame's slots keep what the code before the loop stored there
                        # [INFERENCE: a slot the loop rewrites, a stepped pointer, keeps its start]
                        st, last_load = {k: v for k, v in st.items() if k.startswith("sp:")}, {}
                    elif dead:
                        st, last_load = (dict(came) if came is not None else {}), {}
                    elif came is not None:
                        if self.ext:
                            st = self.merge(st, came)
                        else:
                            a0 = (st.get("a0"), came.get("a0"))
                            st0 = st
                            st = {k: v for k, v in st.items() if came.get(k) == v}
                            if self.callee:
                                st.update(self.join_addrs(st0, came, st))
                            if self.distinct and a0[0] != a0[1] and all(v is not None and v[0] in "AI" for v in a0):
                                # (siblings) a0 is one of two record addresses here: kept for the return value
                                st["a0"] = ("U", a0)
                dead = False
                self._lab_line[n] = self._line
                if self.array_end or self.chains:
                    self._lab_state[n] = {r: st.get(r) for r in REGS if r[0] == "a"}
                    self._last_lab, self._since_lab = n, 0
                if k_line in heads:
                    self.loop_head(n, heads[k_line], st)
                code = code[ml.end():].strip()
                if not code:
                    continue
            parts = code.split(None, 1)
            op = parts[0]
            args = [x.strip() for x in self.split_args(parts[1])] if len(parts) > 1 else []
            if self.callee and self._frame is None:
                if op == "movm" and len(args) == 2 and args[1] == "(sp)":
                    rl = [r for r in args[0].strip("[]").split(",") if r.strip()]
                    self._spd -= sum(28 if r.strip() == "other" else 4 for r in rl)
                elif op == "add" and len(args) == 2 and args[1] == "sp" and _num(args[0]) is not None:
                    self._spd += _num(args[0])
                else:
                    self._frame = -self._spd
            dead = op in ("bra", "jmp", "ret", "retf", "rets", "rti") or (self.ext and op == "lra")
            if self.callee and op == "jmp" and args and args[0].startswith("("):
                ijmp = {k: v for k, v in st.items() if not k.startswith("#") and (
                    (k.startswith("sp:") and v and addrs_of(v[0]) is not None) or
                    (not k.startswith("sp:") and v is not None and (
                        addrs_of(v) is not None or (v[0] in "PD" and v[1][0] == "param"))))}
            if self.callee:
                # (callee) a branch back to a label above, or a hardware loop's Lcc back to its setlb:
                # a parameter pointer stepped since then is stepped by a loop
                if op == "setlb":
                    self._lab_line["#setlb"] = self._line
                back = None
                if (op.startswith("b") or op == "jmp") and args and args[0] in self._lab_line:
                    back = self._lab_line[args[0]]
                elif re.fullmatch(r"l(eq|ne|lt|gt|ge|le|cs|cc|hi|ls|ra)", op) and "#setlb" in self._lab_line:
                    back = self._lab_line["#setlb"]
                if back is not None:
                    cnt = self.loop_count(op, args, st) if self.loop_index else None
                    for ln_, key_, c_ in self._psteps:
                        if ln_ > back:
                            self.param_steps[key_].add(c_)
                            if cnt:
                                self.param_count[key_].add((c_, cnt))
            if op == "setlb" and k_line in heads:
                self.loop_head("#setlb", heads[k_line], st)
                if self.chains:
                    self._lab_state["#setlb"] = {r: st.get(r) for r in REGS if r[0] == "a"}
            if self.array_end:
                self.loop_bound(op, args, st, site or func, cpu, code.strip())
            if self.chains:
                self.loop_close(op, args, st, site or func, cpu, code.strip())
            if (op.startswith("b") or op == "jmp") and args and (LOCAL.search(args[0]) or (
                    self.callee and re.fullmatch(r"[A-Za-z_]\w*", args[0]) and args[0] not in self.funcs
                    and not args[0].endswith("_entry"))) and op not in ("btst", "bset", "bclr"):
                t = args[0]
                snap = {k: v for k, v in st.items() if not k.startswith("#cmp")}
                if op in self.LESS and "#cmp" in st:
                    pass                  # (the bound is applied by step below, on both paths)
                prev = pending.get(t)
                pending[t] = snap if prev is None else self.merge(prev, snap)
            if op in ("ret", "retf", "rets"):
                v = st.get("a0")
                self.rets[func] += list(v[1]) if v is not None and v[0] == "U" else [v]
            self.step(op, args, st, last_load, site or func, cpu, code.strip())

    # -- loops (lane mn10300-typer) ----------------------------------------------------
    BRANCH_OP = re.compile(r"^(?:b(?!tst$|set$|clr$)[a-z]+|bra|jmp)$")
    LCC_OP = re.compile(r"^l(?:eq|ne|lt|gt|ge|le|cs|cc|hi|ls|ra)$")

    def loop_scan(self, lines):
        """{line index (in `lines`) of a loop head -- a label a later branch of the same stretch of code
        jumps back to, or a setlb an Lcc returns to --: (the registers written in the loop, {register:
        the number of `inc R` / `add 1, R` among its writes}, the registers written otherwise)}.  A
        loop is at most 2,000 lines long; labels are forgotten at a `# Name  (CPU ...)` header (a new
        function)."""
        key = id(lines)
        if key in self._scan_memo:
            return self._scan_memo[key]
        labels, heads, setlb, parsed = {}, {}, None, []
        for k, ln in enumerate(lines):
            if re.match(r"# \S+\s+\((?:lib )?CPU 0x", ln):
                labels, setlb = {}, None
            code = ln.split("#", 1)[0].strip()
            ml = re.match(r"^([A-Za-z_.$][\w.$]*):", code)
            if ml:
                labels[ml.group(1)] = k
                code = code[ml.end():].strip()
            if not code:
                parsed.append(None)
                continue
            parts = code.split(None, 1)
            op = parts[0]
            args = [x.strip() for x in self.split_args(parts[1])] if len(parts) > 1 else []
            parsed.append((op, args))
            if op == "setlb":
                setlb = k
            tgt = None
            if self.BRANCH_OP.match(op) and args and args[0] in labels:
                tgt = labels[args[0]]
            elif self.LCC_OP.match(op) and setlb is not None:
                tgt = setlb
            if tgt is None or not 0 <= k - tgt < 2000:
                continue
            wr, inc, oth = heads.get(tgt, (set(), collections.Counter(), set()))
            for q in parsed[tgt:k + 1]:
                if q is None:
                    continue
                o2, a2 = q
                if o2 in ("call", "calls"):
                    wr |= set(SCRATCH)
                    oth |= set(SCRATCH)
                    continue
                if not a2 or a2[-1] not in REGS or o2 in ("cmp", "btst", "bset", "bclr") or \
                        self.BRANCH_OP.match(o2) or self.LCC_OP.match(o2):
                    continue
                r = a2[-1]
                wr.add(r)
                if (o2 == "inc" and len(a2) == 1) or (o2 == "add" and len(a2) == 2 and _num(a2[0]) == 1):
                    inc[r] += 1
                else:
                    oth.add(r)
            heads[tgt] = (wr, inc, oth)
        self._scan_memo[key] = heads
        return heads

    def loop_head(self, name, info, st):
        """At a loop head (label `name`, or "#setlb"): keep the data registers' values for loop_count(),
        and (loop_index) forget a constant in a data register the loop writes -- it is the loop's
        induction variable there, an index the walk does not know, not the value it starts at
        (DrawBitmapSPFast16_Impl's palette index starts at 0x20)."""
        self._lab_dpre[name] = ({r: st.get(r) for r in REGS if r[0] == "d"}, info)
        if self.loop_index:
            for r in info[0]:
                if r[0] == "d" and st.get(r) is not None and st[r][0] == "C":
                    # (an index from 0 is the unknown index the ext setlb rule already gives; one from c
                    # keeps c, the first element the loop reaches; a bound a `cmp` of an earlier loop
                    # gave the register is not this loop's)
                    st[r] = S(1, None, st[r][1]) if st[r][1] else None
                    st.pop("#b" + r, None)

    def loop_count(self, op, args, st):
        """(loop_index, at a branch back) The number of times the loop runs when its counter is proven:
        the instruction before is `cmp N, dR`, the branch repeats while dR < N (or != N), dR held a
        constant c <= N - 2 at the head and the loop writes it only by one `inc dR` / `add 1, dR`: N - c
        times.  Else None."""
        pc = st.get("#cmp")
        if pc is None or op not in self.LOOP_WHILE_BELOW:
            return None
        lab = "#setlb" if op.startswith("l") else (args[0] if args else None)
        pre = self._lab_dpre.get(lab)
        if pre is None:
            return None
        vals, (wr, inc, oth) = pre
        reg, n = pc
        v0 = vals.get(reg)
        if v0 is not None and v0[0] == "C" and 0 <= v0[1] and inc.get(reg) == 1 and reg not in oth and n - v0[1] >= 2:
            return n - v0[1]
        return None

    def loop_close(self, op, args, st, func, cpu, insn):
        """(chains) At a branch back to a loop head: an address register that held a pointer P(K) at the
        head and holds the pointer loaded from field f of it now (`mov (f, a0), a0`) walks a chain of
        records of one kind through their field f (a list): recorded as a "chain" access of ("ptr", K)
        at offset f; gen_data_s.py types every record the chain reaches as that kind."""
        if self.BRANCH_OP.match(op) and args and args[0] in self._lab_state and args[0] in self._lab_line:
            lab = args[0]
        elif self.LCC_OP.match(op) and "#setlb" in self._lab_state:
            lab = "#setlb"
        else:
            return
        for r, h in self._lab_state[lab].items():
            c = st.get(r)
            if h is None or c is None or h[0] != "P" or c[0] != "P" or h[2] or c[2] or h[3] or c[3]:
                continue
            if c[1][0] == "fld" and c[1][1] == ("ptr", h[1]) and h[1][0] in ("fld", "tgt"):
                self.record(("ptr", h[1]), c[1][2], 0, "chain", func, cpu, insn)

    # -- memory slots (mem_ptrs, lane mn10300-typer) ----------------------------------------
    def memory_slots(self):
        """(After a collecting walk) {slot: frozenset of data addresses}: the slots every store fills
        with a data address (or NULL), a set the walk knows, or a parameter of the storing function --
        which stands for the data addresses its callers pass in it [INFERENCE: the calls that pass
        something else are not counted against it].  A ("pf", (F, slot), off) store, to field off of
        the block parameter `slot` of F points at, is a store to each block its callers pass there."""
        vals = collections.defaultdict(set)
        bad = set(self._mbad)
        for k, v in self._mstore.items():
            vals[k] |= v
        for k, ps in self._mparam.items():
            for p in ps:
                vals[k] |= {x for x in self._pvals.get(p, ()) if self.in_data(x)}
        out = collections.defaultdict(set)
        for k, v in vals.items():
            if k[0] == "pf":
                (F, r), off = k[1], k[2]
                if k in bad:
                    for b in self._pvals.get((F, r), ()):
                        bad.add(("g", b + off))
                    continue
                for b in self._pvals.get((F, r), ()):
                    out[("g", b + off)] |= v
                    self._mfunc.setdefault(("g", b + off), self._mfunc.get(k))
            else:
                out[k] |= v
        return {k: frozenset(v) for k, v in out.items() if v and k not in bad and len(v) <= TGT_MAX}

    def abs_addr(self, tok):
        """Any address `tok` names (Label, Label+N or a number), not only a data address."""
        tok = tok.strip()
        m = re.fullmatch(r"([A-Za-z_]\w*)\s*([+-]\s*(?:0x[0-9a-fA-F]+|\d+))?", tok)
        if m:
            a = self.labels.get(m.group(1))
            if a is None:
                return None
            return a + (int(m.group(2).replace(" ", ""), 0) if m.group(2) else 0)
        v = _num(tok)
        return v & 0xFFFFFFFF if v is not None else None

    def slot_key(self, tok, st, stores=False):
        """The memory word a `mov` operand names, when it is one the walk can find again in another
        function: ("g", address) for a fixed address (`(0x500A1CF0)`, `(Label)`, `(8, aN)` with aN a
        known address), ("f", slot, off) for field off of a record whose address was loaded from such a
        slot ("M" below).  Not the stack, not an index, not a parameter's record."""
        m = self.MEM.match(tok)
        if not m or m.group("idx"):
            return None
        if m.group("abs") is not None:
            a = self.abs_addr(m.group("abs"))
            return ("g", a) if a is not None else None
        if m.group("base") == "sp":
            return None
        v = st.get(m.group("base"))
        off = int(m.group("off"), 0) if m.group("off") else 0
        if v is None:
            return None
        if v[0] == "M":
            return ("f", v[1], off)
        if v[0] == "A":
            return ("g", v[1] + off)
        if v[0] == "C" and v[1] >= 0x10000:
            return ("g", (v[1] + off) & 0xFFFFFFFF)       # a fixed address the walk holds as a number (RAM)
        if v[0] == "P" and v[1][0] == "param":
            return ("pf", v[1][1:], v[2] + off) if stores and not v[3] else None
        if v[0] == "P" and not self.rooted(("ptr", v[1])):
            return ("p", v[1], v[2] + off)               # a field of the records a pointer field leads to
        return None

    def step(self, op, args, st, last_load, func, cpu, insn):
        """_step, and (mem_ptrs) what a `mov` to / from a memory slot stores or gives back: a load from
        a slot that every store fills with data addresses (or NULL) holds one of them (a T value), when
        the walk knew nothing better (a zero-initialised data word: not the 0 it starts as); a load of an
        address register from another slot outside the stack holds an "M" value, a record only this rule
        follows (its fields are slots too).  "M" is no address: no other rule reads it."""
        msk = None
        if self.mem_ptrs and op in WIDTH and len(args) == 2:
            src, dst = args
            if dst in REGS and src.startswith("(") and op == "mov":
                msk = (dst, self.slot_key(src, st))
            elif dst.startswith("("):
                sk = self.slot_key(dst, st, stores=True)
                if sk is not None:
                    v = st.get(src) if src in REGS else None
                    vs = addrs_of(v) if op == "mov" else None
                    if vs is not None:
                        self._mstore[sk] |= vs
                        self._mfunc.setdefault(sk, func)
                    elif op == "mov" and v is not None and v[0] in "PD" and v[1][0] == "param" and not v[2] \
                            and (v[0] == "D" or not v[3]):
                        self._mparam[sk].add(v[1][1:])        # the storing function's own parameter
                        self._mfunc.setdefault(sk, func)
                    elif self.fld_slots and op == "mov" and v is not None and v[0] == "P" and v[1][0] == "fld" \
                            and not v[2] and not v[3] and sk[0] != "p":
                        # (fld_slots) a pointer the code loaded from a typed field (a table entry); for
                        # mem_ptr's data-address slots it spoils the slot, as before
                        self._mfld[sk].add(v)
                        self._mfunc.setdefault(sk, func)
                        self._mbad.add(sk)
                    else:
                        self._mbad.add(sk)
                        self._mbad_nf.add(sk)
        self._step(op, args, st, last_load, func, cpu, insn)
        if msk is not None and msk[1] is not None:
            dst, sk = msk
            vs = self.mem_ptr.get(sk)
            cur = st.get(dst)
            if sk[0] == "p" or (sk[0] == "g" and self.in_data(sk[1])):
                pass                     # a field the walk keys: field_stores gives gen_data_s its targets
            elif vs is not None and cur is None:
                st[dst] = T(vs)
            elif cur is None and sk in self.mem_fld:
                st[dst] = self.mem_fld[sk]    # (fld_slots) the field's targets, as if loaded from it
            elif cur is None and dst[0] == "a":
                st[dst] = ("M", sk)

    # the branches that repeat a loop while the stepped pointer is below (or not at) the address compared
    LOOP_WHILE_BELOW = {"bcs", "blt", "bne", "lcs", "llt", "lne"}
    # (top_tested) the branches that leave a loop once the pointer reaches the address compared
    LOOP_EXIT_AT_END = {"bcc", "bge", "beq"}

    def loop_bound(self, op, args, st, func, cpu, insn):
        """(array_end, lane mn10300-typer) A pointer loop proven to end at an address: `cmp End, aN`
        followed by a branch back to a label above (or an Lcc back to its setlb) taken while aN < End
        (bcs / blt / bne and their Lcc forms), aN holding the data address B at that label and B + s at
        the compare (stepped only by constants on the way: the walk would otherwise not know it), with
        End - B a whole number (>= 2) of s.  Recorded as a ("bound", B) access, off = End - B,
        width = s: the array the loop walks is (End - B) / s records of s bytes from B.  A loop that
        tests before its body (`cmp End, aN` / a forward exit / `bra` back) is not taken: its step is not
        seen before the compare [the KernelWaitRelease probe loop and the MainMmmControl loops are the
        bottom-tested kind]."""
        pend, self._cmpa = self._cmpa, None
        self._since_lab = getattr(self, "_since_lab", 99) + 1
        if self.top_tested and self.BRANCH_OP.match(op) and op in ("bra", "jmp") and args and \
                args[0] in self._toptest and args[0] in self._lab_state:
            # (lane mn10300-rest) the branch back of a loop that tests at its head: the pointer has
            # stepped by s since the compare saw it at B
            reg, end, b, cmp_insn = self._toptest[args[0]]
            h, c = self._lab_state[args[0]].get(reg), st.get(reg)
            if h is not None and c is not None and h[0] == c[0] == "A" and h[1] == b:
                step = c[1] - b
                if 1 <= step <= 4096 and end > b and (end - b) % step == 0 and (end - b) // step >= 2:
                    self.record(("bound", b), end - b, step, "bound", func, cpu, cmp_insn)
            return
        if op == "setlb":
            self._lab_state["#setlb"] = {r: st.get(r) for r in REGS if r[0] == "a"}
            return
        if op == "cmp" and len(args) == 2 and args[1] in ("a0", "a1", "a2", "a3"):
            v, p = (st.get(args[0]) if args[0] in REGS else self.imm(args[0])), st.get(args[1])
            if v is not None and v[0] == "A" and p is not None and p[0] == "A":
                self._cmpa = (args[1], v[1], p[1], insn)
            elif v is not None and p is not None and v[0] == p[0] == "P" and v[1] == p[1] and v[1][0] == "param" \
                    and not v[3] and not p[3]:
                # (a parameter's block: the end the loop compares with is the parameter plus a constant)
                self._cmpa = (args[1], ("param", v[1], v[2]), p[2], insn)
            return
        if self.top_tested and pend is not None and op in self.LOOP_EXIT_AT_END and args and \
                args[0] not in self._lab_line and not isinstance(pend[1], tuple) and \
                getattr(self, "_last_lab", None) in self._lab_state and self._since_lab <= 4:
            # (lane mn10300-rest) a loop that tests before its body: `L: cmp End, aN` / an exit forward
            # taken once aN reaches End / ... / `add s, aN` / `bra L`; the bound is recorded at the
            # branch back, where the step shows
            lab = self._last_lab
            reg, end, p, cmp_insn = pend
            h = self._lab_state[lab].get(reg)
            if h is not None and h[0] == "A" and h[1] == p:
                self._toptest[lab] = (reg, end, p, cmp_insn)
            return
        if pend is None or op not in self.LOOP_WHILE_BELOW or not (args or op.startswith("l")):
            return
        lab = "#setlb" if op.startswith("l") else args[0]
        if lab not in self._lab_state or (lab != "#setlb" and lab not in self._lab_line):
            return                       # not a branch back
        reg, end, p, cmp_insn = pend
        b = self._lab_state[lab].get(reg)
        if isinstance(end, tuple):
            # `cmp aM, aN` within one parameter's block: the loop runs (end - start) / step times
            _k, key, e_off = end
            if b is not None and b[0] == "P" and b[1] == key and not b[3]:
                step = p - b[2]
                if 1 <= step <= 4096 and e_off > b[2] and (e_off - b[2]) % step == 0 and (e_off - b[2]) // step >= 2:
                    self.param_count[key[1:]].add((step, (e_off - b[2]) // step))
            return
        if b is None or b[0] != "A":
            return
        b, step = b[1], p - b[1]
        if 1 <= step <= 4096 and end > b and (end - b) % step == 0 and (end - b) // step >= 2:
            self.record(("bound", b), end - b, step, "bound", func, cpu, cmp_insn)

    def join_addrs(self, a, b, done):
        """(callee without ext: the siblings) what a label two paths reach with states a and b holds
        besides what they agree on: one of the data addresses each brings (a T value, the rule of
        ext's joins), in a register or a frame slot; only addresses, not ext's other values."""
        out = {}
        for k, v in a.items():
            if k in done or k not in b or k.startswith("#"):
                continue
            w = b[k]
            if k.startswith("sp:"):
                if v is not None and w is not None and v[1] == w[1]:
                    j = join(v[0], w[0])
                    if j is not None and addrs_of(j) is not None:
                        out[k] = (j, v[1])
            else:
                j = join(v, w)
                if j is not None and addrs_of(j) is not None:
                    out[k] = j
        return out

    def merge(self, a, b):
        """The state at a label two paths reach with states a and b."""
        if not self.ext:
            out = {k: v for k, v in a.items() if b.get(k) == v}
            if self.callee:
                out.update(self.join_addrs(a, b, out))
            return out
        out = {}
        for k, v in a.items():
            if k in b:
                w = b[k]
                if k.startswith("sp:"):
                    if v[1] == w[1]:
                        j = join(v[0], w[0])
                        if j is not None:
                            out[k] = (j, v[1])
                elif k.startswith("#"):
                    if v == w:
                        out[k] = v
                else:
                    j = join(v, w)
                    if j is not None:
                        out[k] = j
        return out

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
        if v[0] == "P":
            return ("ptr", v[1]), v[2] + off, (-1 if v[3] else None), (v[3] if type(v[3]) is int else None)
        if v[0] == "D":
            return ("ptr", v[1]), v[2] + off, None, None
        return None

    def record(self, key, off, w, rw, func, cpu, insn, extra=None, inner=None, bound=None):
        if key[0] == "abs":
            key, off = ("abs", key[1] + off), 0
        self.accesses.append(Access(key, off, w, False, rw, func, cpu, insn, extra, inner, bound, self._pos))
        return len(self.accesses) - 1

    LESS = {"blt": 0, "bcs": 0, "bge": 0, "bcc": 0, "llt": 0, "lcs": 0, "lge": 0, "lcc": 0,
            "ble": 1, "bls": 1, "bgt": 1, "bhi": 1, "lle": 1, "lls": 1, "lgt": 1, "lhi": 1}

    def _step(self, op, args, st, last_load, func, cpu, insn):
        R = lambda t: t in REGS     # noqa: E731
        pc = st.pop("#cmp", None)
        if op == "cmp" and len(args) == 2 and R(args[1]) and _num(args[0]) is not None and 0 < _num(args[0]) < 65536:
            st["#cmp"] = (args[1], _num(args[0]))
            return
        if pc and op in self.LESS:
            st["#b" + pc[0]] = pc[1] + self.LESS[op]
            return
        if op in WIDTH and len(args) == 2 and any(st.get(r) and st[r][0] == "U" for r in REGS):
            # (siblings) a register holding one of several record addresses: the access is one of each
            ur = next(r for r in REGS if st.get(r) and st[r][0] == "U")
            if ur in "".join(args):
                for alt in st[ur][1][1:]:
                    s2 = dict(st)
                    s2[ur] = alt
                    self.step(op, args, s2, {}, func, cpu, insn)
                st[ur] = st[ur][1][0]
        if op in WIDTH and len(args) == 2 and self.slots:
            src, dst = args
            ms = re.fullmatch(r"\((-?(?:0x[0-9a-fA-F]+|\d+))\s*,\s*sp\)", dst)
            if ms and R(src):
                st["sp:" + ms.group(1)] = (st.get(src), WIDTH[op])
                return
            ms = re.fullmatch(r"\((-?(?:0x[0-9a-fA-F]+|\d+))\s*,\s*sp\)", src)
            if ms and R(dst):
                v = st.get("sp:" + ms.group(1))
                st[dst] = v[0] if v and v[1] == WIDTH[op] else None
                if not self.ext and st[dst] is not None and not (
                        addrs_of(st[dst]) or (st[dst] == ("C", 0) and dst[0] == "a")
                        or (st[dst][0] in "PD" and st[dst][1][0] == "param")):
                    # (callee without ext: the siblings) a slot gives back only what the callee walk
                    # needs, a data address or a parameter (NULL only into an address register: into a
                    # data register it is an index); a pointer loaded from a field, an index,
                    # is not carried (the full rule of ext changes what the siblings' other passes see)
                    st[dst] = None
                if v is None and self.callee and WIDTH[op] == 4 and self._func:
                    # a word of the caller's frame, above this function's own: a stack parameter
                    c = int(ms.group(1), 0) - (self._frame or 0)
                    # (the words below 16 are the return address and the homes the callee itself
                    # spills a0 / a1 to, at +8 / +12: DrawString_entry; not the caller's arguments)
                    if 16 <= c < 0x100:
                        st[dst] = (P if dst[0] == "a" else D)(("param", self._func, f"sp{c}"), 0)
                st.pop("#b" + dst, None)
                last_load.pop(dst, None)
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
                    if self.ext:
                        # a bound a `cmp` gave the register's old value is not the loaded one's
                        st.pop("#b" + dst, None)
                        if w == 1:
                            st["#b" + dst] = 256
                return
            if dst.startswith("(") and (R(src) or src.startswith("-") or _num(src) is not None):
                mk = self.mem(dst, st)
                if mk:
                    self.record(mk[0], mk[1], w, "st", func, cpu, insn, inner=mk[2], bound=mk[3])
                return
            if R(dst) and op == "mov":
                st[dst] = st.get(src) if R(src) else (self.imm(src) if src not in ("sp", "mdr", "psw") else None)
                if not R(src) and st[dst] is not None and st[dst][0] == "A":
                    self.record(("base", st[dst][1]), 0, 0, "base", func, cpu, insn)
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
            c = _num(src)
            v0 = st.get(dst)
            if not R(src) and op == "add":
                vb = self.imm(src)
                if vb is not None and vb[0] == "A":
                    self.record(("base", vb[1]), 0, 0, "base", func, cpu, insn)
            if self.callee and op == "add" and c is not None and 1 <= c <= 4096 and v0 and v0[0] == "P" \
                    and v0[1][0] == "param" and not v0[3]:
                self._psteps.append((self._line, v0[1][1:], c))
            if op == "add" and dst[0] == "a" and c is not None and 2 <= c <= 4096 and v0 and v0[0] == "A":
                # a pointer stepped through an array from its base: the record size
                self.record(("step", v0[1]), c, 0, "step", func, cpu, insn)
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
        if op == "inc4" and args and args[0][0] == "a" and st.get(args[0]) and st[args[0]][0] == "A":
            self.record(("step", st[args[0]][1]), 4, 0, "step", func, cpu, insn)
        if op in ("inc", "inc4") and args:
            v0 = st.get(args[0])
            if self.callee and v0 and v0[0] == "P" and v0[1][0] == "param" and not v0[3]:
                self._psteps.append((self._line, v0[1][1:], 1 if op == "inc" else 4))
            st[args[0]] = self.add(st.get(args[0]), C(1 if op == "inc" else 4))
            return
        if op in ("mul", "mulu") and len(args) == 2:
            a, b = st.get(args[0]), st.get(args[1])
            a = None if a is not None and a[0] in "DP" else a
            b = None if b is not None and b[0] in "DP" else b
            if a and b and a[0] == "C" and b[0] == "C":
                # the compiler folds constant products, so a run-time multiply has a variable
                # operand: one that the walk knows is a loop counter's start (clr / mov 0 or 1);
                # otherwise the larger constant is taken as the record size [INFERENCE]
                k = b[1] if a[1] in (0, 1) else a[1] if b[1] in (0, 1) else max(a[1], b[1])
                st[args[1]] = S(k) if k >= 2 else None
                return
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
            if self.mem_ptrs:
                for r in ("a0", "a1", "d0", "d1"):
                    v_ = st.get(r)
                    vs = addrs_of(v_) or ({v_[1]} if v_ is not None and v_[0] == "C" and v_[1] >= 0x10000 else None)
                    if vs:
                        self._pvals[(tgt, r)] |= vs
                for k_, sv in st.items():
                    if k_.startswith("sp:") and sv and sv[1] == 4 and _num(k_[3:]) is not None \
                            and 16 <= _num(k_[3:]) < 0x100:
                        vs = addrs_of(sv[0])
                        if vs:
                            self._pvals[(tgt, f"sp{_num(k_[3:])}")] |= vs
            for r in ("a0", "a1", "d0", "d1"):
                v = st.get(r)
                if v is None or v[0] not in "AIPD":
                    continue
                mk = self.mem(f"({r})" if r[0] == "a" else "(0, a0)", {"a0": v} if r[0] == "d" else st)
                if mk:
                    self.record(mk[0], mk[1], 0, f"arg {r}", func, cpu, insn, (tgt, consts), mk[2], mk[3])
            if self.callee and not tgt.startswith("("):
                # (callee) the words the caller stored in its outgoing frame: stack arguments
                for k, sv in list(st.items()):
                    if not k.startswith("sp:") or sv[1] != 4 or sv[0] is None or sv[0][0] not in "AIPD":
                        continue
                    c = _num(k[3:])
                    if c is None or not 16 <= c < 0x100:
                        continue
                    mk = self.mem("(0, a0)", {"a0": sv[0]})
                    if mk:
                        self.record(mk[0], mk[1], 0, f"arg sp{c}", func, cpu, insn, (tgt, consts), mk[2], mk[3])
            for r in SCRATCH:
                st[r] = None
                last_load.pop(r, None)
            if self.rets_t and tgt in self.returns:
                st["a0"] = T(self.returns[tgt])
            elif self.ext and tgt in self.returns_p:
                st["a0"] = self.returns_p[tgt]
            elif tgt in self.ret_val:
                st["a0"] = self.ret_val[tgt]
            return
        if op in ("ret", "retf", "rets") and self.rets_t and func:
            func = self._func if not self.ext else func     # (siblings: the function, not the site)
            v = st.get("a0")
            a = addrs_of(v)
            if a is None:
                self._retbad.add(func)        # some path returns something else
            else:
                self._ret[func] |= a
            # a pointer loaded from a typed field (a table entry the arguments select), the same on
            # every path that returns: the caller's a0 is that field's target
            if v != ("C", 0):            # (a NULL return: "not found")
                self._retv[func].add(v if v is not None and v[0] == "P" and v[1][0] == "fld" and v[2] == 0
                                     and not v[3] else None)
            return
        if op == "setlb" and self.ext:
            # the head of a hardware loop (setlb .. Lcc): a register the code set to a constant before
            # it is a loop counter or index here, not that constant
            for r in REGS:
                if st.get(r) is not None and st[r][0] == "C":
                    st[r] = None
            return
        if op in ("movm", "ret", "retf", "rets", "rti"):
            return
        if self.slots and op in ("add", "sub") and args and args[-1] == "sp":
            for k in [k for k in st if k.startswith("sp:")]:
                del st[k]
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
    return Reader(os.path.join(KN7, G.P["src"], "*.s"), labels, G.Gen.in_data, ext=bool(G.P.get("readers_ext")))


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
