#!/usr/bin/env python3
r"""kernel_a3_merge.py -- the record of how wsa1/kernel/kernel.s became the KN5000 sub-CPU's kernel too.

QUESTION THIS ANSWERS / JOB IT DID (join/split phase A3, register item N-8c52a3ed)
    The owner decided on 2026-11-06: "one kernel source for three CPUs, with conditional blocks
    through most routines".  This tool joined the KN5000 v1.42 sub-CPU's kernel listing
    (v142/subcpu/core/03_task_scheduler_kernel.s, TaskSched_Init .. TaskSched_TerminateTask) into
    kernel/kernel.s, INSTRUCTION BY INSTRUCTION, on the routine pairing that
    notes/open9-a3-probes/kernel_a3_pairing.py measured (26 pairs, same ROM order on both sides):

      * each paired routine is aligned by LCS over unidasm tokens (kernel_structural_match.tok);
      * an aligned instruction pair is written ONCE (kernel.s's line, unchanged) when that line,
        with the KN5000's values for its KERNEL_* equates, assembles to the KN5000's bytes -- or,
        for a branch / label reference, when its target is the KN5000 instruction paired with the
        WSA1 target;
      * every other instruction goes in a per-CPU block:
            .if KERNEL_KN5000      the KN5000 text, its RAM literals spelled with the equates
            .else                  kernel.s's text, unchanged
            .endif
      * routines only the KN5000 has (TaskSched_GetCurrentTaskId, TaskSched_Take_Pending_Count,
        the TaskEvent_* family, TaskSem_GetCount) sit at their ROM position under `.if
        KERNEL_KN5000`; the WSA1's stack faces (*_StackArg) and prom_a's alias labels sit under
        `.if KERNEL_KN5000 == 0`;
      * every KN5000 comment line moves verbatim: a routine header under a banner naming the
        tree it came from, an interior comment in front of the instruction it preceded.

    It is kept as the RECORD OF THE MERGE (like notes/kernel_join_probe.py --emit), not as a build
    step: kernel.s is the source now and a re-run would discard edits made there.  --verify is
    the thing to run after editing: it re-derives what must hold from the pre-merge sources in
    git (BASE) and the current tree.

RUN (from wsa1/, built tree)
    UNIDASM=/home/fsanches/compartilhado/mame-sony-video/unidasm python3 notes/open9-a3-probes/kernel_a3_merge.py --report
    ... --emit      # (done once, 2026-11-06) rewrite kernel/kernel.s, kernel/kernel_kn5000_subcpu.inc,
                    # v142/subcpu/core/03_task_scheduler_kernel.s, scripts/renaming/rename_kernel_a3.sed
    ... --verify    # every KN5000 line of BASE accounted for; see cmd_verify()
"""
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
WSA1 = os.path.dirname(os.path.dirname(HERE))
REPO = os.path.dirname(WSA1)
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.dirname(HERE))
os.environ.setdefault("UNIDASM", "/home/fsanches/compartilhado/mame-sony-video/unidasm")
import kernel_structural_match as K   # noqa: E402
import kernel_a3_pairing as P         # noqa: E402

BASE = "34bc0c5fe"                      # the pre-merge commit both sources are read from
MC = "/home/fsanches/compartilhado/llvm-project/build/bin/llvm-mc"
KN_FILE = "v142/subcpu/core/03_task_scheduler_kernel.s"
KS_FILE = "wsa1/kernel/kernel.s"
KN_LO, KN_HI = 0x01FDDA, 0x02083B      # TaskSched_Init .. Timer_Delay_Ticks (half-open)
KN_DATA = (0x01FEDF, 8)                # TaskSched_Init_ConfigData
C_DATA = (0xF98245, 8)                 # SoftTimer_Request_Boot (prom_c)

# The KN5000 sub-CPU's values for kernel.s's equates (kernel/kernel_kn5000_subcpu.inc).  Each is
# the operand the KN5000 instruction paired with a kernel.s use carries; the merge (and then the
# byte gate) checks every use.
KN_EQU = [
    ("KERNEL_STACK_TOP",           "TaskSched_StackTop", 0x00040B1E),
    ("KERNEL_CURRENT_TASK",        "0x1046", 0x1046),
    ("KERNEL_PENDING_TICKS",       "0x1044", 0x1044),
    ("KERNEL_TCB_BASE",            "0x1048", 0x1048),
    ("KERNEL_TASK_COUNT",          "3", 3),
    ("KERNEL_READY_HEADS",         "0x106C", 0x106C),
    ("KERNEL_READY_LEVELS",        "3", 3),
    ("KERNEL_SEMA_QUEUES",         "0x1082", 0x1082),
    ("KERNEL_SEMA_COUNTS",         "0x1092", 0x1092),
    ("KERNEL_SEMA_COUNT",          "4", 4),
    ("KERNEL_SEMA_COUNT_IMAGE",    "TaskSched_SemaphoreInit", 0x01FDBE),
    ("KERNEL_MSGQ_WAITQ",          "0x1096", 0x1096),
    ("KERNEL_MSGQ_HEADS",          "0x109E", 0x109E),
    ("KERNEL_MSGQ_COUNT",          "2", 2),
    ("KERNEL_NODE_POOL",           "0x10A6", 0x10A6),
    ("KERNEL_NODE_COUNT",          "4", 4),
    ("KERNEL_FREE_LIST",           "0x10C6", 0x10C6),
    ("KERNEL_TIMERS",              "0x10CA", 0x10CA),
    ("KERNEL_TIMER_COUNT",         "1", 1),
    ("KERNEL_BOOT_TIMER_CALLBACK", "TaskSched_NullTimerCallback", 0x01FDC7),
    ("KERNEL_TCB_TEMPLATE",        "TaskSched_TaskDescriptorTable - 12", 0x01FD8C),
    # the KN5000 build only: no kernel.s line used these before
    ("KERNEL_LOCK_DEPTH",          "0x10D2", 0x10D2),
    ("KERNEL_EVENT_QUEUES",        "0x1078", 0x1078),
    ("KERNEL_EVENT_FLAGS",         "0x1080", 0x1080),
    ("KERNEL_EVENT_COUNT",         "2", 2),
    ("KERNEL_EVENT_FLAG_IMAGE",    "TaskSched_EventFlagInit", 0x01FDBC),
    ("KERNEL_PRIORITY_OUT",        "0x0131", 0x0131),
]
KN_VAL = {n: v for n, _, v in KN_EQU}


# ----------------------------------------------------------------- reading ---
def git_bytes(path, rev=BASE):
    return subprocess.run(["git", "-C", REPO, "show", "%s:%s" % (rev, path)],
                          capture_output=True, check=True).stdout


def lines_of(data):
    return data.decode("utf-8").split("\n")


LABEL = re.compile(r'^([A-Za-z_.][A-Za-z0-9_.]*):(.*)$')
KADDR = re.compile(r';\s*([0-9A-F]{6})/([0-9A-F]{6})\s')
DATA_DIR = re.compile(r'^\s+\.(byte|short|long)\b')


