#!/usr/bin/env python3
"""faj_eq_response.py -- frequency response of the KN5000 FAJ board's speaker-path filters.

Question it answers (open item N-29e0f8b4): what do the "EQUALIZING" sections on the FAJ board
(IC8, IC10, IC11, IC12, service manual p. II-25, PDF page 39) do to the speaker signal, and what
do the stages around them (IC4 "MIXING AMP", IC7 "LOW PASS FILTER", IC14 output summer) do?

Method: exact nodal analysis (MNA) with ideal op-amps (nullor: V+ = V-, output current free),
over polynomials in s with rational coefficients (fractions.Fraction), so every transfer
function comes out as an exact ratio of polynomials.  Poles and zeros are then found with
numpy.roots and reported as f0 / Q; magnitudes are tabulated at the 1/3-octave ISO centres.

The component values are the left channel's (IC*A); the right channel (IC*B) carries the same
values on the sheet (table VALUES below gives both reference designators).  Readings of the
scan are in VALUES with a confidence column.

Run:  python3 faj_eq_response.py            (prints everything; about 15 s)
      python3 faj_eq_response.py --brief    (section summary only)
      python3 faj_eq_response.py --set=R16=82000   (re-run with one value changed, e.g. to see
                                                    what a misread would change)

Needs only numpy.  Ideal op-amps: the M5218AL's finite gain-bandwidth (about 10 MHz, typical)
does not matter below 20 kHz at these gains.
"""
import math
import sys
from fractions import Fraction as F

import numpy as np

K = 1000
U = F(1, 10**6)          # micro
P = F(1, 10**12)         # pico

# ---------------------------------------------------------------------------------------------
# Component values read from the FAJ sheet (PDF page 39 of technics_sx-kn5000.pdf, printed
# II-25, grid 6-9 / A-C).  (left ref, right ref, value, confidence)
# confidence: "clear" = legible on the 500 dpi render and the same on both channels.
VALUES = {
    # IC4A/B "MIXING AMP" (inverting summer); only the DAC input is modelled
    "Cin":  ("C37", "C38", 10 * U, "clear (polarity mark; 16V10 = 10 uF 16 V)"),
    "Rin":  ("R82", "R84", F(10 * K), "clear"),
    "Rf4":  ("R85", "R86", F(33 * K), "clear"),
    "Cf4":  ("C46", "C45", 220 * P, "clear"),
    # IC7A/B: drawn as a multiple-feedback HIGH-pass, though labelled "LOW PASS FILTER"
    "C42":  ("C42", "C41", F(47, 1000) * U, "clear"),
    "R38":  ("R38", "R37", F(10 * K), "clear"),
    "C48":  ("C48", "C47", F(68, 1000) * U, "clear (TF mark)"),
    "C96":  ("C96", "C97", F(68, 1000) * U, "clear (TF mark)"),
    "R87":  ("R87", "R88", F(150 * K), "clear"),
    "C67":  ("C67", "C68", 22 * P, "clear"),
    # series resistor from IC7 output into the equaliser bus
    "R55":  ("R55", "R56", F(3300), "clear"),
    # IC8A/B shunt network
    "R28":  ("R28", "R78", F(6800), "clear"),
    "C59":  ("C59", "C61", F(47, 10000) * U, "clear"),
    "R60":  ("R60", "R61", F(4700), "clear"),
    "C60":  ("C60", "C62", F(1, 100) * U, "clear"),
    "R57":  ("R57", "R58", F(150 * K), "clear"),
    # IC10A/B shunt network (same topology as IC8)
    "R95":  ("R95", "R96", F(6800), "clear"),
    "C4":   ("C4", "C82", F(1, 100) * U, "clear"),
    "R7":   ("R7", "R10", F(4700), "clear"),
    "C57":  ("C57", "C83", F(47, 1000) * U, "clear"),
    "R2":   ("R2", "R3", F(150 * K), "clear"),
    # IC11A/B: series C + gyrator (simulated series RLC to ground)
    "C84":  ("C84", "C86", F(15, 1000) * U, "clear"),
    "R13":  ("R13", "R15", F(1 * K), "clear"),
    "C85":  ("C85", "C87", F(22, 10000) * U, "clear"),
    "R11":  ("R11", "R12", F(150 * K), "clear"),
    # IC12A/B: gyrator with no series C
    "R18":  ("R18", "R21", F(10 * K), "clear"),
    "C89":  ("C89", "C91", F(15, 1000) * U, "clear"),
    "R16":  ("R16", "R17", F(8200), "clear (8.2K; low for a gyrator, see README)"),
    # IC14A/B output summer
    "R41":  ("R41", "R42", F(82 * K), "clear"),
    "R91":  ("R91", "R92", F(150 * K), "clear"),
    "C98":  ("C98", "C99", 33 * P, "clear"),
}
V = {k: v[2] for k, v in VALUES.items()}

