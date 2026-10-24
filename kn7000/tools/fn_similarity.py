#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Whole-function similarity between two MN10300 MILK images, for carrying names
# from one to the other (port_names_by_code.py --fuzzy, port_sibling_names.py).
#
# Question it answers: "is this unnamed routine of image B the routine image A
# names, although the two builds' copies are not byte-for-byte the same code?"
#
# A routine's BODY is every instruction control flow reaches from its entry
# (branches followed, calls not), up to the next routine start, decoded with MAME
# unidasm (gen_image_s.Image). Each instruction becomes two tokens:
#   strict    mnemonic and operands; a branch/jump inside the body becomes "@k",
#             k = the index of its target instruction in the body (so a size change
#             elsewhere does not move it); a call becomes "C", a jump out of the
#             body "out"; every other number of 0x10000 or more becomes "A"
#             (addresses and MILK message codes, which move between builds);
#             smaller numbers (offsets, masks, counts, frame sizes) are kept.
#   skeleton  the same with the small numbers masked too ("#").
# For each body it also records its CALLEES (the routine each call enters: a call
# to a register-save `X_entry` counts as a call to X) and its STRINGS (an immediate
# that addresses a NUL-terminated printable text of 4+ characters in the image).
#
# compare(A, fa, B, fb) aligns the two skeletons (difflib, no junk heuristic) and
# reports:
#   sk / st     the skeleton / strict similarity ratio, 0..1 (1 = equal sequences)
#   agree       aligned call or string pairs that say the same thing: both callees
#               named and the names equal (X and X_entry are one name), or the two
#               texts equal
#   conflict    aligned pairs that disagree: two named callees with different names,
#               or two different texts
#   kept        instructions with no number masked to "A" (the content that is not
#               relocation)
#
# A shingle index (3-grams of skeleton tokens) finds the few bodies worth a full
# comparison, so neither side is compared with everything.
import bisect
import collections
import difflib
import hashlib
import os
import pickle
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_image_s as GI  # noqa: E402

NUM = re.compile(r"0x[0-9a-fA-F]+|\b\d+\b")
MAX_BODY = 0x4000
SHINGLE = 3
DF_MAX = 400          # a shingle shared by more bodies than this says nothing


def cached_image(rom, base, code, unidasm, cache_dir=None):
    """gen_image_s.Image, with unidasm's decode kept in cache_dir between runs
    (keyed by the image's SHA-1 and its code ranges: a different image or range
    decodes afresh)."""
    if not cache_dir:
        return GI.Image(rom, base, code, unidasm)
    os.makedirs(cache_dir, exist_ok=True)
    raw = open(rom, "rb").read()
    key = hashlib.sha1(raw + repr((base, code)).encode()).hexdigest()[:20]
    path = os.path.join(cache_dir, f"unidasm_{key}.pickle")
    if os.path.exists(path):
        img = GI.Image.__new__(GI.Image)
        img.rom, img.base, img.code, img.unidasm = rom, base, code, unidasm
        img.d = raw
        with open(path, "rb") as f:
            img.ix = pickle.load(f)
        return img
    img = GI.Image(rom, base, code, unidasm)
    with open(path, "wb") as f:
        pickle.dump(img.ix, f)
    return img


def strip_entry(nm):
    return nm[:-6] if nm and nm.endswith("_entry") else nm


Tokens = collections.namedtuple("Tokens", "strict skel calls strings kept n")