def kind(line):
    s = line.strip()
    if not s:
        return "blank"
    if s.startswith(";"):
        return "comment"
    if LABEL.match(line):
        return "label"
    if s.startswith(".if") or s in (".else", ".endif"):
        return "cond"
    if DATA_DIR.match(line):
        return "data"
    if line[0] in " \t":
        return "insn"
    return "other"


def code_of(line):
    """The assembler text, without a trailing comment (no ';' occurs inside these operands)."""
    return line.split(";", 1)[0].rstrip()


def data_bytes(line, val):
    """Bytes a .byte/.short/.long line emits, with names resolved through `val`."""
    m = re.match(r'^\s+\.(byte|short|long)\s+(.*)$', code_of(line))
    size = {"byte": 1, "short": 2, "long": 4}[m.group(1)]
    out = b""
    for e in m.group(2).split(","):
        e = e.strip()
        for n in sorted(val, key=len, reverse=True):
            e = re.sub(r'\b%s\b' % re.escape(n), str(val[n]), e)
        out += (eval(e, {}, {}) & ((1 << (8 * size)) - 1)).to_bytes(size, "little")
    return out


def decode_run(key, lo, hi):
    img = K.image(key)
    o = K.off_of(key, lo)
    return [(a, n, t, img[K.off_of(key, a):K.off_of(key, a) + n])
            for a, n, t in K._unidasm(img[o:o + (hi - lo)], lo) if a + n <= hi]


def decode_skip(key, lo, hi, data):
    dlo, dsz = data
    return decode_run(key, lo, dlo) + decode_run(key, dlo + dsz, hi)


# ------------------------------------------------------------- the elements ---
class El(object):
    """One instruction or data line, with the non-code lines that precede it."""
    def __init__(self, side, idx, line, addr, n, text, raw):
        self.side, self.idx, self.line = side, idx, line
        self.addr, self.n, self.text, self.raw = addr, n, text, raw
        self.tok = K.tok(text) if text is not None else "DATA%d" % n
        self.pre = []               # [(kind, line)] comments / labels / blanks before it
        self.post = []              # trailing non-code lines (only on the last element)

    @property
    def labels(self):
        return [LABEL.match(l).group(1) for k, l in self.pre if k == "label"]


def kn_elements(lines):
    """The KN5000 kernel region of BASE's 03 file as elements, every address PROVEN: the
    instruction lines are assigned the linear decode in order and every label is checked
    against the built ELF."""
    lo_i = next(i for i, l in enumerate(lines) if l.startswith("TaskSched_Init:"))
    hi_i = next(i for i, l in enumerate(lines) if l.startswith("; Busy-wait delay measured in audio ticks."))
    dec = decode_skip("kn5000:payload", KN_LO, KN_HI, KN_DATA)
    img = K.image("kn5000:payload")
    sym = P.elf_symbols()
    out, pre, di, pc = [], [], 0, KN_LO
    for i in range(lo_i, hi_i):
        l = lines[i]
        k = kind(l)
        if k in ("blank", "comment", "label"):
            if k == "label" and sym.get(LABEL.match(l).group(1)) not in (None, pc):
                sys.exit("KN label %s at 0x%X, decode says 0x%X" % (l, sym[LABEL.match(l).group(1)], pc))
            pre.append((k, l))
            continue
        if k == "data":
            b = data_bytes(l, {"TaskSched_NullTimerCallback": sym["TaskSched_NullTimerCallback"]})
            o = K.off_of("kn5000:payload", pc)
            assert img[o:o + len(b)] == b, (hex(pc), l)
            e = El("k", i, l, pc, len(b), None, b)
            pc += len(b)
        elif k == "insn":
            a, n, t, raw = dec[di]
            assert a == pc, (hex(a), hex(pc), l)
            di += 1
            e = El("k", i, l, a, n, t, raw)
            pc += n
        else:
            sys.exit("unexpected KN line %d: %r" % (i + 1, l))
        e.pre, pre = pre, []
        out.append(e)
    assert pc == KN_HI and di == len(dec), (hex(pc), di, len(dec))
    out[-1].post = pre
    return out, lo_i, hi_i


def ks_elements(lines):
    """kernel.s (BASE) as elements, prom_c addresses from each line's own comment."""
    dec = {a: (n, t, r) for a, n, t, r in decode_skip("wsa1:c", 0xF9816B, 0xF989EF, C_DATA)}
    img = K.image("wsa1:c")
    first = next(i for i, l in enumerate(lines) if l.startswith("Kernel_InitRam:"))
    # the pre-lines of Kernel_InitRam reach back to the first banner after the macro include
    endif = next(i for i, l in enumerate(lines) if l.strip() == ".endif")
    start = next(i for i in range(endif, first) if lines[i].startswith("; >>>>>> moved from"))
    out, pre = [], []
    for i in range(start, len(lines)):
        l = lines[i]
        k = kind(l)
        if k in ("blank", "comment", "label", "cond"):
            pre.append((k, l))
            continue
        m = KADDR.search(l)
        assert m, (i + 1, l)
        c = int(m.group(2), 16)
        if k == "data":
            n = {"byte": 1, "short": 2, "long": 4}[DATA_DIR.match(l).group(1)]
            raw = img[K.off_of("wsa1:c", c):K.off_of("wsa1:c", c) + n]
            e = El("w", i, l, c, n, None, raw)
        else:
            n, t, r = dec[c]
            e = El("w", i, l, c, n, t, r)
        e.pre, pre = pre, []
        out.append(e)
    out[-1].post = pre
    return out, start


# ---------------------------------------------------------- shareability ---
_ENC = {}


def assemble(text):
    """Bytes llvm-mc gives one instruction line, or None if it does not assemble."""
    if text not in _ENC:
        r = subprocess.run([MC, "-triple=tlcs900", "-show-encoding"], input=text + "\n",
                           capture_output=True, text=True)
        m = re.findall(r'encoding: \[([^\]]*)\]', r.stdout)
        _ENC[text] = None if r.returncode or len(m) != 1 else \
            bytes(int(x, 16) for x in m[0].split(",") if x.strip())
    return _ENC[text]


IDENT = re.compile(r'(?<![\w.])([A-Za-z_][A-Za-z0-9_.]*)')
REGS = set("""a w c b e d l h ia iw ic ib ie id il ih wa bc de hl ix iy iz sp xwa xbc xde xhl xix
xiy xiz xsp sr f qwa qbc qde qhl qix qiy qiz z nz c nc t f eq ne gt ge lt le ugt uge ult ule ov nov
pl mi""".split())


def subst_kn(code):
    out = code
    for n in sorted(KN_VAL, key=len, reverse=True):
        out = re.sub(r'(?<![\w.])%s(?![\w.])' % n, "0x%X" % KN_VAL[n], out)
    return out


def names_in(code):
    """Identifiers in an instruction's operands that are not registers or conditions."""
    parts = code.strip().split(None, 1)
    if len(parts) < 2:
        return []
    ops = re.sub(r':(opc|io|i3|8|16|24)\b', '', parts[1])
    return [x for x in IDENT.findall(ops) if x.lower() not in REGS]