# ---------------------------------------------------------------------------------------------
# exact polynomial arithmetic (lists of Fractions, index = power of s)


def ptrim(a):
    a = list(a)
    while len(a) > 1 and a[-1] == 0:
        a.pop()
    return a


def padd(a, b):
    n = max(len(a), len(b))
    return ptrim([(a[i] if i < len(a) else 0) + (b[i] if i < len(b) else 0) for i in range(n)])


def pneg(a):
    return [-x for x in a]


def pmul(a, b):
    r = [F(0)] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        if x:
            for j, y in enumerate(b):
                r[i + j] += x * y
    return ptrim(r)


def pdiv_exact(a, b):
    a, b = ptrim(a), ptrim(b)
    if a == [0]:
        return [F(0)]
    q = [F(0)] * (len(a) - len(b) + 1)
    r = list(a)
    for i in range(len(q) - 1, -1, -1):
        c = r[i + len(b) - 1] / b[-1]
        q[i] = c
        for j, y in enumerate(b):
            r[i + j] -= c * y
    assert all(x == 0 for x in r), "inexact division"
    return ptrim(q)


def pdet(M):
    """Bareiss fraction-free determinant over the polynomial ring."""
    M = [[ptrim(x) for x in row] for row in M]
    n = len(M)
    sign = 1
    prev = [F(1)]
    for k in range(n - 1):
        if M[k][k] == [0]:
            for i in range(k + 1, n):
                if M[i][k] != [0]:
                    M[k], M[i] = M[i], M[k]
                    sign = -sign
                    break
            else:
                return [F(0)]
        for i in range(k + 1, n):
            for j in range(k + 1, n):
                M[i][j] = pdiv_exact(padd(pmul(M[i][j], M[k][k]), pneg(pmul(M[i][k], M[k][j]))), prev)
        prev = M[k][k]
    d = M[n - 1][n - 1]
    return d if sign > 0 else pneg(d)


# ---------------------------------------------------------------------------------------------
# netlist -> transfer function


class Circuit:
    def __init__(self):
        self.el = []        # (a, b, admittance poly)
        self.opamps = []    # (plus, minus, out)
        self.nodes = {"0"}

    def _n(self, *ns):
        self.nodes.update(ns)

    def R(self, a, b, r):
        self._n(a, b)
        self.el.append((a, b, [F(1) / F(r)]))

    def C(self, a, b, c):
        self._n(a, b)
        self.el.append((a, b, [F(0), F(c)]))

    def opamp(self, plus, minus, out):
        self._n(plus, minus, out)
        self.opamps.append((plus, minus, out))

    def tf(self, src, out):
        """V(out)/V(src) with an ideal voltage source on node src; also returns Zin poly pair."""
        nodes = sorted(self.nodes - {"0"})
        idx = {n: i for i, n in enumerate(nodes)}
        nn = len(nodes)
        size = nn + len(self.opamps) + 1
        Z = [F(0)]
        A = [[list(Z) for _ in range(size)] for _ in range(size)]

        def add(i, j, y):
            A[i][j] = padd(A[i][j], y)
        for a, b, y in self.el:
            if a != "0":
                add(idx[a], idx[a], y)
            if b != "0":
                add(idx[b], idx[b], y)
            if a != "0" and b != "0":
                add(idx[a], idx[b], pneg(y))
                add(idx[b], idx[a], pneg(y))
        for k, (p, m, o) in enumerate(self.opamps):
            col = nn + k
            add(idx[o], col, [F(-1)])          # output current leaves into the node
            if p != "0":
                add(col, idx[p], [F(1)])
            if m != "0":
                add(col, idx[m], [F(-1)])
        s = nn + len(self.opamps)
        add(idx[src], s, [F(-1)])              # source current
        add(s, idx[src], [F(1)])               # V(src) = 1
        D = pdet(A)

        def cramer(col):
            B = [row[:] for row in A]
            for i in range(size):
                B[i][col] = [F(1)] if i == s else [F(0)]
            return pdet(B)
        num = cramer(idx[out])
        isrc = cramer(s)                       # source current (into the circuit) / D
        return (num, D), (D, isrc)             # H = num/D ; Zin = D/isrc


def peval(p, s):
    return sum(complex(c) * s ** i for i, c in enumerate(p))


def H_at(h, f):
    s = 2j * math.pi * f
    return peval(h[0], s) / peval(h[1], s)


def roots(p):
    p = ptrim(p)
    if len(p) <= 1:
        return []
    c = np.array([float(x) for x in reversed(p)])
    c = c / c[0]
    return list(np.roots(c))