class Side:
    """One image, its named routines {cpu: name} and its unnamed entries
    {cpu: placeholder}. Routine starts are those plus every `movm` prologue and
    call target of the linear decode (port_names_by_code.all_entries), except a
    call target that is the register-save entry of a prologue right in front of
    it."""

    def __init__(self, img, names, unnamed, extra_starts=()):
        self.img = img
        self.names = dict(names)            # cpu -> name (routine starts only)
        self.unnamed = dict(unnamed)        # cpu -> func_<ADDR>
        d = img.d
        raw = set(extra_starts)
        for o, (b, mnem, ops) in img.ix.items():
            if mnem == "movm" and b[:1] == b"\xcf":
                raw.add(o)
            elif mnem in ("call", "calls"):
                t = GI.target_of(mnem, ops)
                t = img.off(t) if t is not None else None
                if t is not None:
                    raw.add(t)
        for cpu in list(self.names) + list(self.unnamed):
            o = img.off(cpu)
            if o is not None:
                raw.add(o)
        self.entry_of = {}                  # register-save entry offset -> routine start
        starts = set()
        for o in raw:
            p = GI.prologue_before(d, o)
            if p is not None and p in raw:
                self.entry_of[o] = p
            else:
                starts.add(o)
        self.starts = starts
        self.sorted = sorted(starts)
        self._tok = {}

    # ---- names ----------------------------------------------------------------
    def routine(self, off):
        """The routine start a call to file offset `off` enters."""
        return self.entry_of.get(off, off)

    def name_at(self, off):
        """The real (non-placeholder) name of the routine at file offset off."""
        if off is None:
            return None
        return self.names.get(self.img.cpu(off))

    # ---- bodies ---------------------------------------------------------------
    def body(self, o):
        img = self.img
        i = bisect.bisect_right(self.sorted, o)
        end = self.sorted[i] if i < len(self.sorted) else img.code_end(o)
        end = min(end, img.code_end(o), o + MAX_BODY)
        ins = img.decode(o, end)
        if not ins:
            return []
        reached = img.walk(ins, [o])[0]
        return [x for x in ins if x[0] in reached]

    def text_at(self, v):
        """The printable NUL-terminated text (4+ characters) CPU address v holds in
        the image, else None."""
        o = self.img.off(v)
        if o is None:
            o = v - self.img.base
        d = self.img.d
        if not 0 <= o < len(d):
            return None
        e = d.find(b"\0", o, o + 256)
        if e - o < 4:
            return None
        s = d[o:e]
        if all(0x20 <= c < 0x7F for c in s):
            return s.decode("ascii")
        return None

    def tokens(self, o):
        t = self._tok.get(o)
        if t is not None:
            return t
        img = self.img
        body = self.body(o)
        idx = {x[0]: k for k, x in enumerate(body)}
        strict, skel, calls, strings, kept = [], [], [], [], 0

        def s_norm(m):
            return "A" if int(m.group(0), 0) >= 0x10000 else m.group(0)

        def k_norm(m):
            return "A" if int(m.group(0), 0) >= 0x10000 else "#"
        for k, (off, _b, mnem, ops) in enumerate(body):
            tgt = GI.target_of(mnem, ops)
            if tgt is not None:
                m = re.match(r"0x[0-9a-fA-F]+", ops)
                rest = ops[m.end():]
                to = img.off(tgt)
                if mnem in ("call", "calls"):
                    head = "C"
                    calls.append((k, self.routine(to) if to is not None else None))
                elif to is not None and to in idx:
                    head = f"@{idx[to]}"
                else:
                    head = "out"
                    if mnem in ("jmp", "bra") and to is not None and to in self.starts:
                        calls.append((k, to))            # a tail call
                strict.append(f"{mnem} {head}{NUM.sub(s_norm, rest)}")
                skel.append(f"{mnem} {head}{NUM.sub(k_norm, rest)}")
                kept += 1
                continue
            masked = False
            for m in NUM.finditer(ops):
                v = int(m.group(0), 0)
                if v >= 0x10000:
                    masked = True
                    txt = self.text_at(v)
                    if txt is not None:
                        strings.append((k, txt))
            strict.append(f"{mnem} {NUM.sub(s_norm, ops)}")
            skel.append(f"{mnem} {NUM.sub(k_norm, ops)}")
            kept += not masked
        t = Tokens(tuple(strict), tuple(skel), calls, strings, kept, len(body))
        self._tok[o] = t
        return t

    def shingles(self, o):
        sk = self.tokens(o).skel
        if len(sk) < SHINGLE:
            return {hash(sk)} if sk else set()
        return {hash(sk[i:i + SHINGLE]) for i in range(len(sk) - SHINGLE + 1)}


class Index:
    """Inverted index of skeleton shingles over a set of a Side's routine starts."""

    def __init__(self, side, offs):
        self.side = side
        self.sh = {}
        post = collections.defaultdict(list)
        for o in offs:
            s = side.shingles(o)
            if not s:
                continue
            self.sh[o] = s
            for h in s:
                post[h].append(o)
        self.post = {h: v for h, v in post.items() if len(v) <= DF_MAX}

    def near(self, shingles, top=12, floor=0.25):
        """The `top` indexed starts whose shingle sets are closest (Jaccard) to
        `shingles`, at least `floor`, as [(jaccard, off)]."""
        cnt = collections.Counter()
        for h in shingles:
            for o in self.post.get(h, ()):
                cnt[o] += 1
        out = []
        n = len(shingles)
        for o, c in cnt.items():
            j = c / (n + len(self.sh[o]) - c)
            if j >= floor:
                out.append((j, o))
        out.sort(reverse=True)
        return out[:top]