WLABELS = set()                       # every label kernel.s defines (filled by merge())


def byte_shareable(w, k):
    """kernel.s's line, with the KN5000's equate values, assembles to the KN5000 bytes.
    (Lines naming a label are decided by their target instead: see Merger.share.)"""
    if w.n != k.n or w.tok != k.tok:
        return False
    if w.text is None:
        return data_bytes(w.line, KN_VAL) == k.raw
    names = names_in(code_of(w.line))
    if any(x not in KN_VAL for x in names):
        return False
    return assemble("\t" + subst_kn(code_of(w.line)).strip()) == k.raw


def names_labels(w):
    return [x for x in names_in(code_of(w.line)) if x in WLABELS] if w.text is not None else []


# ---------------------------------------------------------------- grouping ---
def groups(els, starts):
    """Cut an element list at the elements whose pre-labels hold one of `starts` (in order)."""
    pos = []
    for name in starts:
        j = next((i for i, e in enumerate(els) if name in e.labels), None)
        if j is None:
            sys.exit("no element carries label %s" % name)
        pos.append(j)
    assert pos == sorted(pos), starts
    pos.append(len(els))
    return [(starts[k], els[pos[k]:pos[k + 1]]) for k in range(len(starts))]


def wsa1_groups(wel):
    names = [n for n, _, _ in P.wsa1_routines()]
    names.remove("Kernel_Start")             # folded into the SoftTimer_Request_Boot group: the composite
    return groups(wel, names)


def kn_groups(kel):
    names = [o for o, _ in P.ENTRIES[:-1]]
    names[names.index("TaskSched_ConfigAndDispatch")] = "TaskSched_Init_ConfigData"
    return groups(kel, names)


PAIR_OF = dict(P.PAIRS)
del PAIR_OF["Kernel_Start"]
PAIR_OF["SoftTimer_Request_Boot"] = "TaskSched_Init_ConfigData"


def weighted_lcs(wg, kg):
    """Align two routines: a token match scores 1, and 2 when kernel.s's line also gives the
    KN5000 bytes -- so where the KN5000 has an extra copy of a shape (its event-flag init beside
    the semaphore init), the copy that really is the same code wins."""
    na, nb = len(wg), len(kg)
    wt = [[0] * nb for _ in range(na)]
    for i in range(na):
        for j in range(nb):
            if wg[i].tok == kg[j].tok:
                wt[i][j] = 2 if byte_shareable(wg[i], kg[j]) else 1
    dp = [[0] * (nb + 1) for _ in range(na + 1)]
    for i in range(na - 1, -1, -1):
        for j in range(nb - 1, -1, -1):
            best = max(dp[i + 1][j], dp[i][j + 1])
            if wt[i][j]:
                best = max(best, dp[i + 1][j + 1] + wt[i][j])
            dp[i][j] = best
    ops, i, j = [], 0, 0
    while i < na or j < nb:
        if i < na and j < nb and wt[i][j] and dp[i][j] == dp[i + 1][j + 1] + wt[i][j]:
            ops.append((wg[i], kg[j])); i += 1; j += 1
        elif i < na and (j == nb or dp[i][j] == dp[i + 1][j]):
            ops.append((wg[i], None)); i += 1
        else:
            ops.append((None, kg[j])); j += 1
    return ops


def alignment(wel, kel):
    """[(wsa1 group name|None, kn group name|None, [(w El|None, k El|None), ...]), ...] in ROM order."""
    W, N = wsa1_groups(wel), kn_groups(kel)
    out, ni = [], 0
    for wn, wg in W:
        kn = PAIR_OF.get(wn)
        if kn is None:
            out.append((wn, None, [(e, None) for e in wg]))
            continue
        while N[ni][0] != kn:                 # KN-only routines stand where they are
            out.append((None, N[ni][0], [(None, e) for e in N[ni][1]]))
            ni += 1
        out.append((wn, kn, weighted_lcs(wg, N[ni][1])))
        ni += 1
    while ni < len(N):
        out.append((None, N[ni][0], [(None, e) for e in N[ni][1]])); ni += 1
    return out


# --------------------------------------------------------- KN5000 spelling ---
# RAM literal -> the equate expression it is, for the KN5000 lines kept as they were written
KN_RAM = {
    0x1044: "KERNEL_PENDING_TICKS", 0x1046: "KERNEL_CURRENT_TASK", 0x1048: "KERNEL_TCB_BASE",
    0x103C: "KERNEL_TCB_BASE-12", 0x106C: "KERNEL_READY_HEADS", 0x1068: "KERNEL_READY_HEADS-4",
    0x1078: "KERNEL_EVENT_QUEUES", 0x1074: "KERNEL_EVENT_QUEUES-4", 0x1080: "KERNEL_EVENT_FLAGS",
    0x107F: "KERNEL_EVENT_FLAGS-1", 0x1082: "KERNEL_SEMA_QUEUES", 0x107E: "KERNEL_SEMA_QUEUES-4",
    0x1091: "KERNEL_SEMA_COUNTS-1", 0x1096: "KERNEL_MSGQ_WAITQ", 0x109E: "KERNEL_MSGQ_HEADS",
    0x109A: "KERNEL_MSGQ_HEADS-4", 0x10A6: "KERNEL_NODE_POOL", 0x10C6: "KERNEL_FREE_LIST",
    0x10CA: "KERNEL_TIMERS", 0x10C2: "KERNEL_TIMERS-8", 0x10D2: "KERNEL_LOCK_DEPTH",
}
NUM = re.compile(r'(?<![\w.+-])(0x[0-9A-Fa-f]+|\d+)(?![\w.])')


def kn_spell(line, wline=None):
    """The KN5000 line with its kernel RAM literals spelled as equates (the gate checks it)."""
    code, sep, rest = line.partition(";")
    m = re.match(r'^(\s*\S+\s+)(.*?)(\s*)$', code)
    if not m:
        return line
    head, ops, tail = m.groups()
    wexpr = re.findall(r'KERNEL_[A-Z_]+(?:\s*[-+]\s*\d+)?', code_of(wline)) if wline else []

    def rep(mm):
        v = int(mm.group(1), 0)
        for e in wexpr:
            if eval(subst_kn(e)) == v:
                return e.replace(" ", "")
        if v == 0x1092:
            return "KERNEL_MSGQ_WAITQ-4" if head.strip().startswith("add") else "KERNEL_SEMA_COUNTS"
        if v == 0x0131 and "(%s:16)" % mm.group(1) in ops:
            return "KERNEL_PRIORITY_OUT"
        return KN_RAM.get(v, mm.group(1))
    # only operands that are addresses or immediates, never displacements inside (xrr + d)
    pieces = re.split(r'(\([^)]*[+-][^)]*\))', ops)
    ops2 = "".join(pc if pc.startswith("(") and re.search(r'[a-z]\s*[+-]', pc) else NUM.sub(rep, pc)
                   for pc in pieces)
    return head + ops2 + tail + sep + rest


