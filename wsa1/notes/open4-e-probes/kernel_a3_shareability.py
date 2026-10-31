#!/usr/bin/env python3
r"""kernel_a3_shareability.py -- can kernel/kernel.s also build the KN5000 sub-CPU's kernel?

QUESTION THIS ANSWERS (join/split phase A3, notes/PLAN-join-and-split.md sec 10.2)
    A1 made kernel/kernel.s ONE source for both WSA1 CPUs, differing only by `.equ`
    (kernel_maincpu.inc / kernel_subcpu.inc, no .if/.else).  A2
    (notes/FINDINGS-kernel-in-the-kn5000.md) showed the same kernel is in the KN5000's
    sub-CPU payload.  A3 asks whether a third .inc -- `.equ` only -- would let the same
    source emit the KN5000 routines byte for byte.

    For every kernel routine of >= 8 instructions, the prom_c routine (decoded off the ROM by
    notes/kernel_structural_match.py's own decoder) is aligned by LCS with the KN5000 sub-CPU
    code at its A2 match site (the table of FINDINGS sec 3), and each instruction is put in
    one class:
        same      identical bytes
        operand   same disassembled shape and the SAME LENGTH: only an address/count
                  differs, which an `.equ` can carry
        length    same shape, DIFFERENT length (an 8-bit direct address on the WSA1,
                  16-bit on the KN5000: a different encoding, not an `.equ`)
        wsa1-only / kn-only   no partner: an instruction inserted or deleted
    ⚠ `wsa1-only` is a LOWER BOUND on the real difference (LCS maximises the pairing, so a
    wider window can only lower it).  `kn-only` is NOT robust: it is the unpaired KN5000
    instructions between the first and last paired one, and a stray pairing far into the
    window (which holds the next routines) inflates it.  The selftest pins `wsa1-only`.
    A routine is EQUATE-SHAREABLE only when it has no `length`, `wsa1-only` or `kn-only`
    instruction.  Anything else needs per-CPU code -- `.if/.else` round instructions or a
    second spelling -- which the A1 design ruled out.

RUN (from wsa1/)
    UNIDASM=/home/fsanches/compartilhado/mame-sony-video/unidasm \
        python3 notes/open4-e-probes/kernel_a3_shareability.py            # table
    ... --selftest     # exits 1 if the counts drift from the ones FINDINGS quotes
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
os.environ.setdefault("UNIDASM", "/home/fsanches/compartilhado/mame-sony-video/unidasm")
import kernel_structural_match as K   # noqa: E402

# A2's match sites in the KN5000 sub-CPU payload (FINDINGS-kernel-in-the-kn5000.md sec 3)
SITES = {
    "MsgQueue_Send_NoDispatch": 0x0204D5, "Kernel_InitRam": 0x01FDDA, "MsgQueue_Send": 0x02044F,
    "MsgQueue_ReceiveBlocking": 0x020642, "Kernel_SemaSignal_NoDispatch": 0x020374,
    "Kernel_SemaSignal": 0x020308, "Kernel_StartTask": 0x01FFFD,
    "Kernel_SetTaskLevel_NoDispatch": 0x0207B0, "MsgQueue_Receive_NoBlock": 0x0206D3,
    "Kernel_SemaWait": 0x02044F, "Kernel_SetTaskLevel": 0x02072A, "Kernel_YieldRotate": 0x0200C0,
    "Kernel_RotateQueue": 0x0200C4, "Kernel_Dispatch": 0x01FF2A, "Kernel_ReadyTask": 0x02014D,
    "Kernel_ReadyTask_NoDispatch": 0x020189, "Kernel_ServiceSoftTimers": 0x01FF7F,
    "Kernel_KillTask": 0x02080B, "IRQ_Epilogue": 0x01FFD0, "SoftTimer_Register": 0x02072A,
    "Kernel_BlockSelf": 0x02014D, "Kernel_ExitTask": 0x02014E, "Kernel_SemaTryWait": 0x0204A9,
    "Kernel_Start": 0x01FEE7, "MsgQueue_Send_StackArg": 0x01FFFD, "Kernel_ResumeTask": 0x01FF72,
}
KEY = "kn5000:payload"
EXPECT = (26, 1, 10, 93)   # (routines, equate-shareable, length-class, wsa1-only), measured 2026-10-31


def classify(q, site):
    off = K.off_of(KEY, site)
    window = K.query_window(q)
    rows = K._unidasm(K.image(KEY)[off:off + window + 8], site)
    c = K.Seq([], site)
    for a, n, t in rows:
        if a - site + n > window:
            break
        c.addr.append(a); c.n.append(n); c.text.append(t); c.tok.append(K.tok(t))
    qs = q.seq
    pairs = K.lcs_pairs(qs.tok, c.tok)
    cls = {"same": 0, "operand": 0, "length": 0, "wsa1-only": 0, "kn-only": 0}
    data = K.image(KEY)
    wsa = K.image(q.key)
    for i, j in pairs:
        qa, ca = K.off_of(q.key, qs.addr[i]), K.off_of(KEY, c.addr[j])
        qb, cb = wsa[qa:qa + qs.n[i]], data[ca:ca + c.n[j]]
        if qb == cb:
            cls["same"] += 1
        elif qs.n[i] == c.n[j]:
            cls["operand"] += 1
        else:
            cls["length"] += 1
    cls["wsa1-only"] = len(qs.tok) - len(pairs)
    if pairs:
        span = pairs[-1][1] - pairs[0][1] + 1
        cls["kn-only"] = span - len(pairs)
    return cls, len(qs.tok)


def table():
    out = []
    for q in K.kernel_queries(which=1, minlen=8):
        site = SITES.get(q.name)
        if site is None:
            continue
        cls, n = classify(q, site)
        ok = cls["length"] == cls["wsa1-only"] == cls["kn-only"] == 0
        out.append((q.name, n, cls, ok))
    return out


def main():
    rows = table()
    print("%-32s %4s %5s %8s %7s %10s %8s  %s" % ("routine", "n", "same", "operand", "length",
                                                 "wsa1-only", "kn-only", "equate-shareable"))
    tot = {"same": 0, "operand": 0, "length": 0, "wsa1-only": 0, "kn-only": 0}
    for name, n, c, ok in rows:
        print("%-32s %4d %5d %8d %7d %10d %8d  %s" % (name, n, c["same"], c["operand"], c["length"],
                                                     c["wsa1-only"], c["kn-only"], "YES" if ok else "no"))
        for k in tot:
            tot[k] += c[k]
    nok = sum(1 for r in rows if r[3])
    print("TOTAL %d routines: %s; equate-shareable %d" % (len(rows), tot, nok))
    return rows, tot, nok


if __name__ == "__main__":
    rows, tot, nok = main()
    if sys.argv[1:] == ["--selftest"]:
        want = EXPECT
        got = (len(rows), nok, tot["length"], tot["wsa1-only"])
        print("selftest:", "ok" if got == want else "DRIFT %r != %r" % (got, want))
        sys.exit(0 if got == want else 1)
