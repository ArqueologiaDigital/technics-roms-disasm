"""Rule U1: the register allocator of cc900 V4.23 counted loops (research-scratch
sessions/2026-11-09_cc900-counted-loops, README "The allocation rule (U1)", engine `fit.py`).

One greedy allocator for -O3 -XS -Xr, -O3 -XS and plain -Xr.  The caller precolours what is fixed (the register
parameters a loop mentions, the returned variable in HL / XHL / L, a byte temporary and the parameter it evicts),
then hands over the loop's objects, each in a CLASS.  The classes are visited in a fixed order and each object
takes the first free register of WA, BC, DE, HL, IX, IY, IZ at its width (a 32-bit one needs its Q half free too),
then a Q half (QWA, QBC, ...) for a 16-bit object; a byte object takes the first free byte of A, W, C, B, E, D, L, H.

  walk     the walking pointer and its end pointer of a constant-trip loop
  inv      a hoisted invariant (ol_inv's a * b)
  iv       a derived induction variable (oc_down2's n - 1), a bound loaded from a global (ld WA,(_gn))
  temp1    the first temporary: the byte temporary's pointer temporary, else the first of const > value > addr >
           chain (the caller names it)
  const    a temporary holding a constant (ld XBC,0x0 for a long store)
  value    a loaded or computed value (ol_i_copy: ld BC,(XHL+DE))
  addr     a CSE'd element address (ol_i_acc2: lda XBC,XHL+DE)
  off      offset induction variables (ld O,0 / inc 0x2,O), in order of first use
  base     hoisted global bases (lda XB,_g), in order of first use
  cparam   cdecl parameters kept in a register; pointers reloaded and used directly as a base
  chain    index-chain registers (ld T,i / exts XT / add XT,XT / add XT,Xp)
  reload   a cdecl pointer reloaded as a chain's operand
  acc      locals other than the counters and the returned variable
  ctr      the loop counters
  held     the copy of an address held while a second access is evaluated (oc_add2: ld XIY,XHL)

Within cparam, acc and ctr the order is reverse declaration (for nested loops the inner counter first); a
`return s0 + s1` accumulator (s0; s1 of three terms) takes HL / L at its class's turn when HL is still free.
"""

WORDS = ('WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ')
QWORDS = ('QWA', 'QBC', 'QDE', 'QHL', 'QIX', 'QIY', 'QIZ')
HALVES = {'WA': ('A', 'W'), 'BC': ('C', 'B'), 'DE': ('E', 'D'), 'HL': ('L', 'H')}
BYTEFAM = {b: f for f, hs in HALVES.items() for b in hs}
BYTES = ('A', 'W', 'C', 'B', 'E', 'D', 'L', 'H')
ORDER = ('walk', 'inv', 'iv', 'temp1', 'const', 'value', 'addr', 'off', 'base', 'cparam', 'chain', 'reload', 'acc',
         'ctr', 'held')
REVERSE = ('acc', 'ctr', 'cparam')
RESULT = {8: 'L', 16: 'HL', 32: 'XHL'}


class Fail(Exception):
    pass


class Obj:
    """one object to allocate: `what` is the caller's handle (a declaration, a pseudo, a string), `cls` one of
    ORDER, `w` 8 / 16 / 32, `key` its position in the class (declaration or first-use order), `pref` the
    returned-sum preference for HL / L"""

    def __init__(self, what, cls, w, key=0, pref=False):
        self.what, self.cls, self.w, self.key, self.pref = what, cls, w, key, pref
        self.reg = None

    def __repr__(self):
        return 'Obj(%r, %s, %d, %r)' % (getattr(self.what, 'name', self.what), self.cls, self.w, self.reg)


class RegFile:
    """busy slots: byte halves A, W, C, B, ..., the index words IX, IY, IZ, and the Q halves QWA, QBC, ..."""

    def __init__(self):
        self.busy = set()

    @staticmethod
    def slots(f):
        return list(HALVES[f]) if f in HALVES else [f]

    def free_word(self, f):
        return not any(s in self.busy for s in self.slots(f))

    def fits(self, reg):
        """is register `reg` (any width, fit.py's notation) entirely free?"""
        if reg in BYTEFAM or reg.startswith('Q'):
            return reg not in self.busy
        if reg.startswith('X'):
            return self.free_word(reg[1:]) and 'Q' + reg[1:] not in self.busy
        return self.free_word(reg)

    def take(self, reg, on=True):
        op = self.busy.add if on else self.busy.discard
        if reg in BYTEFAM or reg.startswith('Q'):
            op(reg)
        elif reg.startswith('X'):
            for s in self.slots(reg[1:]) + ['Q' + reg[1:]]:
                op(s)
        else:
            for s in self.slots(reg):
                op(s)

    def first(self, w, order=WORDS):
        if w == 8:
            return next((b for b in BYTES if b not in self.busy), None)
        for f in order:
            if self.free_word(f) and (w < 32 or 'Q' + f not in self.busy):
                return ('X' + f) if w == 32 else f
        if w == 16:
            return next((q for q in QWORDS if q not in self.busy), None)
        return None


def regname(fam, w):
    """the register of family `fam` (WA, ..., IZ) at width w, in fit.py's notation"""
    if w == 8:
        return HALVES[fam][0]
    return ('X' + fam) if w == 32 else fam


def family(reg):
    """fit.py's register name -> the model's register family (d.reg): XHL -> HL, L -> HL, QBC -> QBC"""
    if reg in BYTEFAM:
        return BYTEFAM[reg]
    if reg.startswith('X'):
        return reg[1:]
    return reg


def allocate(objs, rf):
    """visit `objs` in U1's class order and give each the first free register of `rf` (a RegFile holding the
    precoloured registers); sets obj.reg (fit.py's notation) and returns objs.  Raises Fail when out of
    registers."""
    rank = {c: k for k, c in enumerate(ORDER)}

    def key(o):
        return (rank[o.cls], -o.key if o.cls in REVERSE else o.key)

    todo = sorted(objs, key=key)
    seen = set()
    k = 0
    while k < len(todo):
        o = todo[k]
        if o.cls not in seen:                    # a preferring accumulator goes first in its class, if HL is free
            seen.add(o.cls)
            p = next((x for x in todo[k:] if x.cls == o.cls and x.pref), None)
            if p is not None and rf.fits(RESULT[p.w]):
                todo.remove(p)
                todo.insert(k, p)
                p.reg = RESULT[p.w]
                rf.take(p.reg)
                k += 1
                continue
        k += 1
        reg = rf.first(o.w)
        if reg is None:
            raise Fail('out of registers')
        o.reg = reg
        rf.take(reg)
    return objs


def byte_temp(rf, live, reloc=('DE', 'HL', 'IX')):
    """-Xr: the byte temporary is C; a parameter in BC moves to the first free of `reloc` (oc_cpy_abn:
    ld XHL,XBC).  `live` maps a handle to its register (fit.py notation) and is updated; returns
    (byte register, [(handle, old, new)])."""
    owner = next((h for h, r in live.items() if family(r) == 'BC'), None)
    if owner is None:
        if 'C' in rf.busy:
            raise Fail('byte temporary')
        rf.take('C')
        return 'C', []
    old = live[owner]
    w = 32 if old.startswith('X') else 16
    dest = next((regname(f, w) for f in reloc if rf.fits(regname(f, w))), None)
    if dest is None:
        raise Fail('byte temporary relocation')
    rf.take(old, False)
    rf.take(dest)
    live[owner] = dest
    rf.take('C')
    return 'C', [(owner, old, dest)]