# ------------------------------------------------------------------ merge ---
# a KN5000 comment naming the MAIN CPU's routine of the same old name keeps that name
PROTECT = ["Main-CPU twin: TaskSched_ChangePriority"]
KN_BANNER = "; >>>>>> moved from v142/subcpu/core/03_task_scheduler_kernel.s -- the KN5000 SUB-CPU >>>>>>"
ALIAS = "; <- prom_a's name for this address."
IF_KN, IF_WS, ELSE, ENDIF = ".if KERNEL_KN5000", ".if KERNEL_KN5000 == 0", ".else", ".endif"


def label_items(pre):
    return [(LABEL.match(l).group(1), l) for k, l in pre if k == "label"]


class Merger(object):
    def __init__(self, al):
        self.al = al
        self.rename = {}            # KN5000 old name -> canonical name
        self.wdefs, self.kdefs = {}, {}     # (group index, gap) -> [(name, line text)]
        self.kaddr = {}             # canonical label -> KN5000 address it stands for
        self.why = {}
        self.layout()

    # gap of each element's pre-lines inside a group
    def gaps(self, ops):
        wg, kg = {}, {}
        fw = next((i for i, (w, k) in enumerate(ops) if w), None)
        fk = next((i for i, (w, k) in enumerate(ops) if k), None)
        for i, (w, k) in enumerate(ops):
            if w:
                wg[id(w)] = 0 if i == fw else i
            if k:
                kg[id(k)] = 0 if i == fk else i
        return wg, kg

    def layout(self):
        for gi, (wn, kn, ops) in enumerate(self.al):
            wg, kg = self.gaps(ops)
            wl, kl = {}, {}          # name -> (gap, line)
            alias = set()
            for i, (w, k) in enumerate(ops):
                for e, gmap, d in ((w, wg, wl), (k, kg, kl)):
                    if e:
                        for name, line in label_items(e.pre):
                            d[name] = (gmap[id(e)], line)
                            if ALIAS in line:
                                alias.add(name)
            corr = {}
            if wn and kn:
                corr[kn] = wn
                for i, (w, k) in enumerate(ops):
                    if w and k:
                        wc = [n for n, l in label_items(w.pre) if n not in alias]
                        for n, l in label_items(k.pre):
                            if wc and n not in corr and wc[0] not in corr.values():
                                corr[n] = wc[0]
            self.al[gi] = (wn, kn, ops, wl, kl, alias, corr)
        # branch rule: a paired branch's KN target label corresponds to its WSA1 target label --
        # but only when the two targets are the SAME POINT of the merged routine: the paired
        # instruction, or separated only by instructions the other CPU does not have.  (A KN5000
        # `jr nz` to an extra pending-count bump is not the WSA1 `jr nz` to its exit, even though
        # the two branches pair.)
        where = {}
        for gi, g in enumerate(self.al):
            for x, (w, k) in enumerate(g[2]):
                for e in (w, k):
                    if e:
                        where[id(e)] = (gi, x)
        kel_at = {}
        for g in self.al:
            for w, k in g[2]:
                if k:
                    kel_at[k.addr] = k
        wel_of = {}
        for g in self.al:
            for w, k in g[2]:
                if w:
                    for n in w.labels:
                        wel_of[n] = w
        for wn, kn, ops, wl, kl, alias, corr in self.al:
            for w, k in ops:
                if not (w and k and w.tok == k.tok and w.text is not None):
                    continue
                labs = names_labels(w)
                m = re.findall(r'0x([0-9a-f]+)', k.text)
                if len(labs) != 1 or not m or labs[0] not in wel_of:
                    continue
                kt = kel_at.get(int(m[-1], 16))
                wt = wel_of[labs[0]]
                if kt is None or not label_items(kt.pre):
                    continue
                (gk, xk), (gw, xw) = where[id(kt)], where[id(wt)]
                if gk != gw:
                    continue
                gops = self.al[gk][2]
                lo, hi = min(xk, xw), max(xk, xw)
                same = xk == xw or (xk < xw and all(gops[i][0] is None for i in range(xk, xw))) or \
                    (xw < xk and all(gops[i][1] is None for i in range(xw, xk)))
                if not same:
                    continue
                g = self.al[gk]
                for n, l in label_items(kt.pre):
                    if n not in g[6] and labs[0] not in g[6].values():
                        g[6][n] = labs[0]
        # positions
        for gi, (wn, kn, ops, wl, kl, alias, corr) in enumerate(self.al):
            kpos = {}
            for n, (h, line) in kl.items():
                L = corr.get(n)
                if L is None or L not in wl:
                    self.kdefs.setdefault((gi, h), []).append((n, line))
                    continue
                self.rename[n] = L
                kpos.setdefault(L, []).append(h)
            for L, (g, line) in wl.items():
                if L in alias:
                    self.wdefs.setdefault((gi, g), []).append((L, line))
                    continue
                hs = kpos.get(L)
                if hs is None:
                    if g == 0 and not kn or (g < len(ops) and not ops[g][1] and g != 0):
                        self.wdefs.setdefault((gi, g), []).append((L, line))       # WSA1-only op
                        continue
                    if not kn:
                        self.wdefs.setdefault((gi, g), []).append((L, line))
                        continue
                    hs = [g]
                h = min(hs)
                lo, hi = min(g, h), max(g, h)
                side_ok = (h < g and all(ops[i][0] is None for i in range(h, g))) or \
                          (g < h and all(ops[i][1] is None for i in range(g, h))) or g == h
                if side_ok:
                    self.wdefs.setdefault((gi, lo), []).append((L, line))
                    self.kdefs.setdefault((gi, lo), []).append((L, line))
                    kg_ = lo if g >= h else h
                else:
                    self.wdefs.setdefault((gi, g), []).append((L, line))
                    self.kdefs.setdefault((gi, h), []).append((L, L + ":"))
                    kg_ = h
                nxt = next((ops[i][1] for i in range(kg_, len(ops)) if ops[i][1]), None)
                if nxt is not None:
                    self.kaddr[L] = nxt.addr
        # KN-only labels keep their names; their KN address is their own
        for wn, kn, ops, wl, kl, alias, corr in self.al:
            for i, (w, k) in enumerate(ops):
                if k:
                    for n, l in label_items(k.pre):
                        self.kaddr.setdefault(self.rename.get(n, n), k.addr)

    def share(self, w, k):
        if w.n != k.n or w.tok != k.tok:
            return False, "length" if w.tok == k.tok else "shape"
        labs = names_labels(w)
        if labs:
            m = re.findall(r'0x([0-9a-f]+)', k.text)
            if len(labs) != 1 or not m:
                return False, "label"
            if self.kaddr.get(labs[0]) != int(m[-1], 16):
                return False, "target"
            others = [x for x in names_in(code_of(w.line)) if x not in WLABELS and x not in KN_VAL]
            return (not others), "target"
        ok = byte_shareable(w, k)
        return ok, "bytes" if ok else "bytes differ"

    # ------------------------------------------------------------ emission ---
    def kn_line(self, k, w=None):
        l = kn_spell(k.line, w.line if w else None)
        for o, n in self.rename.items():
            l = re.sub(r'(?<![\w.])%s(?![\w.])' % re.escape(o), n, l)
        return l

    def emit(self):
        out = []
        stats = {}
        for gi, (wn, kn, ops, wl, kl, alias, corr) in enumerate(self.al):
            if wn and not kn:
                out += [IF_WS] + self.side_text(gi, ops, "w") + [ENDIF]
                continue
            if kn and not wn:
                body = self.side_text(gi, ops, "k")
                if any(k.pre and any(x == "comment" for x, _ in k.pre) for _, k in ops[:1]):
                    body = [KN_BANNER] + body
                out += [IF_KN] + body + [ENDIF]
                continue
            shared = [bool(w and k and self.share(w, k)[0]) for w, k in ops]
            for w, k in ops:
                if w and k:
                    r = self.share(w, k)
                    stats[r] = stats.get(r, 0) + 1
            i = 0
            n = len(ops)
            while i <= n:
                if i < n and not shared[i]:
                    j = i
                    while j < n and not shared[j]:
                        j += 1
                    out += self.gap_head(gi, i, ops, block=True)
                    kpart, wpart = [], []
                    for x in range(i, j):
                        w, k = ops[x]
                        if x > i:
                            kpart += self.pre_comments(k, "k", ops, x) + self.labels_at(gi, x, "k")
                            wpart += self.pre_comments(w, "w", ops, x) + self.labels_at(gi, x, "w")
                        else:
                            kpart += self.side_only(gi, x, "k")
                            wpart += self.side_only(gi, x, "w")
                        if k:
                            kpart.append(self.kn_line(k, w))
                        if w:
                            wpart.append(w.line)
                    if kpart and wpart:
                        out += [IF_KN] + kpart + [ELSE] + wpart + [ENDIF]
                    elif kpart:
                        out += [IF_KN] + kpart + [ENDIF]
                    else:
                        out += [IF_WS] + wpart + [ENDIF]
                    i = j
                    continue
                out += self.gap_head(gi, i, ops, block=False)
                if i < n:
                    out.append(ops[i][0].line)
                i += 1
            last = [e for e in (ops[-1][0], ops[-1][1]) if e]
            for e in last:
                out += [l for k_, l in e.post if k_ != "label"]
        return out, stats

    def pre_comments(self, e, side, ops, x):
        if not e:
            return []
        # the KN5000 listing's blank lines are layout only; inside a routine paired with a
        # kernel.s one they would re-space kernel.s's text, so only its comments move
        lines = [l for k_, l in e.pre if k_ in (("comment",) if side == "k" else ("comment", "blank", "cond"))]
        if side == "k":
            lines = [self.rename_text(l) for l in lines]
        return lines

    def rename_text(self, l):
        keep = [p_ for p_ in PROTECT if p_ in l]
        for k_, p_ in enumerate(keep):
            l = l.replace(p_, "\0%d\0" % k_)
        for o, n in self.rename.items():
            l = re.sub(r'(?<![\w.])%s(?![\w.])' % re.escape(o), n, l)
        for k_, p_ in enumerate(keep):
            l = l.replace("\0%d\0" % k_, p_)
        return l

    def record(self, gi):
        """The old KN5000 names of one paired routine, as comment lines."""
        kl = self.al[gi][4]
        items = ["%s = %s" % (o, self.rename[o]) for o in kl if o in self.rename]
        if not items:
            return []
        out, cur = [], "; KN5000 sub-CPU names until 2026-11-06 (it IS this routine: wsa1/notes/open9-a3-probes/):"
        for it in items:
            if len(cur) + len(it) + 2 > 104:
                out.append(cur)
                cur = ";   "
            cur += " " + it + ","
        out.append(cur.rstrip(",") + ".")
        return out

    def labels_at(self, gi, x, side):
        d = self.kdefs if side == "k" else self.wdefs
        return [line if side == "w" else self.rename_text(line) for name, line in d.get((gi, x), [])]

    def side_only(self, gi, x, side):
        both = {n for n, _ in self.wdefs.get((gi, x), [])} & {n for n, _ in self.kdefs.get((gi, x), [])}
        d = self.kdefs if side == "k" else self.wdefs
        return [line if side == "w" else self.rename_text(line) for name, line in d.get((gi, x), [])
                if name not in both]

    def gap_head(self, gi, x, ops, block):
        """Comments and labels at gap x: WSA1 comments, then the KN5000 ones, then the labels."""
        w, k = ops[x] if x < len(ops) else (None, None)
        out = []
        # at gap 0 the first elements of each side carry the routine headers
        if x == 0:
            w = next((a for a, b in ops if a), None)
            k = next((b for a, b in ops if b), None)
        wc = self.pre_comments(w, "w", ops, x) if (w and (x == 0 or ops[x][0] is w)) else []
        kc = self.pre_comments(k, "k", ops, x) if (k and (x == 0 or ops[x][1] is k)) else []
        out += wc
        if x == 0 and self.al[gi][1] and self.al[gi][0]:
            if out and out[-1].strip():
                out.append("")
            out.append(KN_BANNER)
            out += self.record(gi) + kc
        elif kc:
            out += kc
        wd = self.wdefs.get((gi, x), [])
        kd = self.kdefs.get((gi, x), [])
        both = [(n, l) for n, l in wd if n in {m for m, _ in kd}]
        out += [l for n, l in both]
        if not block:
            wo = [l for n, l in wd if (n, l) not in both]
            ko = [self.rename_text(l) for n, l in kd if n not in {m for m, _ in both}]
            if wo:
                out += [IF_WS] + wo + [ENDIF]
            if ko:
                out += [IF_KN] + ko + [ENDIF]
        return out

    def side_text(self, gi, ops, side):
        out = []
        for x, (w, k) in enumerate(ops):
            e = w if side == "w" else k
            if side == "w":
                out += [l for k_, l in e.pre]
                out.append(e.line)
            else:
                out += [self.rename_text(l) for k_, l in e.pre]
                out.append(self.kn_line(e))
        e = ops[-1][0] if side == "w" else ops[-1][1]
        out += [l if side == "w" else self.rename_text(l) for k_, l in e.post]
        return out


