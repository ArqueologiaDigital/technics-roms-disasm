#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Carries names from one MN10300 MILK image (A, the KN7000's program 941) to another
# (B, a sibling) along the CALL SITES and RAM OPERANDS of routines both images
# already name the same way.
#
# Question it answers: "which unnamed routines of B, and which of its RAM addresses,
# are the ones A names, judged not by their own code but by where the routines both
# images name use them?"
#
# Why a second porting tool: port_names_by_code.py and fn_similarity.py judge a
# routine by its own body, so they cannot carry a name onto a routine that is too
# short (fewer than 8 unmasked instructions: getters, setters, thunks, the MILK
# library's small leaves) or that has a twin (two identical bodies, as table-driven
# code has).  But such a routine is still pinned down by its CALLERS: when A's Foo
# and B's Foo are the same code, the routine Foo calls at its k-th call site in A is
# the routine B's Foo calls at the aligned call site.  The same holds for the RAM
# operand of the k-th instruction (`mov (0x5004ee84), d0` in B against
# `mov (0x50061234), d0` in A): the two addresses are one variable, relinked.
#
# ANCHORS are the names both A and B give exactly one routine start.  Each anchor's
# two bodies (fn_similarity.Side.tokens: every instruction control flow reaches,
# relocations masked) are aligned:
#   exact     the strict token sequences are equal
#   skeleton  the skeletons are equal (only small immediates differ)
#   aligned   the skeleton similarity ratio is at least --min-ratio (default 0.9);
#             only matching blocks of at least 3 instructions are used
# An aligned call site pairs A's callee ca with B's callee cb (tail jumps to a
# routine start count as calls).  An aligned instruction pair whose numbers are
# RAM addresses on both sides (top byte 0x50, 0x90 or 0x84, the same count of
# masked numbers in the same places) pairs a B RAM address with an A one.
#
# A name of A goes to B's routine cb only when
#   * every aligned call site that has cb as B's callee has the same A callee ca,
#     and every one that has ca has cb (a routine pairs with exactly one routine);
#   * ca has a name in A that B does not use yet, given at ca's start;
#   * the support is at least one exact or skeleton anchor, or two aligned ones;
#   * the two routines' own bodies do not disagree: fn_similarity.compare gives no
#     conflicting named callee or string, and a skeleton similarity of at least
#     --min-body (default 0.6; a short body differs by little).
# Accepted names make new anchors, and so does a pair the rule accepts where A names
# neither routine (the two are one routine, unnamed): its own call sites and RAM
# operands pair the next round's.  The rounds run to a fixed point.
#
# THE AUDIT measures the rule where the answer is known: every B callee that B
# already names and that the rule pairs with a named A callee is counted right when
# the two names agree (case-insensitively, X and X_entry one name) and wrong when
# they differ; the wrong ones are listed in the report.
#
# POINTERS (lane open12/sibling-names2): an aligned instruction pair whose numbers are a
# routine start on both sides (`mov func, d0`, a callback handed to a registration) pairs
# the two routines as a call site does; one whose numbers are data addresses on both sides
# (`mov table, a0`) pairs the two tables, whose 32-bit words pair at equal offsets as long
# as both or neither are code addresses.  A table is used only when at least --table-agree
# of its word pairs are routines both images name alike and none is named unlike (a walk
# that slipped by a row pairs every later word wrongly, and its named words show it); its
# audit leaves each named word out in turn.  Without that test the KN2400's table-word
# pairs were 317 wrong of 1,043 (../notes/sibling-names2/README.md).
#
# RAM: a B address pairs with an A address under the same uniqueness rule.  The
# names of A's RAM addresses (its --a-sym rows outside the image, but not a RAM window's
# base, is_region_base) are carried onto their B partners; every pair, named or not, is
# written to --ram-map, so a RAM name given to the KN7000 later reaches the sibling by a
# re-run.  RUNS (wave 12): a relinked module keeps its variables' order and spacing, so
# the voted pairs come in runs of one delta; between two voted pairs that are neighbours
# in B's order and share the delta, the RAM addresses both codes spell pair by that delta
# (ram_runs; the premise is audited on the voted pairs themselves, ram_runs_audit).  The
# twin pass reads these pairs too.
#
# Usage:
#   port_names_by_alignment.py --a-rom A.rom --a-code LO:HI[:CPU] ... --a-sym A1.sym ...
#       --b-rom B.rom --b-base 0x... --b-code LO:HI[:CPU] ... --b-sym B1.sym ...
#       --b-labels B/src/labels.inc --out B_aligned.sym --ram-map B_ram_map.tsv
#       --report REPORT.md --title "..." [--unidasm PATH] [--cache DIR]
import argparse
import bisect
import collections
import difflib
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_image_s as GI  # noqa: E402
import fn_similarity as FS  # noqa: E402
from port_names_by_code import ranges  # noqa: E402