def describe_roots(rs):
    out, used = [], set()
    rs = sorted(rs, key=lambda r: abs(r))
    for i, r in enumerate(rs):
        if i in used:
            continue
        used.add(i)
        w = abs(r)
        if abs(r.imag) > 1e-6 * w:
            for j in range(i + 1, len(rs)):
                if j not in used and abs(rs[j] - r.conjugate()) < 1e-6 * w:
                    used.add(j)
                    break
            q = w / (2 * abs(r.real)) if r.real else float("inf")
            out.append("pair f0 %.1f Hz Q %.3f" % (w / (2 * math.pi), q))
        else:
            out.append("real %.2f Hz%s" % (w / (2 * math.pi), "" if r.real <= 0 or w == 0 else " (RHP)") if w else "s = 0")
    return out


def db(x):
    return 20 * math.log10(abs(x)) if abs(x) > 0 else -999.0


# ---------------------------------------------------------------------------------------------
# the circuit, section by section (node names are local to each sub-circuit)


def stage_mix():
    c = Circuit()            # LOUT -> C37 -> R82 -> IC4A(-); feedback R85 || C46
    c.C("in", "a", V["Cin"])
    c.R("a", "n4", V["Rin"])
    c.R("n4", "o4", V["Rf4"])
    c.C("n4", "o4", V["Cf4"])
    c.opamp("0", "n4", "o4")
    return c, "in", "o4"


def stage_ic7():
    c = Circuit()            # C42 in; R38 to ground; C48 to (-); C96 to output; R87 || C67 feedback
    c.C("in", "j", V["C42"])
    c.R("j", "0", V["R38"])
    c.C("j", "n7", V["C48"])
    c.C("j", "o7", V["C96"])
    c.R("n7", "o7", V["R87"])
    c.C("n7", "o7", V["C67"])
    c.opamp("0", "n7", "o7")
    return c, "in", "o7"


def add_ic8_like(c, bus, tag, Rs, C1, Rf, C2, Rg):
    """IC8 / IC10: bus-Rs-out, bus-C1-Y, Y-Rf-out, Y-C2-P, P-Rg-gnd, follower P->out."""
    y, p, o = tag + "y", tag + "p", tag + "o"
    c.R(bus, o, Rs)
    c.C(bus, y, C1)
    c.R(y, o, Rf)
    c.C(y, p, C2)
    c.R(p, "0", Rg)
    c.opamp(p, o, o)


def add_ic11(c, bus, tag):
    m, p, o = tag + "m", tag + "p", tag + "o"
    c.C(bus, m, V["C84"])
    c.R(m, o, V["R13"])
    c.C(m, p, V["C85"])
    c.R(p, "0", V["R11"])
    c.opamp(p, o, o)


def add_ic12(c, bus, tag):
    p, o = tag + "p", tag + "o"
    c.R(bus, o, V["R18"])
    c.C(bus, p, V["C89"])
    c.R(p, "0", V["R16"])
    c.opamp(p, o, o)


SHUNTS = {
    "IC8":  lambda c, b: add_ic8_like(c, b, "i8", V["R28"], V["C59"], V["R60"], V["C60"], V["R57"]),
    "IC10": lambda c, b: add_ic8_like(c, b, "i10", V["R95"], V["C4"], V["R7"], V["C57"], V["R2"]),
    "IC11": lambda c, b: add_ic11(c, b, "i11"),
    "IC12": lambda c, b: add_ic12(c, b, "i12"),
}


def stage_eq(which):
    """IC7 output (ideal source) -> R55 -> bus; shunts `which`; R41 into IC14's virtual ground."""
    c = Circuit()
    c.R("in", "bus", V["R55"])
    c.R("bus", "0", V["R41"])       # IC14A inverting input is a virtual ground
    for w in which:
        SHUNTS[w](c, "bus")
    return c, "in", "bus"


def shunt_alone(which):
    c = Circuit()
    SHUNTS[which](c, "in")
    return c, "in", "in"


def stage_ic14():
    c = Circuit()
    c.R("in", "n14", V["R41"])
    c.R("n14", "o14", V["R91"])
    c.C("n14", "o14", V["C98"])
    c.opamp("0", "n14", "o14")
    return c, "in", "o14"


def whole_path():
    c = Circuit()
    c.C("in", "a", V["Cin"])
    c.R("a", "n4", V["Rin"])
    c.R("n4", "o4", V["Rf4"])
    c.C("n4", "o4", V["Cf4"])
    c.opamp("0", "n4", "o4")
    c.C("o4", "j", V["C42"])
    c.R("j", "0", V["R38"])
    c.C("j", "n7", V["C48"])
    c.C("j", "o7", V["C96"])
    c.R("n7", "o7", V["R87"])
    c.C("n7", "o7", V["C67"])
    c.opamp("0", "n7", "o7")
    c.R("o7", "bus", V["R55"])
    for w in SHUNTS:
        SHUNTS[w](c, "bus")
    c.R("bus", "n14", V["R41"])
    c.R("n14", "o14", V["R91"])
    c.C("n14", "o14", V["C98"])
    c.opamp("0", "n14", "o14")
    return c, "in", "o14"