def merge():
    kl = lines_of(git_bytes(KN_FILE))
    wl = lines_of(git_bytes(KS_FILE))
    kel, klo, khi = kn_elements(kl)
    wel, wstart = ks_elements(wl)
    WLABELS.update(n for e in wel for n in e.labels)
    al = alignment(wel, kel)
    M = Merger(al)
    body, stats = M.emit()
    return kl, wl, klo, khi, wstart, M, body, stats


# The edits --emit makes to kernel.s's own text beyond the merge: the header's A3 section, two
# notes on claims the third processor qualifies, and ONE instruction respelled natively -- the raw
# `extpfx5` of `ld (XSP+0x0e),0xffff` is `ldw (xsp+14), 0xffff` to the pinned llvm-mc, same bytes
# (bf 0e 02 ff ff), and it was kernel.s's last raw-byte spelling.  --verify allows exactly these.
KS_EDITS = [
    ('insert-after',
     ';     every pair of addresses differs by exactly 0x12B65, first slot to last\n',
     ';\n'
     ";     v142/subcpu/core/03_task_scheduler_kernel.s   the KN5000's SUB-CPU, TMP94C241F\n"
     ';         .include "kernel_kn5000_subcpu.inc"     (-I wsa1/kernel; v141 and v140,\n'
     ';         .include "kernel.s"                     generated from v142, do the same)\n'
     ';                                             ->  0x01FDDA-0x02083A in payload v1.42\n'
     ';\n'
     '; ==============================================================================\n'
     '; ★★ A THIRD PROCESSOR (2026-11-06, join/split phase A3, register item N-8c52a3ed)\n'
     '; ==============================================================================\n'
     '; The owner decided: "one kernel source for three CPUs, with conditional blocks\n'
     '; through most routines."  So the KN5000 sub-CPU payload builds its kernel from\n'
     '; this file too, and all three images rebuild byte for byte from it (`make gate`\n'
     '; for v1.42 / v1.41 / v1.40, `make gate-wsa1` for prom_a / prom_c).\n'
     ';\n'
     ';   HOW IT WAS JOINED, measured (wsa1/notes/open9-a3-probes/, README there):\n'
     ';     kernel_a3_pairing.py   pairs the KN5000 routines with these, routine\n'
     ';         against routine on proven boundaries: 26 pairs, in the SAME ROM ORDER\n'
     ';         on both products, the 10 WSA1 stack faces (*_StackArg) and 7 KN5000\n'
     ';         routines with no partner.\n'
     ';     kernel_a3_merge.py     aligns each pair instruction by instruction and\n'
     ";         writes an instruction ONCE when this file's line, with the KN5000's\n"
     ";         equates (kernel_kn5000_subcpu.inc), gives the KN5000's bytes, or names\n"
     ';         the paired target:\n'
     ';             941 WSA1 slots, 1,137 KN5000 slots;\n'
     ';             801 written once for all three processors;\n'
     ';              30 aligned but spelled per CPU -- 11 a 16-bit direct address\n'
     ";                 where the WSA1's RAM map fits in 8 bits, 15 a different\n"
     ';                 register, count or encoding, 4 a branch to a different place;\n'
     ';             306 KN5000-only and 110 WSA1-only instructions.\n'
     ';   `--report` re-derives every figure above; `--verify` checks that the merge\n'
     ";   only inserted into this file's text and moved every KN5000 comment line.\n"
     ';\n'
     ';   THE SHAPE, and why:\n'
     ';     * ONE SEQUENTIAL BODY, not per-routine files with a per-CPU order list.\n'
     ";       The order was measured first: it is the same on both products (A2's\n"
     ';       "21-long increasing run of 26" came from its approximate match sites),\n'
     ';       so one body emits both, and the KN5000-only routines simply stand at\n'
     ';       their place.  One file also keeps every tool that reads kernel.s by\n'
     ';       path working.\n'
     ';     * `.if KERNEL_KN5000` / `.else` / `.endif` round each run of instructions\n'
     ';       that differs, `.if KERNEL_KN5000 == 0` round what only the WSA1 has\n'
     ";       (its stack faces, prom_a's alias labels).  25 of the 26 paired routines\n"
     ';       have at least one such block; Kernel_ResumeTask has none.  The equates\n'
     ';       still carry every per-CPU VALUE: no shared line spells a RAM address.\n'
     ';     * Why equates alone could not do it (notes/open4-e-probes/\n'
     ';       kernel_a3_shareability.py): the KN5000 keeps its dispatch-inhibit depth\n'
     ';       in a RAM word (KERNEL_LOCK_DEPTH) and mirrors it into control register\n'
     ';       0x7C, where the TMP95C061 uses cr 0x3C alone; its RAM map needs 16-bit\n'
     ';       direct addresses; and it has whole routines the WSA1 lacks -- an\n'
     ';       event-flag family (TaskEvent_*), TaskSched_GetCurrentTaskId,\n'
     ';       TaskSched_Take_Pending_Count, TaskSem_GetCount -- plus a pending-wake\n'
     ';       count in each task control block (+10) that Kernel_ReadyTask and\n'
     ';       Kernel_BlockSelf maintain.\n'
     ";     * The KN5000's text in its blocks is ITS listing, with the kernel RAM\n"
     ';       literals spelled with the equates (4166 -> KERNEL_CURRENT_TASK, ...).\n'
     ';\n'
     ";   NAMES.  Where a KN5000 routine IS one of these, this file's name is now the\n"
     ';   one label in all three builds (62 KN5000 labels renamed:\n'
     ';   scripts/renaming/rename_kernel_a3.sed); each paired routine lists its old\n'
     ';   KN5000 names under its KN5000 banner.  The KN5000-only routines keep theirs.\n'
     ';\n'
     ';   COMMENTS.  The KN5000 headers moved here under the banner\n'
     ';     ; >>>>>> moved from v142/subcpu/core/03_task_scheduler_kernel.s -- the KN5000 SUB-CPU >>>>>>\n'
     ';   after the WSA1 headers of the same routine; the KN5000 interior comments\n'
     ';   stand before the instruction they preceded.  ⚠ ADDRESSES IN THOSE COMMENTS\n'
     ';   ARE v1.42 PAYLOAD ADDRESSES (0x01FDDA ...); the per-line `; AAAAAA/CCCCCC`\n'
     ';   columns are prom_a/prom_c, and the KN5000 lines carry none (repo policy).\n'
     ';\n'
     ";   Not in this file: the KN5000 MAIN CPU's separate build of the same kernel\n"
     ';   (FINDINGS-kernel-in-the-kn5000.md sec 7, v10/v9/v7 around 0xEF1977); joining\n'
     ';   it would be a fourth processor and a fourth .inc (a follow-up, see the A3\n'
     ';   README).\n'),
    ('insert-after',
     '; Technics SX-WSA1R -- THE MULTITASKING KERNEL, ONE SOURCE FOR BOTH PROCESSORS\n',
     ';   (and, since 2026-11-06, for the KN5000\'s sub-CPU as well: "A THIRD PROCESSOR")\n'),
    ('insert-after',
     ';   site; equates name each difference once and leave the body genuinely shared.\n',
     ';   ⚠ TRUE FOR THE TWO WSA1 CPUs, AND STILL TRUE BETWEEN THEM -- but since\n'
     ";   2026-11-06 this file is also the KN5000 sub-CPU's kernel, and between the\n"
     ';   WSA1 and the KN5000 there ARE `.if KERNEL_KN5000` blocks: see "A THIRD\n'
     ';   PROCESSOR" below for why equates alone could not carry it.\n'),
    ('replace',
     '\textpfx5 0xBF, 0x0E, 0x02, 0xFF, 0xFF         ; F85C3D/F987A2',
     '\tldw\t(xsp+14), 0xffff                     ; F85C3D/F987A2'),
]