NUM = re.compile(r"0x[0-9a-fA-F]+|\b\d+\b")
RAM_TOPS = (0x50, 0x90, 0x84)


def is_ram(v):
    return (v >> 24) in RAM_TOPS


def is_region_base(v):
    """0x50000000, 0x90000000, 0x84000000: the base of a RAM window is a memory-map constant,
    not a variable.  Its A name (WORK_RAM_BASE) is not carried: in B's data the same value is a
    bus-window base held as a number (KN6000 func_4C0506C7_entry_L4_Records' +0 field holds
    0x50000000 / 0x58000000 / 0x54000000), and a label there makes gen_data_s.py read that
    field as a pointer (lane mn10300-data3, ../notes/mn10300-data3/README.md section 3)."""
    return is_ram(v) and not v & 0x00FFFFFF


def big_numbers(ops):
    return [int(m.group(0), 0) for m in NUM.finditer(ops) if int(m.group(0), 0) >= 0x10000]


def alignment(ta, tb, min_ratio):
    """(class, {A body index: B body index}) or (None, None)."""
    if ta.strict == tb.strict:
        return "exact", {k: k for k in range(ta.n)}
    if ta.skel == tb.skel:
        return "skeleton", {k: k for k in range(ta.n)}
    sm = difflib.SequenceMatcher(None, ta.skel, tb.skel, autojunk=False)
    if sm.ratio() < min_ratio:
        return None, None
    amap = {}
    for i, j, n in sm.get_matching_blocks():
        if n >= 3:
            for q in range(n):
                amap[i + q] = j + q
    return "aligned", amap


def norm_name(nm):
    return FS.strip_entry(nm).lower() if nm else nm