Cmp = collections.namedtuple("Cmp", "sk st agree conflict")


def compare(A, fa, B, fb):
    ta, tb = A.tokens(fa), B.tokens(fb)
    if not ta.n or not tb.n:
        return Cmp(0.0, 0.0, 0, 0)
    if ta.strict == tb.strict:
        st = sk = 1.0
        amap = {k: k for k in range(ta.n)}
    else:
        sm = difflib.SequenceMatcher(None, ta.skel, tb.skel, autojunk=False)
        sk = sm.ratio()
        amap = {}
        for i, j, n in sm.get_matching_blocks():
            for q in range(n):
                amap[i + q] = j + q
        st = difflib.SequenceMatcher(None, ta.strict, tb.strict, autojunk=False).ratio()
    agree = conflict = 0
    cb = dict(tb.calls)
    for k, ca in ta.calls:
        j = amap.get(k)
        if j is None or j not in cb:
            continue
        na, nb = strip_entry(A.name_at(ca)), strip_entry(B.name_at(cb[j]))
        if na and nb:
            if na == nb:
                agree += 1
            else:
                conflict += 1
    sb = dict(tb.strings)
    for k, txt in ta.strings:
        j = amap.get(k)
        if j is None or j not in sb:
            continue
        if sb[j] == txt:
            agree += 1
        else:
            conflict += 1
    return Cmp(sk, st, agree, conflict)


def score(c):
    return (c.sk + c.st) / 2


# ---- carrying names ----------------------------------------------------------
# A name of A goes to an unnamed entry g of B only when f (the routine A names)
# and g are each other's best match: g is f's best among ALL of B's routine starts
# (named or not), f is g's best among ALL of A's routine starts, both by a clear
# margin, no aligned callee or string disagrees, and the match falls in one of
# these classes (strongest first):
#   exact     the strict token sequences are equal, and no other start on either
#             side has them
#   skeleton  the skeletons are equal (only small immediates differ), no other start
#             on either side has that skeleton, and either a callee or string agrees
#             or the strict similarity is at least 0.9
#   fuzzy     sk >= FUZZY_SK, st >= FUZZY_ST, at least FUZZY_AGREE agreeing callees or
#             strings, at least FUZZY_N instructions, and the margin on both sides
# Every body must have at least MIN_KEPT instructions with nothing masked to "A".
# Accepted names join B's names, so a later round sees them as named callees; the
# rounds run to a fixed point.
MIN_KEPT = 8
MARGIN = 0.05
FUZZY_SK, FUZZY_ST, FUZZY_AGREE, FUZZY_N = 0.90, 0.85, 2, 20

Row = collections.namedtuple("Row", "b_cpu name a_cpu cls n sk st agree conflict margin_b margin_a round")


def _ranked(A, fa, B, cands, a_side):
    """[(score, cmp, off)] of the candidates, best first; a_side: cands are A's."""
    out = []
    for _j, o in cands:
        c = compare(A, o, B, fb=fa) if a_side else compare(A, fa, B, o)
        out.append((score(c), c, o))
    out.sort(key=lambda r: (r[0], r[1].st), reverse=True)
    return out