def apply_edits(text):
    for how, anchor, add in KS_EDITS:
        assert text.count(anchor) == 1, anchor[:60]
        text = text.replace(anchor, anchor + add if how == "insert-after" else add)
    return text


# ★ LATER EDITS to kernel.s's own lines, made after this merge by other lanes (dated).  --verify's
#   "the merge only inserts" check applies them to BASE after KS_EDITS, exactly as written; anything
#   else that rewrites a BASE line still fails it.  (date, lane, how, anchor, new) as in KS_EDITS.
#   (BASE is the WSA1-only kernel.s of 34bc0c5fe: an edit to a KN5000 line the merge inserted is not
#   one of these -- checks 3 and 4 see those, through the KN5000 view.)
# lane open10/kernel4 (L-kernel-a3-softtimer-boot-header): prom_a's SoftTimer_Request_Boot header now
# reads +2 off the shared callee, as prom_c's and the KN5000's do.
LATER_EDITS = [
    ("2026-11-06", "open10/kernel4", "replace",
     '; Layout:  the fields are read off the CALLEE, so only two of the three are\n;          established:\n',
     '; Layout:  the fields are read off the CALLEE -- SoftTimer_Register, one text in\n;          this file for both WSA1 CPUs -- and all three are read there:\n'),
    ("2026-11-06", "open10/kernel4", "replace",
     ';            +2  LE16  0x0001  ⚠ NOT established.  Do not assume it is the\n;                              reload value: the software-timer SLOT layout is\n;                              (+0 countdown, +2 reload, +4 callback), and this\n;                              block is a REQUEST with a different +0, so the\n;                              two layouts must not be conflated.\n',
     ";            +2  LE16  0x0001  the PERIOD in ticks: SoftTimer_Register copies it\n;                              into BOTH slot+0 (the countdown) and slot+2 (the\n;                              reload) -- `ld WA,(XIX+0x02)`, `ld (XIY+0x00),WA`,\n;                              `ld (XIY+0x02),WA` -- as prom_c's and the KN5000's\n;                              headers below read it.  The request and the slot\n;                              still differ at +0: slot number here, countdown\n;                              there.  (Until 2026-11-06 this line left +2 open;\n;                              lane open10/kernel4 read it off the shared callee.)\n"),
    ("2026-11-06", "open10/kernel4", "replace",
     'copied into BOTH slot+0 and slot+2   ⚠ role not established\n',
     'copied into BOTH slot+0 and slot+2   the period: countdown and reload\n'),
]


