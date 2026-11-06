#!/usr/bin/env python3
r"""kernel_a3_pairing.py -- which KN5000 sub-CPU routine IS which kernel.s routine, on proven boundaries?

QUESTION THIS ANSWERS (join/split phase A3, register item N-8c52a3ed)
    Before the KN5000 sub-CPU payload can build from wsa1/kernel/kernel.s, each KN5000 kernel
    routine must be paired with the kernel.s routine it is (or with none).  A2's match SITES
    (FINDINGS-kernel-in-the-kn5000.md sec 3) were approximate: they came from length-matched
    windows, so several routines landed on one site (0x02044F for both MsgQueue_Send and
    Kernel_SemaWait, 0x02072A for both SoftTimer_Register and Kernel_SetTaskLevel).  This
    probe pairs ROUTINE against ROUTINE, each side cut at its own proven boundaries:

      WSA1   prom_c, the routines kernel/kernel.s defines (notes/kernel_structural_match.py's
             kernel_routines(): every non-`__`, non-`sub_` label, to the next one), decoded
             off the EPROM with the inline data skipped.
      KN5000 v1.42 payload, the routine ENTRY labels below (ENTRIES), each to the next entry,
             addresses from the built ELF rebuilt_ROMs/kn5000_subprogram_v142.llvm.elf,
             decoded off original_ROMs/kn5000_subprogram_v142.rom; the 8-byte config record
             (KN_DATA) is skipped the way prom_c's SoftTimer_Request_Boot is.

    Both are decoded by the same MAME unidasm and tokenised by kernel_structural_match.tok()
    (every 0x... literal -> #).  For every (WSA1, KN5000) pair: LCS of the token sequences, and
    score = LCS / max(len WSA1, len KN5000) -- a SIMILARITY of the two whole routines, not the
    containment A2 used (containment rewards a long candidate that merely holds the query).
    A pairing is accepted only when it is the MUTUAL best (each side's best partner is the
    other), its score is >= ACCEPT, and the accepted pairs are in the same ROM order on both
    sides.  Everything else is "no partner".

    ⚠ The ENTRY list is the KN5000 tree's own routine starts (labels that are call/jump targets or
    carry a routine header, read off v142/subcpu/core/03_task_scheduler_kernel.s at 34bc0c5fe);
    the continuation labels inside a routine (`..._Loop`, `..._Return`, ...) are not entries.
    The KN5000 names are those of 34bc0c5fe, before this lane renamed the paired ones; the
    pairing below is what licensed each rename (notes/open9-a3-probes/README.md).

RUN (from wsa1/, on a built tree: `make gate` at the repo root first)
    UNIDASM=/home/fsanches/compartilhado/mame-sony-video/unidasm \
        python3 notes/open9-a3-probes/kernel_a3_pairing.py             # the table
    ... --matrix NAME      # one WSA1 routine's score against every KN5000 entry
    ... --selftest         # exits 1 if the pairing drifts from PAIRS below
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
WSA1 = os.path.dirname(os.path.dirname(HERE))
REPO = os.path.dirname(WSA1)
sys.path.insert(0, os.path.dirname(HERE))
os.environ.setdefault("UNIDASM", "/home/fsanches/compartilhado/mame-sony-video/unidasm")
import kernel_structural_match as K   # noqa: E402

K.IMAGES["kn5000:payload"] = (os.path.join(REPO, "original_ROMs", "kn5000_subprogram_v142.rom"), None)
ELF = os.path.join(REPO, "rebuilt_ROMs", "kn5000_subprogram_v142.llvm.elf")
NM = "/home/fsanches/compartilhado/llvm-project/build/bin/llvm-nm"
ACCEPT = 0.50

# KN5000 v1.42 routine entries in ROM order, from Kernel_InitRam's partner to the end of
# Kernel_KillTask's; names as of 34bc0c5fe, then (after the A3 rename) the canonical name,
# so the probe runs on either side of the rename.
ENTRIES = [
    ("TaskSched_Init", "Kernel_InitRam"),
    ("TaskSched_ConfigAndDispatch", "Kernel_InitRam__install"),
    ("TaskSched_Halt", "Kernel_Idle"),
    ("TaskSched_Dispatch", "Kernel_Dispatch"),
    ("TaskSched_ContextRestore", "Kernel_ResumeTask"),
    ("TaskSched_SoftTimer_Service", "Kernel_ServiceSoftTimers"),
    ("TaskSwitch_Countdown", "IRQ_Epilogue"),
    ("TaskSched_SpawnTask", "Kernel_StartTask"),
    ("TaskSched_ExitCurrentTask", "Kernel_ExitTask"),
    ("TaskSched_GetCurrentTaskId", "TaskSched_GetCurrentTaskId"),
    ("TaskSched_PreemptiveYield", "Kernel_YieldRotate"),
    ("TaskQueue_Dequeue", "Kernel_RotateQueue"),
    ("TaskSched_Block_Self", "Kernel_BlockSelf"),
    ("TaskSched_Wake_Task", "Kernel_ReadyTask"),
    ("TaskSched_Wake_Task_NoResched", "Kernel_ReadyTask_NoDispatch"),
    ("TaskSched_Take_Pending_Count", "TaskSched_Take_Pending_Count"),
    ("TaskEvent_Signal", "TaskEvent_Signal"),
    ("TaskEvent_Signal_NoResched", "TaskEvent_Signal_NoResched"),
    ("TaskEvent_Wait", "TaskEvent_Wait"),
    ("TaskEvent_Clear", "TaskEvent_Clear"),
    ("TaskSem_Release", "Kernel_SemaSignal"),
    ("TaskSem_Release_NoResched", "Kernel_SemaSignal_NoDispatch"),
    ("TaskSched_Wait", "Kernel_SemaWait"),
    ("TaskSem_TryDec", "Kernel_SemaTryWait"),
    ("TaskSem_GetCount", "TaskSem_GetCount"),
    ("TaskMsgQ_Send", "MsgQueue_Send"),
    ("TaskMsgQ_Send_NoResched", "MsgQueue_Send_NoDispatch"),
    ("TaskMsgQ_Receive", "MsgQueue_ReceiveBlocking"),
    ("TaskMsgQ_TryReceive", "MsgQueue_Receive_NoBlock"),
    ("Task_ConfigTimer", "SoftTimer_Register"),
    ("TaskSched_ChangePriority", "Kernel_SetTaskLevel"),
    ("TaskSched_ChangePriority_NoResched", "Kernel_SetTaskLevel_NoDispatch"),
    ("TaskSched_TerminateTask", "Kernel_KillTask"),
    ("Timer_Delay_Ticks", "Timer_Delay_Ticks"),          # END marker: first routine after the kernel
]
KN_DATA = [("TaskSched_Init_ConfigData", "SoftTimer_Request_Boot", 8)]

# prom_c's SoftTimer_Request_Boot splits Kernel_InitRam's listing in two; its second part
# (Kernel_InitRam__install, the `call SoftTimer_Register`) is a label kernel_routines() folds
# into Kernel_InitRam.  On the KN5000 that call opens TaskSched_ConfigAndDispatch, which runs on
# into the timer start-up WSA1 does in Kernel_Start -- so the KN5000 entry is paired with
# Kernel_Start below, and the 1-instruction `install` tail with nothing.

# ONE pairing is a composite and is accepted by ORDER, not by its own score: the KN5000's
# TaskSched_ConfigAndDispatch is WSA1's `Kernel_InitRam__install` (the 1-instruction tail that
# kernel_routines() files under SoftTimer_Request_Boot, the `call SoftTimer_Register`) followed by
# Kernel_Start.  The concatenation scores exactly ACCEPT (0.500) against it; it lies between two
# accepted pairs (Kernel_InitRam and Kernel_Idle) and nothing else is left between them on either
# side.  Its instructions say the same thing in the same order: install the boot soft timer, stop
# timer 3, program its period and interrupt level, start it, start task 1 (and task 3 on the WSA1),
# `ei 6`, clear the pending ticks, zero the dispatch-inhibit control register, `jrl Kernel_Dispatch`.
COMPOSITES = [("Kernel_Start", ("SoftTimer_Request_Boot", "Kernel_Start"), "TaskSched_ConfigAndDispatch")]

# The measured result (2026-11-06, base 34bc0c5fe).  WSA1 routine -> KN5000 entry (old name).
PAIRS = {
    "Kernel_InitRam": "TaskSched_Init",
    "Kernel_Start": "TaskSched_ConfigAndDispatch",
    "Kernel_Idle": "TaskSched_Halt",
    "Kernel_Dispatch": "TaskSched_Dispatch",
    "Kernel_ResumeTask": "TaskSched_ContextRestore",
    "Kernel_ServiceSoftTimers": "TaskSched_SoftTimer_Service",
    "IRQ_Epilogue": "TaskSwitch_Countdown",
    "Kernel_StartTask": "TaskSched_SpawnTask",
    "Kernel_ExitTask": "TaskSched_ExitCurrentTask",
    "Kernel_YieldRotate": "TaskSched_PreemptiveYield",
    "Kernel_RotateQueue": "TaskQueue_Dequeue",
    "Kernel_BlockSelf": "TaskSched_Block_Self",
    "Kernel_ReadyTask": "TaskSched_Wake_Task",
    "Kernel_ReadyTask_NoDispatch": "TaskSched_Wake_Task_NoResched",
    "Kernel_SemaSignal": "TaskSem_Release",
    "Kernel_SemaSignal_NoDispatch": "TaskSem_Release_NoResched",
    "Kernel_SemaWait": "TaskSched_Wait",
    "Kernel_SemaTryWait": "TaskSem_TryDec",
    "MsgQueue_Send": "TaskMsgQ_Send",
    "MsgQueue_Send_NoDispatch": "TaskMsgQ_Send_NoResched",
    "MsgQueue_ReceiveBlocking": "TaskMsgQ_Receive",
    "MsgQueue_Receive_NoBlock": "TaskMsgQ_TryReceive",
    "SoftTimer_Register": "Task_ConfigTimer",
    "Kernel_SetTaskLevel": "TaskSched_ChangePriority",
    "Kernel_SetTaskLevel_NoDispatch": "TaskSched_ChangePriority_NoResched",
    "Kernel_KillTask": "TaskSched_TerminateTask",
}


def elf_symbols():
    out = subprocess.run([NM, "--defined-only", ELF], capture_output=True, text=True, check=True).stdout
    return {p[2]: int(p[0], 16) for p in (l.split() for l in out.split("\n")) if len(p) == 3}


def kn_routines():
    """[(old name, address, Seq)] for the KN5000 entries, exact extents."""
    sym = elf_symbols()

    def addr(pair):
        for n in pair:
            if n in sym:
                return sym[n]
        sys.exit("kernel_a3_pairing: neither %r nor %r in %s" % (pair[0], pair[1], ELF))
    starts = [(old, addr((old, new))) for old, new in ENTRIES]
    data = [(addr((o, n)), size) for o, n, size in KN_DATA]
    img = K.image("kn5000:payload")
    out = []
    for k in range(len(starts) - 1):
        name, lo = starts[k]
        hi = starts[k + 1][1]
        runs, cur = [], lo
        for dlo, dsz in data:
            if lo <= dlo < hi:
                runs.append((cur, dlo))
                cur = dlo + dsz
        runs.append((cur, hi))
        seq = K.Seq([], 0)
        for a, b in runs:
            if b <= a:
                continue
            o = K.off_of("kn5000:payload", a)
            for a2, n2, t2 in K._unidasm(img[o:o + (b - a)], a):
                if a2 + n2 <= b:
                    seq.addr.append(a2); seq.n.append(n2); seq.text.append(t2); seq.tok.append(K.tok(t2))
        out.append((name, lo, seq))
    return out


def wsa1_routines():
    """[(name, prom_c address, Seq)] in ROM order -- every routine kernel.s defines."""
    out = []
    for lab, a, c, alen, rows in K.kernel_routines():
        out.append((lab, c, K.routine_seq("wsa1:c", c, rows, 1)))
    return out


def score(a, b):
    if not a.tok or not b.tok:
        return 0.0
    return len(K.lcs_pairs(a.tok, b.tok)) / float(max(len(a.tok), len(b.tok)))


def measure():
    W, N = wsa1_routines(), kn_routines()
    M = [[score(w[2], n[2]) for n in N] for w in W]
    best_w = [max(range(len(N)), key=lambda j: M[i][j]) for i in range(len(W))]
    best_n = [max(range(len(W)), key=lambda i: M[i][j]) for j in range(len(N))]
    pairs = {}
    for i, j in enumerate(best_w):
        if best_n[j] == i and M[i][j] >= ACCEPT:
            pairs[W[i][0]] = N[j][0]
    wi = {w[0]: i for i, w in enumerate(W)}
    nj = {n[0]: j for j, n in enumerate(N)}
    for name, parts, kn in COMPOSITES:
        cat = K.Seq([], 0)
        for p_ in parts:
            cat.tok += W[wi[p_]][2].tok
        sc = score(cat, N[nj[kn]][2])
        # accepted only if it scores ACCEPT and sits between two accepted pairs on both sides
        prev = [W[i][0] for i in range(wi[parts[0]]) if W[i][0] in pairs]
        nxt = [W[i][0] for i in range(wi[parts[-1]] + 1, len(W)) if W[i][0] in pairs]
        if sc >= ACCEPT and kn not in pairs.values() and prev and nxt and \
           nj[pairs[prev[-1]]] < nj[kn] < nj[pairs[nxt[0]]]:
            pairs[name] = kn
            M[wi[name]][nj[kn]] = sc
    return W, N, M, pairs


def main():
    W, N, M, pairs = measure()
    if sys.argv[1:2] == ["--matrix"]:
        i = [w[0] for w in W].index(sys.argv[2])
        for j in sorted(range(len(N)), key=lambda j: -M[i][j]):
            print("  %.3f  %-36s 0x%06X  n=%d" % (M[i][j], N[j][0], N[j][1], len(N[j][2])))
        return 0
    nidx = {n[0]: j for j, n in enumerate(N)}
    print("%-40s %8s %4s  %-36s %8s %4s %6s %6s" % ("WSA1 routine (kernel.s)", "prom_c", "n",
          "KN5000 v1.42 entry (34bc0c5fe name)", "addr", "n", "score", "2nd"))
    order = []
    for i, (wn, wa, ws) in enumerate(W):
        kn = pairs.get(wn)
        row = sorted(M[i], reverse=True)
        if kn:
            j = nidx[kn]
            second = max(M[i][k] for k in range(len(N)) if k != j)
            order.append(N[j][1])
            print("%-40s %08X %4d  %-36s %06X %4d %6.3f %6.3f" % (wn, wa, len(ws), kn, N[j][1], len(N[j][2]),
                                                                M[i][j], second))
        else:
            print("%-40s %08X %4d  %-36s %8s %4s %6s %6.3f" % (wn, wa, len(ws), "-- no partner", "", "", "",
                                                             row[0]))
    paired_kn = set(pairs.values())
    for j, (kn, ka, ks) in enumerate(N):
        if kn not in paired_kn:
            print("%-40s %8s %4s  %-36s %06X %4d %6s %6.3f" % ("-- no partner", "", "", kn, ka, len(ks), "",
                                                             max(M[i][j] for i in range(len(W)))))
    mono = all(order[k] < order[k + 1] for k in range(len(order) - 1))
    print("paired %d of %d WSA1 routines and %d of %d KN5000 entries; ROM order the same on both sides: %s"
          % (len(pairs), len(W), len(paired_kn), len(N), "yes" if mono else "NO"))
    if "--selftest" in sys.argv:
        ok = pairs == PAIRS and mono
        if pairs != PAIRS:
            for k in sorted(set(pairs) | set(PAIRS)):
                if pairs.get(k) != PAIRS.get(k):
                    print("  DRIFT %s: measured %r, recorded %r" % (k, pairs.get(k), PAIRS.get(k)))
        print("selftest:", "ok" if ok else "FAIL")
        return 0 if ok else 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