def judge(A, fa, B, idx_a, idx_b, min_kept=None):
    """f's best match g among B's routine starts, if the pair is each other's best
    and falls in a class: (cls, g, row fields) or (None, g or None, reason)."""
    min_kept = MIN_KEPT if min_kept is None else min_kept
    ta = A.tokens(fa)
    if ta.kept < min_kept:
        return None, None, "too little unmasked content"
    rb = _ranked(A, fa, B, idx_b.near(A.shingles(fa)), False)
    if not rb:
        return None, None, "no candidate in B"
    s1, c, g = rb[0]
    s2 = rb[1][0] if len(rb) > 1 else 0.0
    c2 = rb[1][1] if len(rb) > 1 else None
    if B.tokens(g).kept < min_kept:
        return None, g, "too little unmasked content"
    ra = _ranked(A, g, B, idx_a.near(B.shingles(g)), True)
    if not ra or ra[0][2] != fa:
        return None, g, "not the best match back in A"
    t1 = ra[0][0]
    t2 = ra[1][0] if len(ra) > 1 else 0.0
    d2 = ra[1][1] if len(ra) > 1 else None
    if c.conflict:
        return None, g, "an aligned callee or string disagrees"
    cls = None
    if c.st == 1.0:
        if (c2 is None or c2.st < 1.0) and (d2 is None or d2.st < 1.0):
            cls = "exact"
    elif c.sk == 1.0:
        if (c2 is None or c2.sk < 1.0) and (d2 is None or d2.sk < 1.0) \
                and (c.agree >= 1 or c.st >= 0.9) \
                and s1 - s2 >= MARGIN and t1 - t2 >= MARGIN:
            cls = "skeleton"
    elif c.sk >= FUZZY_SK and c.st >= FUZZY_ST and c.agree >= FUZZY_AGREE \
            and ta.n >= FUZZY_N and s1 - s2 >= MARGIN and t1 - t2 >= MARGIN:
        cls = "fuzzy"
    if cls is None:
        return None, g, "below the class thresholds or ambiguous"
    return cls, g, (ta.n, round(c.sk, 3), round(c.st, 3), c.agree, c.conflict,
                    round(s1 - s2, 3), round(t1 - t2, 3))


def carry(A, B, a_cands, b_cands, taken, log=None, max_rounds=6):
    """Names of A (a_cands: {A file offset: name}) for unnamed entries of B
    (b_cands: set of B file offsets), never a name in `taken`. Returns
    (rows, rejected, differs): rejected = {reason: count}; differs = [(A cpu, A
    name, B cpu, B name, cls)] where A's routine matches, by the same rules, a
    routine B already names otherwise."""
    idx_a = Index(A, A.starts)
    idx_b = Index(B, B.starts)
    rows, rejected = [], collections.Counter()
    open_b = set(b_cands)
    names_seen = collections.Counter(a_cands.values())
    todo = {o: nm for o, nm in a_cands.items() if nm not in taken and names_seen[nm] == 1}
    rejected["name used twice in A"] = sum(1 for nm in a_cands.values() if names_seen[nm] > 1)
    rejected["name already in B"] = sum(1 for nm in a_cands.values() if nm in taken)
    differs = {}
    for rnd in range(1, max_rounds + 1):
        props = {}
        why = collections.Counter()
        for fa, nm in todo.items():
            cls, g, info = judge(A, fa, B, idx_a, idx_b)
            if cls is None:
                why[info] += 1
                continue
            if g not in open_b:
                why["best match in B is named or already carried"] += 1
                bn = B.name_at(g)
                if bn is not None and bn != nm:
                    differs[fa] = (A.img.cpu(fa), nm, B.img.cpu(g), bn, cls)
                continue
            props.setdefault(g, []).append(Row(B.img.cpu(g), nm, A.img.cpu(fa), cls, *info, rnd))
        new = 0
        for g, rs in props.items():
            if len(rs) != 1:
                why["two A names want one B entry"] += len(rs)
                continue
            r = rs[0]
            rows.append(r)
            open_b.discard(g)
            B.names[r.b_cpu] = r.name
            del todo[A.img.off(r.a_cpu)]
            new += 1
        if log:
            log(f"  round {rnd}: {new} carried")
        last_why = why
        if not new:
            break
    rejected.update(last_why)
    return rows, rejected, sorted(differs.values())


def audit(A, B, common):
    """How the rules fare where the answer is known: for each name both images
    give a routine ({A off: B off} in `common`), does judge() pick that routine?
    Returns {cls: [right, wrong]} and the wrong pairs [(name, cls, B cpu picked)]."""
    idx_a = Index(A, A.starts)
    idx_b = Index(B, B.starts)
    tally = collections.defaultdict(lambda: [0, 0])
    wrong = []
    for fa, gb in common.items():
        cls, g, _info = judge(A, fa, B, idx_a, idx_b)
        if cls is None:
            tally["none"][0] += 1
            continue
        tally[cls][0 if g == gb else 1] += 1
        if g != gb:
            wrong.append((A.name_at(fa), cls, B.img.cpu(g)))
    return dict(tally), wrong