def apply_later_edits(text):
    for _, _, how, anchor, add in LATER_EDITS:
        assert text.count(anchor) == 1, anchor[:60]
        text = text.replace(anchor, anchor + add if how == "insert-after" else add)
    return text


KN_INCLUDE = [
    "; ============================================================================",
    "; The multitasking kernel: Kernel_InitRam .. Kernel_KillTask, 0x01FDDA-0x02083A in v1.42",
    "; ============================================================================",
    "; ONE SOURCE FOR THREE PROCESSORS since 2026-11-06 (owner decision, register item N-8c52a3ed):",
    "; this payload builds its kernel from the SX-WSA1R's wsa1/kernel/kernel.s, the file both WSA1",
    "; CPUs build theirs from.  kernel_kn5000_subcpu.inc is this processor's RAM map for it and sets",
    "; KERNEL_KN5000, which selects the per-CPU blocks; the text that stood here moved there, its",
    "; headers under a banner naming this file, and each renamed routine records its old name",
    "; (scripts/renaming/rename_kernel_a3.sed lists them all: TaskSched_Init is Kernel_InitRam, ...).",
    "; The pairing and the merge are",
    "; wsa1/notes/open9-a3-probes/kernel_a3_pairing.py and kernel_a3_merge.py (README beside them).",
    "; The data the kernel reads (the three tables above) and the routines outside its extent",
    "; (Task_DequeueDispatch_Prio3, INTT3_TaskSwitch_Handler above; Timer_Delay_Ticks, Timer3_Start /",
    "; Timer3_Stop and TaskSched_Lock / TaskSched_Unlock below) stay in this file: the WSA1 kernel's",
    "; extent ends at Kernel_KillTask on both of its CPUs, and none of these has a WSA1 partner.",
    "\t.include \"kernel_kn5000_subcpu.inc\"",
    "\t.include \"kernel.s\"",
    "",
]


def cmd_emit():
    kl, wl, klo, khi, wstart, M, body, stats = merge()
    ks = wl[:wstart] + body
    open(os.path.join(REPO, KS_FILE), "w").write(apply_edits("\n".join(ks).rstrip("\n") + "\n"))
    kn = [M.rename_text(l) for l in kl[:klo]] + KN_INCLUDE + [M.rename_text(l) for l in kl[khi:]]
    open(os.path.join(REPO, KN_FILE), "w").write("\n".join(kn))
    with open(os.path.join(REPO, "scripts/renaming/rename_kernel_a3.sed"), "w") as f:
        f.write("# rename_kernel_a3.sed -- KN5000 sub-CPU kernel labels -> the canonical names of wsa1/kernel/kernel.s\n")
        f.write("# Generated by wsa1/notes/open9-a3-probes/kernel_a3_merge.py --emit (lane open9/kernel-a3, 2026-11-06).\n")
        f.write("# Each KN5000 routine on the left IS the kernel.s routine on the right (kernel_a3_pairing.py); apply it\n")
        f.write("# to the KN5000 SUB-CPU trees only -- the main CPU's own kernel build (v10/v9/v7) has its own names.\n")
        for o, n in sorted(M.rename.items(), key=lambda t: -len(t[0])):
            f.write("s/\\<%s\\>/%s/g\n" % (o, n))
    print("wrote", KS_FILE, KN_FILE, "and the sed;", stats)


def view(kn5000):
    sys.path.insert(0, os.path.join(WSA1, "notes"))
    from asm_source import cpu_view
    return cpu_view(open(os.path.join(REPO, KS_FILE), encoding="utf-8").read().split("\n"), kn5000)


def is_record(l):
    return l == KN_BANNER or l.startswith("; KN5000 sub-CPU names until 2026-11-06") or \
        (l.startswith(";    ") and " = " in l and re.match(r'^;    [A-Za-z_]+ = ', l) is not None)


def kn_origin_lines():
    """Every comment line the merge moved from the KN5000 file, as it now reads (renamed),
    plus the banner and name-record lines the merge wrote: what kernel_join_probe.py --verify
    accepts as the KN5000 origin of a comment in kernel.s."""
    kl, wl, klo, khi, wstart, M, body, stats = merge()
    out = {M.rename_text(l).rstrip() for l in kl[klo:khi] if l.strip().startswith(";")}
    out |= {l.rstrip() for l in body if is_record(l)}
    return out


def subseq(needles, hay):
    """Index of the first needle NOT found in order in hay, or None."""
    j = 0
    for i, n in enumerate(needles):
        while j < len(hay) and hay[j] != n:
            j += 1
        if j == len(hay):
            return i
        j += 1
    return None