class Run:
    def __init__(self, a):
        self.a = a
        if a.cache:
            A = FS.cached_image(a.a_rom, a.a_base, ranges(a.a_code, a.a_base), a.unidasm, a.cache)
            B = FS.cached_image(a.b_rom, a.b_base, ranges(a.b_code, a.b_base), a.unidasm, a.cache)
        else:
            A = GI.Image(a.a_rom, a.a_base, ranges(a.a_code, a.a_base), a.unidasm)
            B = GI.Image(a.b_rom, a.b_base, ranges(a.b_code, a.b_base), a.unidasm)
        a_all = GI.load_syms(a.a_sym)
        b_all = GI.load_syms(a.b_sym)
        self.a_ram = {cpu: nm for cpu, nm in a_all.items()
                      if A.off(cpu) is None and is_ram(cpu) and not is_region_base(cpu)}
        self.b_ram = {cpu: nm for cpu, nm in b_all.items() if B.off(cpu) is None and is_ram(cpu)}
        a_names = {cpu: nm for cpu, nm in a_all.items() if not nm.endswith("_entry") and A.off(cpu) is not None}
        b_names = {cpu: nm for cpu, nm in b_all.items() if not nm.endswith("_entry") and B.off(cpu) is not None}
        before = set(GI.load_syms([a.out]).values()) if os.path.exists(a.out) else set()
        b_unnamed = {}
        for nm, v in re.findall(r"^\.equ\s+(\w+),\s*0x([0-9a-fA-F]+)", open(a.b_labels).read(), re.M):
            if re.fullmatch(r"func_[0-9A-F]{8}(_entry)?", nm) or nm in before:
                b_unnamed[int(v, 16)] = nm
        # names an earlier run of this tool wrote count as unnamed again (a rerun is a fixed point)
        b_names = {cpu: nm for cpu, nm in b_names.items() if nm not in before}
        self.A, self.B = A, B
        self.SA = FS.Side(A, a_names, {})
        self.SB = FS.Side(B, b_names, b_unnamed)
        self.b_unnamed = b_unnamed
        self.b_taken = {norm_name(nm) for nm in b_all.values() if nm not in before}
        self.a_cpu_of = collections.defaultdict(list)
        for cpu, nm in a_names.items():
            self.a_cpu_of[nm].append(cpu)
        self.rows = []
        self.ram_votes = collections.defaultdict(collections.Counter)
        self.audit = collections.Counter()
        self.audit_wrong = []
        self.rejected = collections.Counter()

    def a_name(self, off):
        return self.SA.name_at(off)

    def b_open(self, off):
        """Is B's routine start `off` unnamed (a func_ label, no real name)?"""
        cpu = self.B.cpu(off)
        return self.SB.names.get(cpu) is None and cpu in self.b_unnamed

    def anchors(self):
        out = []
        b_cpu_of = collections.defaultdict(list)
        for cpu, nm in self.SB.names.items():
            b_cpu_of[nm].append(cpu)
        for nm, bl in b_cpu_of.items():
            al = self.a_cpu_of.get(nm, [])
            if len(al) == 1 and len(bl) == 1:
                fa, fb = self.A.off(al[0]), self.B.off(bl[0])
                if fa is not None and fb is not None:
                    out.append((nm, fa, fb))
        return out + self.pair_anchors

    def votes(self, anchors, done):
        """Aligned call-site pairs {(cb, ca): [(anchor, class)]} of the anchors not in done."""
        calls = collections.defaultdict(list)
        for nm, fa, fb in anchors:
            if nm in done:
                continue
            done.add(nm)
            ta, tb = self.SA.tokens(fa), self.SB.tokens(fb)
            cls, amap = alignment(ta, tb, self.a.min_ratio)
            if cls is None:
                continue
            cb_at = dict(tb.calls)
            for k, ca in ta.calls:
                j = amap.get(k)
                if j is None or j not in cb_at or ca is None or cb_at[j] is None:
                    continue
                calls[(cb_at[j], ca)].append((nm, cls, "call"))
            ba, bb = self.SA.body(fa), self.SB.body(fb)
            for k, j in amap.items():
                if k >= len(ba) or j >= len(bb):
                    continue
                ia, ib = ba[k], bb[j]
                if ia[2] != ib[2] or GI.target_of(ia[2], ia[3]) is not None:
                    continue
                na, nb = big_numbers(ia[3]), big_numbers(ib[3])
                if len(na) != len(nb):
                    continue
                for va, vb in zip(na, nb):
                    if is_ram(va) and is_ram(vb):
                        self.ram_votes[vb][va] += 1
                    elif self.a.pointers:
                        self.pointer_votes(calls, nm, cls, va, vb)
        return calls

    # ---- routine addresses held as operands, and in the data tables operands point to ---
    def data_off(self, img, v):
        """File offset of CPU address v in img's data (in the image, outside every code range)."""
        o = v - img.base
        if 0 <= o <= len(img.d) - 4 and not img.in_code(o) and img.off(v) is None:
            return o
        return None

    def pointer_votes(self, calls, nm, cls, va, vb):
        """POINTERS: an aligned operand that is a routine start on both sides (`mov
        func, d0`: a callback handed over) pairs the two routines; one that is a data
        address on both sides (`mov table, a0`) pairs the two tables, and the words of
        the tables pair as far as their layouts agree (table_pairs).  Each pair is one
        support of the anchor's class, as a call site is, and goes through the same
        tests; the audit counts these pairs apart (pointers right / wrong)."""
        oa, ob = self.A.off(va), self.B.off(vb)
        if oa is not None and ob is not None:
            sa, sb = self.SA.routine(oa), self.SB.routine(ob)
            if sa in self.SA.starts and sb in self.SB.starts and sa == oa and sb == ob:
                calls[(sb, sa)].append((nm, cls, "pointer"))
            return
        da, db = self.data_off(self.A, va), self.data_off(self.B, vb)
        if da is None or db is None or (db, da) in self.tables_done:
            return
        self.tables_done.add((db, da))
        tp = self.table_pairs(da, db)
        agree = bad = 0
        for sb, sa, _o in tp:
            na, nb = self.a_name(sa), self.SB.name_at(sb)
            if na and nb:
                if norm_name(na) == norm_name(nb):
                    agree += 1
                else:
                    bad += 1
        # a table counts only when the words both images name agree, at least --table-agree
        # of them, and none disagrees: a walk that slipped by a row (an entry one side
        # added) pairs every later word with the wrong routine, which the named ones show
        # the audit, leave one out: would the table pass on its other named words, and is
        # the word left out right?  (the words that let a table pass cannot audit it)
        if not bad and agree - 1 >= self.a.table_agree:
            self.table_stats["audit: named word, table passes without it, right"] += agree
        elif bad == 1 and agree >= self.a.table_agree:
            self.table_stats["audit: named word, table passes without it, wrong"] += 1
        if bad or agree < self.a.table_agree:
            self.table_stats["tables refused (named words disagree, or too few agree)"] += 1
            return
        self.table_stats["tables used"] += 1
        for sb, sa, o in tp:
            calls[(sb, sa)].append((f"{nm} table 0x{vb:08X}+{o}", cls, "table"))

    def table_pairs(self, da, db):
        """[(B start, A start, offset)] of the 32-bit words at the same offsets of two
        paired tables that are routine starts on both sides, up to --table-max bytes;
        the walk stops where one side holds a code address and the other does not (the
        two layouts part), or where either side reaches code."""
        A, B = self.A, self.B
        out = []
        for o in range(0, self.a.table_max, 4):
            if da + o + 4 > len(A.d) or db + o + 4 > len(B.d) or A.in_code(da + o) or B.in_code(db + o):
                break
            wa = int.from_bytes(A.d[da + o:da + o + 4], "little")
            wb = int.from_bytes(B.d[db + o:db + o + 4], "little")
            pa, pb = A.off(wa), B.off(wb)
            if (pa is None) != (pb is None):
                break
            if pa is not None and pa in self.SA.starts and pb in self.SB.starts:
                out.append((pb, pa, o))
        return out

    def round(self, all_calls):
        by_b = collections.defaultdict(set)
        by_a = collections.defaultdict(set)
        for (cb, ca) in all_calls:
            by_b[cb].add(ca)
            by_a[ca].add(cb)
        new = 0
        for (cb, ca), sup in sorted(all_calls.items()):
            if (cb, ca) in self.judged:
                continue
            na = self.a_name(ca)
            nb = self.SB.name_at(cb)
            strong = sum(1 for _n, c, _k in sup if c in ("exact", "skeleton"))
            kinds = {k for _n, _c, k in sup}
            ptr_only = "call" not in kinds
            pkind = "table" if kinds == {"table"} else "pointer"
            decisive = strong >= 1 or len(sup) >= 2
            if na and nb:                                    # the audit: both named already,
                if decisive:                                 # judged by the rule's own support test
                    self.judged.add((cb, ca))
                if decisive and len(by_b[cb]) == 1 and len(by_a[ca]) == 1 and not (ptr_only and pkind == "table"):
                    if norm_name(na) == norm_name(nb):
                        self.audit["right"] += 1
                        if ptr_only:
                            self.audit[f"{pkind} right"] += 1
                    else:
                        self.audit["wrong"] += 1
                        if ptr_only:
                            self.audit[f"{pkind} wrong"] += 1
                        self.audit_wrong.append((nb, self.B.cpu(cb), na, self.A.cpu(ca), len(sup)))
                continue
            if not na:
                # no name to carry, but a pair the rule accepts is the same routine on both
                # sides: it anchors the next round (its own callees and RAM operands)
                if len(by_b[cb]) == 1 and len(by_a[ca]) == 1 and decisive:
                    c = FS.compare(self.SA, ca, self.SB, cb)
                    if not c.conflict and c.sk >= self.a.min_body:
                        self.judged.add((cb, ca))
                        self.pair_anchors.append((f"@0x{self.A.cpu(ca):08X}", ca, cb))
                        self.last_why[(cb, ca)] = "A's callee is unnamed too (the pair anchors the next round)"
                        continue
                self.reject((cb, ca), "A's callee is unnamed too", final=False)
                continue
            if not self.b_open(cb):
                continue
            if len(by_b[cb]) != 1 or len(by_a[ca]) != 1:
                self.reject((cb, ca), "pairs with more than one routine")
                continue
            if norm_name(na) in self.b_taken:
                self.reject((cb, ca), "the name is taken in B")
                continue
            if not decisive:
                self.reject((cb, ca), "one aligned call site only", final=False)
                continue
            c = FS.compare(self.SA, ca, self.SB, cb)
            if c.conflict:
                self.reject((cb, ca), "the bodies' callees or strings disagree")
                continue
            if c.sk < self.a.min_body:
                self.reject((cb, ca), f"body skeleton similarity below {self.a.min_body}")
                continue
            self.judged.add((cb, ca))
            self.rows.append((self.B.cpu(cb), na, self.A.cpu(ca), len(sup), strong,
                              sorted({n for n, _c, _k in sup})[:3], c.sk, c.st, self.n_round))
            if ptr_only:
                self.ptr_rows.add(self.B.cpu(cb))
            self.SB.names[self.B.cpu(cb)] = na
            self.b_taken.add(norm_name(na))
            new += 1
        return new

    def reject(self, key, why, final=True):
        self.last_why[key] = why
        if final:
            self.judged.add(key)

    def run(self, max_rounds=40):
        done = set()
        all_calls = collections.defaultdict(list)
        self.judged = set()
        self.last_why = {}
        self.how = {}
        self.pair_anchors = []
        self.tables_done = set()
        self.table_stats = collections.Counter()
        self.ptr_rows = set()
        for self.n_round in range(1, max_rounds + 1):
            for key, sup in self.votes(self.anchors(), done).items():
                all_calls[key].extend(sup)
            n_pairs = len(self.pair_anchors)
            new = self.round(all_calls)
            tw = self.twin_pass() if self.a.twins else 0
            np_ = len(self.pair_anchors) - n_pairs
            print(f"  round {self.n_round}: {new} names by call site, {tw} by mapped operands, "
                  f"{np_} unnamed pairs", file=sys.stderr)
            if not new and not tw and not np_:
                break
        for why in self.last_why.values():
            self.rejected[why] += 1
        self.all_calls = all_calls
        # a later round's anchors may have given an accepted pair a rival: count those
        by_b = collections.defaultdict(set)
        by_a = collections.defaultdict(set)
        for (cb, ca) in all_calls:
            by_b[cb].add(ca)
            by_a[ca].add(cb)
        self.late_rivals = [x for x in self.rows if x[0] not in self.how and (len(by_b[self.B.off(x[0])]) != 1 or len(by_a[self.A.off(x[2])]) != 1)]

    # ---- twins and short routines, told apart by the variables they use -------------
    def operand_values(self, side, o):
        """The numbers of 0x10000 or more of body o's non-branch instructions, in order."""
        out = []
        for _off, _b, mnem, ops in side.body(o):
            if GI.target_of(mnem, ops) is None:
                out.extend(big_numbers(ops))
        return out

    def operands_agree(self, fa, fb, ram_map):
        """(agreeing RAM operands, disagreeing ones) of two routines with one strict body:
        a B RAM operand agrees when the RAM map pairs it with A's operand in that place."""
        va, vb = self.operand_values(self.SA, fa), self.operand_values(self.SB, fb)
        if len(va) != len(vb):
            return 0, 1
        ok = bad = 0
        for x, y in zip(va, vb):
            if is_ram(x) and is_ram(y):
                m = ram_map.get(y)
                if m is None:
                    continue
                if m == x:
                    ok += 1
                else:
                    bad += 1
        return ok, bad

    def twin_pass(self):
        """Names of A for B routines whose whole body (strict tokens) equals the A routine's
        but which port_names_by_code.py leaves (fewer than 8 unmasked instructions, or a
        twin on either side): carried when the RAM map pairs every mapped RAM operand of
        the two bodies, at least one, and no other routine of either group passes that test
        with them; a short unique pair may pass on agreeing named callees or strings instead
        (fn_similarity.compare), with no RAM operand disagreeing."""
        if not hasattr(self, "groups_a"):
            self.twin_audited = set()
            self.groups_a, self.groups_b = collections.defaultdict(list), collections.defaultdict(list)
            for o in self.SA.starts:
                t = self.SA.tokens(o)
                if t.n:
                    self.groups_a[t.strict].append(o)
            for o in self.SB.starts:
                t = self.SB.tokens(o)
                if t.n:
                    self.groups_b[t.strict].append(o)
        ram_map = {vb: va for vb, va, _n in self.ram_pairs()}
        new = 0
        b_by_name = {norm_name(nm): self.B.off(c) for c, nm in self.SB.names.items()}
        for cpu, nm in sorted(self.SA.names.items()):
            fa = self.A.off(cpu)
            if fa is None or fa not in self.SA.starts:
                continue
            t = self.SA.tokens(fa)
            ga = self.groups_a.get(t.strict, [])
            if norm_name(nm) in self.b_taken:
                # the audit: B names this routine already; would the rule, run over the whole
                # B group, pick it?  (judged once per name, in the first round it can be)
                known = b_by_name.get(norm_name(nm))
                if nm in self.twin_audited or known is None or known not in self.groups_b.get(t.strict, []):
                    continue
                if len(ga) == 1 and len(self.groups_b[t.strict]) == 1 and t.kept >= 8:
                    continue                     # port_names_by_code.py's own case, not this pass's
                picks = [o for o in self.groups_b[t.strict]
                         if self.operands_agree(fa, o, ram_map)[0] and not self.operands_agree(fa, o, ram_map)[1]]
                if len(picks) == 1:
                    self.twin_audited.add(nm)
                    if picks[0] == known:
                        self.audit["twin right"] += 1
                    else:
                        self.audit["twin wrong"] += 1
                        self.audit_wrong.append((self.SB.name_at(picks[0]) or "(unnamed)", self.B.cpu(picks[0]),
                                                 nm, cpu, 0))
                continue
            gb = [o for o in self.groups_b.get(t.strict, []) if self.b_open(o)]
            if not gb:
                continue
            passing = []
            for fb in gb:
                ok, bad = self.operands_agree(fa, fb, ram_map)
                if bad:
                    continue
                if ok:
                    passing.append((fb, f"{ok} RAM operands agree"))
                elif len(ga) == 1 and len(self.groups_b[t.strict]) == 1:
                    c = FS.compare(self.SA, fa, self.SB, fb)
                    if c.agree and not c.conflict:
                        passing.append((fb, f"{c.agree} named callees or strings agree"))
            if len(passing) != 1:
                continue
            fb, why = passing[0]
            # and fb must pass with no other routine of A's group
            rivals = [o for o in ga if o != fa and self.operands_agree(o, fb, ram_map)[0]
                      and not self.operands_agree(o, fb, ram_map)[1]]
            if rivals:
                continue
            bcpu = self.B.cpu(fb)
            kind = "short" if t.kept < 8 else "twin"
            self.how[bcpu] = (f"same body ({t.n} insns, {t.kept} unmasked; {len(ga)} in A, "
                              f"{len(self.groups_b[t.strict])} in B), {why}")
            self.rows.append((bcpu, nm, cpu, 0, 0, [kind], 1.0, 1.0, self.n_round))
            self.SB.names[bcpu] = nm
            self.b_taken.add(norm_name(nm))
            new += 1
        return new

    def ram_refs(self, img):
        """Every RAM address a non-branch instruction of img's decoded code spells."""
        out = set()
        for _o, (_b, mnem, ops) in img.ix.items():
            if GI.target_of(mnem, ops) is None:
                out.update(v for v in big_numbers(ops) if is_ram(v))
        return out

    def ram_pairs(self):
        """ram_voted() and, unless --no-ram-runs, the pairs ram_runs() adds between them."""
        voted = self.ram_voted()
        if not self.a.ram_runs:
            return voted
        return sorted(voted + self.ram_runs(voted))

    def ram_runs(self, voted):
        """RUNS: a module's variables keep their order and spacing when the module is relinked,
        so the voted pairs come in runs of one delta (B address - A address).  Between two
        voted pairs next to each other in B's order that have the same delta d, every RAM
        address vb that B's code spells and no vote gives another A address pairs with
        vb - d, when A's code spells that and no voted pair holds it.  The audit
        (ram_runs_audit) tests the premise on the voted pairs themselves."""
        if not hasattr(self, "_refs"):
            self._refs = (self.ram_refs(self.A), sorted(self.ram_refs(self.B)))
        a_refs, b_refs = self._refs
        vb_set = {vb for vb, _va, _n in voted}
        va_set = {va for _vb, va, _n in voted}
        out = []
        seq = sorted((vb, va) for vb, va, _n in voted)
        for (b1, a1), (b2, a2) in zip(seq, seq[1:]):
            d = b1 - a1
            if b2 - a2 != d or b2 - b1 > self.a.ram_run_gap:
                continue
            i = bisect.bisect_right(b_refs, b1)
            while i < len(b_refs) and b_refs[i] < b2:
                vb = b_refs[i]
                i += 1
                va = vb - d
                if vb in vb_set or va in va_set or va not in a_refs:
                    continue
                if self.ram_votes.get(vb) and set(self.ram_votes[vb]) != {va}:
                    continue
                out.append((vb, va, 0))
        return out

    def ram_runs_audit(self):
        """(right, wrong): each voted pair whose two neighbours in B's order share one delta
        is predicted to have that delta too (the RUNS premise, measured where it is known)."""
        seq = sorted((vb, va) for vb, va, _n in self.ram_voted())
        ok = bad = 0
        for (b0, a0), (b1, a1), (b2, a2) in zip(seq, seq[1:], seq[2:]):
            if b0 - a0 == b2 - a2 and b2 - b0 <= self.a.ram_run_gap:
                if b1 - a1 == b0 - a0:
                    ok += 1
                else:
                    bad += 1
        return ok, bad

    def ram_voted(self):
        """[(b, a, votes)] for B RAM addresses whose votes name one A address
        that no other B address claims."""
        a_claims = collections.Counter()
        best = {}
        for vb, cnt in self.ram_votes.items():
            if len(cnt) == 1:
                va = next(iter(cnt))
                best[vb] = va
                a_claims[va] += 1
        out = []
        for vb, va in sorted(best.items()):
            if a_claims[va] == 1:
                out.append((vb, va, self.ram_votes[vb][va]))
        return out


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--a-rom", required=True)
    ap.add_argument("--a-base", type=lambda v: int(v, 0), default=0x48400000)
    ap.add_argument("--a-code", action="append", required=True)
    ap.add_argument("--a-sym", nargs="+", required=True)
    ap.add_argument("--a-label", default="KN7000 941")
    ap.add_argument("--b-rom", required=True)
    ap.add_argument("--b-base", type=lambda v: int(v, 0), required=True)
    ap.add_argument("--b-code", action="append", required=True)
    ap.add_argument("--b-sym", nargs="+", required=True, help="B's names (never overridden)")
    ap.add_argument("--b-labels", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--ram-map", required=True)
    ap.add_argument("--routine-map", help="write every routine pair the rule accepted (named or not) here")
    ap.add_argument("--report")
    ap.add_argument("--title", required=True)
    ap.add_argument("--min-ratio", type=float, default=0.9)
    ap.add_argument("--min-body", type=float, default=0.6)
    ap.add_argument("--unidasm", default=os.environ.get("UNIDASM", "../../tools/unidasm"))
    ap.add_argument("--cache")
    ap.add_argument("--no-pointers", dest="pointers", action="store_false",
                    help="call sites only: no pairs from routine addresses held as operands or in paired tables")
    ap.add_argument("--table-agree", type=int, default=2,
                    help="how many words of two paired tables both images must name alike, none unlike (default 2)")
    ap.add_argument("--table-max", type=lambda v: int(v, 0), default=0x400,
                    help="how far into two paired data tables table_pairs walks (default 0x400 bytes)")
    ap.add_argument("--no-ram-runs", dest="ram_runs", action="store_false",
                    help="RAM pairs by aligned operands only, not also between two pairs of one delta (ram_runs)")
    ap.add_argument("--ram-run-gap", type=lambda v: int(v, 0), default=0x1000,
                    help="the widest B span between two pairs of one delta that ram_runs fills (default 0x1000)")
    ap.add_argument("--no-twins", dest="twins", action="store_false",
                    help="call sites only: skip the pass over same-body routines told apart by their RAM operands")
    a = ap.parse_args()

    r = Run(a)
    r.run()
    rows = sorted(r.rows)
    pairs = r.ram_pairs()
    ram_rows = [(vb, r.a_ram[va], va, n) for vb, va, n in pairs if va in r.a_ram and vb not in r.b_ram
                and norm_name(r.a_ram[va]) not in r.b_taken]
    ram_audit = collections.Counter()
    for vb, va, _n in pairs:
        if vb in r.b_ram and va in r.a_ram:
            ram_audit["right" if norm_name(r.b_ram[vb]) == norm_name(r.a_ram[va]) else "wrong"] += 1

    with open(a.out, "w") as f:
        f.write(f"; {a.title}\n")
        f.write("; GENERATED by kn7000/tools/port_names_by_alignment.py -- do not edit; its header says\n")
        f.write("; how a name qualifies.  Columns: B address, name, ; the A address it was carried from,\n")
        f.write("; the aligned call sites (of which exact / skeleton anchors), up to three anchors, the\n")
        f.write("; two bodies' skeleton / strict similarity and the round; RAM rows: the aligned operands.\n;\n")
        f.write(f"; {len(rows)} routine names and {len(ram_rows)} RAM names carried from {a.a_label}; "
                f"audit (names both give): {r.audit['right']} right, {r.audit['wrong']} wrong; "
                f"RAM audit {ram_audit['right']} right, {ram_audit['wrong']} wrong\n")
        out = []
        for bcpu, nm, acpu, n, strong, anc, sk, st, rnd in rows:
            if bcpu in r.how:
                out.append((bcpu, f"0x{bcpu:08X}  {nm}\t; = {a.a_label} 0x{acpu:08X}, {r.how[bcpu]}; round {rnd}\n"))
                continue
            out.append((bcpu, f"0x{bcpu:08X}  {nm}\t; = {a.a_label} 0x{acpu:08X}, callee at {n} aligned call "
                              f"sites ({strong} exact/skeleton) of {', '.join(anc)}; body {sk:.2f}/{st:.2f}; "
                              f"round {rnd}\n"))
        for vb, nm, va, n in ram_rows:
            out.append((vb, f"0x{vb:08X}  {nm}\t; RAM = {a.a_label} 0x{va:08X}, {n} aligned operands\n"))
        for _k, line in sorted(out):
            f.write(line)
    with open(a.ram_map, "w") as f:
        f.write(f"# {a.title}: RAM address pairs (port_names_by_alignment.py; B, A, aligned operands, A name)\n")
        f.write("# a B address is listed when every aligned operand gives it one A address that no other\n")
        f.write("# B address takes\n")
        for vb, va, n in pairs:
            f.write(f"0x{vb:08X}\t0x{va:08X}\t{n}\t{r.a_ram.get(va, '')}\n")
    if a.routine_map:
        with open(a.routine_map, "w") as f:
            f.write(f"# {a.title}: routine pairs (port_names_by_alignment.py; B start, A start, B name, A name, how)\n")
            f.write("# anchors (one name on both sides), names carried, and pairs accepted where A names neither;\n")
            f.write("# a '-' name is a func_ placeholder.  A KN7000 name given to an A start later reaches B by a re-run.\n")
            rpairs = {}
            for nm, fa, fb in r.anchors():
                if not nm.startswith("@"):
                    rpairs[fb] = (fa, "same name" if not any(x[0] == r.B.cpu(fb) for x in rows) else "carried")
            for nm, fa, fb in r.pair_anchors:
                rpairs.setdefault(fb, (fa, "call sites, A unnamed"))
            for fb, (fa, how) in sorted(rpairs.items()):
                f.write(f"0x{r.B.cpu(fb):08X}\t0x{r.A.cpu(fa):08X}\t{r.SB.name_at(fb) or '-'}\t"
                        f"{r.SA.name_at(fa) or '-'}\t{how}\n")
    if a.report:
        with open(a.report, "w") as f:
            f.write(f"# {a.title}\n\n")
            f.write(f"- routine names carried: {len(rows)}, {sum(1 for x in rows if x[0] in r.how)} of them by "
                    f"mapped operands (rounds: "
                    f"{', '.join(str(sum(1 for x in rows if x[8] == k)) for k in range(1, r.n_round + 1))})\n")
            f.write(f"- routine pairs both images leave unnamed, accepted by the same rule as anchors: "
                    f"{len(r.pair_anchors)}\n")
            f.write(f"- accepted pairs that a later round gave a rival: {len(r.late_rivals)}\n")
            f.write(f"- audit, callees both images name: {r.audit['right']} right, {r.audit['wrong']} wrong "
                    f"(of them paired by operand pointers alone: {r.audit['pointer right']} right, "
                    f"{r.audit['pointer wrong']} wrong; pairs by table words alone are audited below)\n")
            f.write(f"- paired data tables: {dict(sorted(r.table_stats.items()))}\n")
            f.write(f"- routine names carried on pointer supports alone (an operand or a table word): "
                    f"{len(r.ptr_rows)}\n")
            f.write(f"- audit, same-body routines B names already, picked by mapped operands: "
                    f"{r.audit['twin right']} right, {r.audit['twin wrong']} wrong\n")
            nv = len(r.ram_voted())
            ro, rb = r.ram_runs_audit()
            f.write(f"- RAM address pairs: {len(pairs)}: {nv} by aligned operands (of {len(r.ram_votes)} B addresses seen "
                    f"in them), {len(pairs) - nv} between two of one delta (runs; the premise on the voted pairs: "
                    f"{ro} right, {rb} wrong); named from A: {len(ram_rows)}; RAM audit {ram_audit['right']} right, "
                    f"{ram_audit['wrong']} wrong\n")
            f.write("- not carried (last reason per call-site pair):\n")
            for why, n in r.rejected.most_common():
                f.write(f"  - {n:6d} {why}\n")
            if r.audit_wrong:
                f.write("\nAudit, wrong pairs (B name, B address, A name, A address, call sites):\n\n")
                for nb, bcpu, na, acpu, n in sorted(r.audit_wrong):
                    f.write(f"- `{nb}` 0x{bcpu:08X} / `{na}` 0x{acpu:08X} ({n})\n")
    print(f"port_names_by_alignment: {len(rows)} routine names, {len(ram_rows)} RAM names -> {a.out}; "
          f"audit {r.audit['right']} right / {r.audit['wrong']} wrong; {len(pairs)} RAM pairs -> {a.ram_map}")


if __name__ == "__main__":
    main()