ISO = [20, 25, 31.5, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630, 800, 1000, 1250,
       1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000, 10000, 12500, 16000, 20000]


def extrema(h, lo=10.0, hi=40000.0, n=4000, prominence=0.1):
    """Local maxima / minima of |H| that stand at least `prominence` dB above (below) the lowest
    (highest) point within half an octave on either side; flat stretches are not reported."""
    fs = [lo * (hi / lo) ** (i / (n - 1)) for i in range(n)]
    m = [db(H_at(h, f)) for f in fs]
    half = int(round((n - 1) * math.log(2 ** 0.5) / math.log(hi / lo)))
    ext = []
    for i in range(1, n - 1):
        win = m[max(0, i - half):i + half + 1]
        if m[i] > m[i - 1] and m[i] >= m[i + 1] and m[i] - min(win) >= prominence:
            ext.append(("max", fs[i], m[i]))
        if m[i] < m[i - 1] and m[i] <= m[i + 1] and max(win) - m[i] >= prominence:
            ext.append(("min", fs[i], m[i]))
    return ext


def report(name, c_src_out, brief):
    c, src, out = c_src_out
    h, zin = c.tf(src, out)
    print("== %s" % name)
    if not brief:
        print("   zeros: " + ("; ".join(describe_roots(roots(h[0]))) or "none"))
        print("   poles: " + ("; ".join(describe_roots(roots(h[1]))) or "none"))
    for kind, f, m in extrema(h):
        print("   local %s %.0f Hz  %+.2f dB" % (kind, f, m))
    print("   gain at 1 kHz %+.2f dB; at 20 Hz %+.2f dB; at 20 kHz %+.2f dB" %
          (db(H_at(h, 1000)), db(H_at(h, 20)), db(H_at(h, 20000))))
    return h, zin


def main():
    brief = "--brief" in sys.argv
    for a in sys.argv[1:]:
        if a.startswith("--set="):          # sensitivity check: --set=R16=82000
            k, val = a[len("--set="):].split("=")
            V[k] = F(val)
            print("value override: %s (%s) = %s" % (k, VALUES[k][0], val))
    print("KN5000 FAJ board speaker path, left channel (right channel: same values)\n")
    res = {}
    res["mix"] = report("IC4A mixing amp, DAC input (C37 + R82 in, R85 || C46 feedback)", stage_mix(), brief)
    res["ic7"] = report("IC7A (labelled LOW PASS FILTER; drawn as an MFB high-pass)", stage_ic7(), brief)
    for w in SHUNTS:
        res[w] = report("EQ bus with %s alone (R55 3.3k source, R41 82k load)" % w, stage_eq([w]), brief)
        if not brief:
            _, zin = shunt_alone(w)[0].tf("in", "in")
            z = zin
            print("   Zin of %s alone: zeros %s; poles %s" % (
                w, "; ".join(describe_roots(roots(z[0]))) or "none",
                "; ".join(describe_roots(roots(z[1]))) or "none"))
            print("   |Zin| at 20 Hz / 1 kHz / 20 kHz: %.0f / %.0f / %.0f ohm" % tuple(
                abs(H_at(z, f)) for f in (20, 1000, 20000)))
    res["eq"] = report("EQ bus, all four shunts", stage_eq(list(SHUNTS)), brief)
    res["ic14"] = report("IC14A output summer (R41 in, R91 || C98)", stage_ic14(), brief)
    res["all"] = report("WHOLE PATH: LOUT (main CN9) -> IC14A output (to SWA as LIN)", whole_path(), brief)

    cols = ["mix", "ic7", "IC8", "IC10", "IC11", "IC12", "eq", "ic14", "all"]
    print("\nMagnitude, dB (EQ columns: bus voltage / IC7 output voltage, each shunt alone, then all four)")
    hdr = "| f (Hz) | " + " | ".join("%6s" % c for c in cols) + " | EQ rel 1k | all rel 1k |"
    print(hdr)
    print("|" + "|".join("-" * (len(x) + 0) for x in hdr.split("|")[1:-1]) + "|")
    eq1k = db(H_at(res["eq"][0], 1000))
    all1k = db(H_at(res["all"][0], 1000))
    for f in ISO:
        cells = ["%+6.2f" % db(H_at(res[c][0], f)) for c in cols]
        e = db(H_at(res["eq"][0], f)) - eq1k
        a = db(H_at(res["all"][0], f)) - all1k
        print("| %6s | " % (("%g" % f)) + " | ".join(cells) + " | %+9.2f | %+10.2f |" % (e, a))


if __name__ == "__main__":
    main()