def cmd_verify():
    ok = fail = 0

    def check(desc, cond, extra=""):
        nonlocal ok, fail
        print(("  ok   " if cond else "  FAIL ") + desc + (("   " + extra) if extra else ""))
        ok, fail = ok + bool(cond), fail + (not cond)

    kl, wl, klo, khi, wstart, M, body, stats = merge()
    new = open(os.path.join(REPO, KS_FILE), encoding="utf-8").read().split("\n")
    # 1. kernel.s's own text: every BASE line is still there, in order -- the merge only INSERTED
    wl = apply_later_edits(apply_edits("\n".join(wl))).split("\n")   # BASE + KS_EDITS + LATER_EDITS, nothing else
    miss = subseq([l.rstrip() for l in wl], [l.rstrip() for l in new])
    check("every one of BASE kernel.s's %d lines (with the %d KS_EDITS and %d LATER_EDITS) is in kernel.s, in order"
          " -- the merge only inserts" % (len(wl), len(KS_EDITS), len(LATER_EDITS)), miss is None,
          "" if miss is None else "first missing BASE line %d: %r" % (miss + 1, wl[miss][:70]))
    # 2. the WSA1 view: what prom_a/prom_c assemble is BASE's text plus comments
    wv = [l for l in view(False) if l.strip() and not l.strip().startswith(";")]
    wb = [l for l in wl if l.strip() and not l.strip().startswith(";")]
    check("the WSA1 view's non-comment lines are exactly BASE kernel.s's (%d)" % len(wb), wv == wb,
          "%d vs %d" % (len(wv), len(wb)))
    # 3. every KN5000 comment line of BASE moved, verbatim but for the renames, in order
    kv = [l.rstrip() for l in view(True)]
    kc = [M.rename_text(l).rstrip() for l in kl[klo:khi] if l.strip().startswith(";")]
    miss = subseq(kc, kv)
    check("all %d KN5000 comment lines of BASE's kernel region are in the KN5000 view, in order"
          % len(kc), miss is None, "" if miss is None else "first missing: %r" % kc[miss][:70])
    # 4. the KN5000 view holds exactly as many instruction/data lines as BASE's region had
    kel, _, _ = kn_elements(kl)
    lo = next(i for i, l in enumerate(kv) if l.startswith("Kernel_InitRam:"))
    n = sum(1 for l in kv[lo:] if kind(l) in ("insn", "data"))
    check("the KN5000 view has %d instruction/data lines from Kernel_InitRam on, as BASE had" % len(kel),
          n == len(kel), "%d" % n)
    # 5. every KN5000 label of BASE is defined in the KN5000 view, by its canonical name
    defined = {LABEL.match(l).group(1) for l in kv if LABEL.match(l)}
    old = [LABEL.match(l).group(1) for l in kl[klo:khi] if LABEL.match(l)]
    lost = [o for o in old if M.rename.get(o, o) not in defined]
    check("all %d KN5000 labels of the region are defined (%d renamed, %d kept)"
          % (len(old), sum(1 for o in old if o in M.rename), sum(1 for o in old if o not in M.rename)),
          not lost, str(lost[:5]))
    # 6. no KN5000 old name survives anywhere in the sub-CPU trees' code (a comment may quote one)
    stale = []
    for tree in ("v142/subcpu", "v141/subcpu", "v140/subcpu"):
        for dp, dn, fn in os.walk(os.path.join(REPO, tree)):
            for f in fn:
                if f.endswith(".s"):
                    for ln in open(os.path.join(dp, f), "rb").read().decode("latin-1").split("\n"):
                        code = ln.split(";", 1)[0]
                        stale += [o for o in M.rename if re.search(r'(?<![\w.])%s(?![\w.])' % o, code)]
    check("no renamed KN5000 name is used in v142/v141/v140 code", not stale, str(sorted(set(stale))[:5]))
    # 7. the generated payload trees reach the same source
    for v in ("v142", "v141", "v140"):
        t = open(os.path.join(REPO, v, "subcpu/core/03_task_scheduler_kernel.s"), encoding="utf-8").read()
        check("%s's 03_task_scheduler_kernel.s includes kernel_kn5000_subcpu.inc and kernel.s, and holds no copy" % v,
              '.include "kernel.s"' in t and '.include "kernel_kn5000_subcpu.inc"' in t and "Kernel_Dispatch:" not in t)
    mk = open(os.path.join(REPO, "Makefile")).read()
    for v in ("v142", "v141", "v140"):
        rule = [l for l in mk.split("\n") if l.startswith("rebuilt_ROMs/kn5000_subprogram_%s.llvm.o:" % v)]
        check("Makefile: the %s object depends on the shared kernel source" % v,
              bool(rule) and "SUBCPU_KERNEL_SRC" in rule[0])
    print("%d checks, %d failures" % (ok + fail, fail))
    return 1 if fail else 0


def cmd_report():
    kl, wl, klo, khi, wstart, M, body, stats = merge()
    kv, wv = view(True), view(False)
    sh = sum(n for (okk, _), n in stats.items() if okk)
    nsh = sum(n for (okk, _), n in stats.items() if not okk)
    al = M.al
    kn_only = sum(1 for g in al for w, k in g[2] if k and not w)
    ws_only = sum(1 for g in al for w, k in g[2] if w and not k)
    print("routines: %d paired, %d KN5000-only, %d WSA1-only" % (
        sum(1 for g in al if g[0] and g[1]), sum(1 for g in al if g[1] and not g[0]),
        sum(1 for g in al if g[0] and not g[1])))
    print("instruction/data slots: WSA1 %d, KN5000 %d" % (
        sum(1 for g in al for w, k in g[2] if w), sum(1 for g in al for w, k in g[2] if k)))
    print("  written once, for all three CPUs: %d (%s)" % (sh, ", ".join(
        "%s %d" % (why, n) for (okk, why), n in sorted(stats.items(), key=lambda t: -t[1]) if okk)))
    print("  aligned but per-CPU: %d (%s)" % (nsh, ", ".join(
        "%s %d" % (why, n) for (okk, why), n in sorted(stats.items(), key=lambda t: -t[1]) if not okk)))
    print("  KN5000 only: %d    WSA1 only: %d" % (kn_only, ws_only))
    txt = open(os.path.join(REPO, KS_FILE), encoding="utf-8").read().split("\n")
    print("conditional blocks in kernel.s: %d `.if KERNEL_KN5000` (%d with `.else`), %d `.if KERNEL_KN5000 == 0`" % (
        sum(1 for l in txt if l.strip() == IF_KN), sum(1 for l in txt if l.strip() == ELSE),
        sum(1 for l in txt if l.strip() == IF_WS)))
    print("paired routines with at least one per-CPU block: %d of %d" % (
        sum(1 for g in al if g[0] and g[1] and any(not (w and k and M.share(w, k)[0]) for w, k in g[2])),
        sum(1 for g in al if g[0] and g[1])))
    print("KN5000 labels renamed to kernel.s's: %d" % len(M.rename))


if __name__ == "__main__":
    if "--emit" in sys.argv:
        cmd_emit()
    elif "--verify" in sys.argv:
        sys.exit(cmd_verify())
    else:
        cmd_report()
