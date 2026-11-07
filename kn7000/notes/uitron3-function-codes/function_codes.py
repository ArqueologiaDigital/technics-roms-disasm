#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Question: "which uITRON 3.0 service is each MILK kernel routine that reports an error, by the
# function code it passes to KernelErrorHook / KernelErrorHook2, and is that routine the
# service's entry or an inner body?"
#
# Each kernel service of the MILK kernel (Technics SX-KN7000 and its MN10300 siblings) calls
# KernelErrorHook or KernelErrorHook2 just before it returns an error, with d0 = the service's
# function code and d1 = the uITRON error code.  The function codes are those of the "uITRON 3.0
# Specification" Ver 3.02.00 (TRON Association, document I-01-02E), section 6.3 "Function Codes";
# the error codes are its section 6.7.  The specification may be reproduced only in its entirety,
# so it is not in this repository: fetch_spec.sh downloads it into spec/ (git-ignored) and this
# script parses both tables from that copy at run time.
#
# For every tree it lists each KernelErrorHook* call: d0 and its service name, d1 and its error
# name, the routine it is in (its current label), the routines that call or jump to that routine,
# and a verdict:
#   ok         the label is the service's name, or <name>_Impl and a caller is <name>
#   wrapper    the routine is the body of a service-call wrapper (the context-saving trap stub every
#              exported service has: `udf15 d3, d3` ... `call <body>_entry`); the body is
#              <name>_Impl and the wrapper <name>
#   name       a func_ placeholder that is the service itself (no wrapper calls it)
#   MISMATCH   a non-placeholder label that disagrees with the code
#
#     sh kn7000/notes/uitron3-function-codes/fetch_spec.sh
#     python3 -I kn7000/notes/uitron3-function-codes/function_codes.py            # all trees
#     python3 -I kn7000/notes/uitron3-function-codes/function_codes.py --selftest
#     python3 -I kn7000/notes/uitron3-function-codes/function_codes.py --codes    # the parsed table's
#                                                       # names, for the codes the firmware uses
# (run from the repository root).
import argparse
import collections
import glob
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SPEC = os.path.join(HERE, "spec", "mitron3.02.txt")

# tree key -> (label, list of source globs, relative to the repository root)
TREES = collections.OrderedDict([
    ("941",    ("KN7000 program 941 (v1.6)",       ["kn7000/src/program.s", "kn7000/src/program/*.s"])),
    ("942",    ("KN7000 program 942 (SP7001)",     ["kn7000/src/sp7001/program.s", "kn7000/src/sp7001/program/*.s"])),
    ("935",    ("KN7000 program 935 (v1.5)",       ["kn7000/src/b935/program.s", "kn7000/src/b935/program/*.s"])),
    ("893",    ("KN7000 program 893 (v1.3)",       ["kn7000/src/b893/program.s", "kn7000/src/b893/program/*.s"])),
    ("kn6000", ("SX-KN6000 v7.1",                  ["kn6000/src/program.s", "kn6000/src/program/*.s"])),
    ("kn6500", ("SX-KN6500 v1.3",                  ["kn6500/src/program.s", "kn6500/src/program/*.s"])),
    ("kn2400", ("SX-KN2400 (KN2600 v1.1)",         ["kn2400/src/program.s", "kn2400/src/program/*.s"])),
    ("hdsx3",  ("HD-SX3 (XAPR plug-in)",           ["hdsx3/src/program.s", "hdsx3/src/program/*.s"])),
])

# Names the firmware itself gives, in program 942: the plug-in export table
# (kn7000_sp7001_exports.sym) names the services' entries.  The selftest checks the
# specification's code for each against what the named routine (or the body it calls) reports.
ANCHORS_942 = {"cre_tsk": -17, "wai_sem": -53, "rot_rdq": -28, "exd_tsk": -22, "ext_tsk": -21,
               "unl_cpu": -7, "ter_tsk": -25}


# ---------------------------------------------------------------------------------------------
# the specification

def read_spec(path):
    if not os.path.exists(path):
        sys.exit(f"{path}: missing; run fetch_spec.sh first")
    return open(path, encoding="ascii", errors="replace").read().split("\n")


def section(lines, number):
    """Lines of section <number> (e.g. '6.3'): from its starred header to the next one."""
    start = None
    for i, ln in enumerate(lines):
        if re.match(r"^\*\*\*\s+" + re.escape(number) + r"\s", ln):
            start = i
        elif start is not None and re.match(r"^\*\*\*\s+\d+\.\d+\s", ln):
            return lines[start:i]
    return lines[start:] if start is not None else []


CELL_TOKEN = re.compile(r"^(-[a-z]?|=|[A-Za-z]{1,3})$")
ANNOT = re.compile(r"(V2|New|Name)")


def parse_function_codes(lines):
    """Section 6.3's table -> {code: (name, reserved, prefix_dash)} and a list of notes.

    The table has one block per 16 codes (row H'ffX0, columns +0..+F, 4 characters each):
    optional prefix lines (letters prepended to the name, '-' marking a reserved code), the
    name's first and second parts, and, in some blocks, a line marking codes V2 (used by ITRON2 /
    uITRON 2.0 only, so reserved in 3.0), New or Name.  In a block with that line, V2 decides
    which codes are reserved; the prefix line's '-' is only cross-checked (the notes list where the
    two disagree)."""
    sec = section(lines, "6.3")
    codes, notes = {}, []
    blocks, cur = [], None
    for ln in sec:
        m = re.match(r"^\| H'(ff[0-9a-f]0) \|(.*)$", ln)
        if m:
            cur = [int(m.group(1), 16), [m.group(2)]]
            blocks.append(cur)
            continue
        if ln.startswith("+"):
            cur = None
            continue
        if cur is not None and ln.startswith("|        |"):
            cur[1].append(ln[10:])
    for base, raw in blocks:
        rows = [r.split("|")[0].ljust(63) for r in raw]
        annot = [r for r in rows if ANNOT.search(r)]
        cells = []
        for r in rows:
            if r in annot:
                continue
            toks = r.replace(":", " ").split()
            if toks and all(CELL_TOKEN.match(t) for t in toks):
                cells.append(r)
        lettered = [r for r in cells if re.search(r"[A-Za-z]", r)]
        if len(lettered) < 2:
            for k in range(16):
                codes[base + k - 0x10000] = (None, True, True)
            continue
        main, suffix = lettered[-2], lettered[-1]
        prefixes = [r for r in cells if r is not main and r is not suffix and cells.index(r) < cells.index(main)]
        v2 = set()
        for a in annot:
            for m in re.finditer("V2", a):
                v2.add(m.start() // 4)
        for k in range(16):
            first = main[4 * k:4 * k + 3].strip()
            second = suffix[4 * k:4 * k + 3].strip()
            pre = "".join(p[4 * k:4 * k + 3].strip() for p in prefixes)
            dash = "-" in pre or first in ("", "-", "=")
            reserved = (k in v2 or first in ("", "-", "=")) if annot else dash
            name = None
            if first not in ("", "-", "=") and second:
                letters = pre.replace("-", "").lower()
                name = (letters if not ("-" in pre and not reserved) else "") + first + "_" + second
            code = base + k - 0x10000
            if annot and dash != reserved and first not in ("", "-", "="):
                notes.append(f"H'{base + k:04x} ({code}): the prefix line says {'reserved' if dash else 'used'}, "
                             f"the V2 line says {'reserved' if reserved else 'used'}; taken as "
                             f"{'reserved' if reserved else name}")
            codes[code] = (name, reserved, dash)
    return codes, notes


def parse_error_codes(lines):
    errs = {}
    for ln in section(lines, "6.7"):
        m = re.match(r"^\s*(E_[A-Z]+)\s+\(?(-?\d+)\)?\s", ln)
        if m:
            errs.setdefault(int(m.group(2)), m.group(1))
    return errs


# ---------------------------------------------------------------------------------------------
# the sources

LABEL = re.compile(rb"^([A-Za-z_.$][\w.$]*):")
INSN = re.compile(rb"^\s+([a-z][a-z0-9]*)\s+(.*?)\s*(?:[#;].*)?$")
MOVIMM = re.compile(rb"^\s+mov\s+(\S+),\s*(d[01])\s*$")
HOOK = re.compile(rb"^\s+call\s+(KernelErrorHook\w*)\b")


def is_local(label, routine):
    if re.match(r"^loc_[0-9A-F]{8}$", label) or label.startswith("."):
        return True
    if routine and (label == routine + "_entry" or re.match(re.escape(routine) + r"(_entry)?_L[0-9a-f]+$", label)):
        return True
    return False


def num(s):
    try:
        return int(s, 0)
    except ValueError:
        return None


def scan_tree(globs, root):
    files = []
    for g in globs:
        files += sorted(glob.glob(os.path.join(root, g)))
    owner = {}          # label -> routine
    insns = []          # (routine, mnemonic, operands, line bytes, recent lines)
    hooks = []          # (routine, hook, d0, d1, file:line)
    udf15 = set()       # routines that save the context the way the service-call wrapper does
    first = collections.defaultdict(list)   # routine -> its first two instructions
    order = []
    for f in files:
        lines = open(f, "rb").read().split(b"\n")
        cur = None
        for i, ln in enumerate(lines):
            m = LABEL.match(ln)
            if m:
                lab = m.group(1).decode("latin-1")
                if not is_local(lab, cur):
                    cur = lab
                    order.append(cur)
                owner[lab] = cur
                continue
            mi = INSN.match(ln)
            if not mi or cur is None:
                continue
            mn, ops = mi.group(1).decode(), mi.group(2).decode("latin-1")
            insns.append((cur, mn, ops))
            if len(first[cur]) < 2:
                first[cur].append(f"{mn} {ops}")
            if mn == "udf15":
                udf15.add(cur)
            h = HOOK.match(ln)
            if h:
                got = {}
                for j in range(i - 1, max(i - 9, -1), -1):
                    if LABEL.match(lines[j]):
                        break
                    r = MOVIMM.match(lines[j])
                    if r and r.group(2).decode() not in got:
                        got[r.group(2).decode()] = r.group(1).decode()
                hooks.append((cur, h.group(1).decode(), got.get("d0"), got.get("d1"),
                              f"{os.path.relpath(f, root)}:{i + 1}"))
    # the service-call wrapper (the trap stub of every service a task calls through the kernel):
    # `add -4, sp / mov d1, (0, sp)`, then, unless the call is nested, the register save
    # (`udf15 d3, d3` reads a system register), a switch to the kernel stack and `call <body>_entry`
    wrappers = {r for r in udf15 if first[r] == ["add -4, sp", "mov d1, (0, sp)"]}
    fps = collections.defaultdict(list)
    for r, mn, ops in insns:
        toks = re.split(r"([\s,()\[\]]+)", ops)
        norm = "".join("L" if t in owner else "A" if re.match(r"^-?0x[0-9a-f]{5,}$", t) else t for t in toks)
        fps[r].append(f"{mn} {norm}")
    callers = collections.defaultdict(set)
    for r, mn, ops in insns:
        if mn in ("call", "calls", "jmp", "bra") or (mn.startswith("b") and mn not in ("bset", "bclr", "btst")):
            t = ops.split(",")[0].strip()
            if t in owner and owner[t] != r:
                callers[owner[t]].add((r, mn))
    callees = collections.defaultdict(set)
    for callee, cs in callers.items():
        for c, mn in cs:
            if mn in ("call", "calls"):
                callees[c].add(callee)
    return {"hooks": hooks, "callers": callers, "callees": callees, "wrappers": wrappers, "routines": order,
            "fp": {r: tuple(v) for r, v in fps.items()}}


# Two services report another service's code: the polling variants' bodies pass the code of the
# waiting service they share their core with (d1 then is the core's result in a register, E_TMOUT
# when the poll fails).  Where a code is reported by two routines and one of them passes d1 in a
# register, that one is the polling service.  Evidence, program 942 (checked by --selftest): the
# export table names the -53 register variant's wrapper `preq_sem`, and the exported forwarder
# `prcv_msg_X` calls the -61 register variant's wrapper (`rcv_msg_X` the other's).
POLLING = {-61: "prcv_msg", -53: "preq_sem"}

# program 942's exported forwarders (region 1) -> the code the body behind the routine they call
# reports, and whether it is the polling variant
FORWARDERS_942 = {"cre_tsk_X": (-17, False), "chg_pri_X": (-27, False), "wai_flg_X": (-46, False),
                  "rcv_msg_X": (-61, False), "prcv_msg_X": (-61, True)}


def is_placeholder(name):
    return name.startswith("func_")


def verdicts(tree, codes):
    """Per reporting routine: its code, d1s, callers, the names the structure asks for, the verdict."""
    rows = collections.OrderedDict()
    for r, hook, d0, d1, where in tree["hooks"]:
        row = rows.setdefault(r, {"d0": set(), "d1": set(), "hook": set(), "where": []})
        row["d0"].add(num(d0) if d0 is not None and num(d0) is not None else d0)
        row["d1"].add(num(d1) if d1 is not None and num(d1) is not None else d1)
        row["hook"].add(hook)
        row["where"].append(where)
    by_code = collections.defaultdict(list)
    for r, row in rows.items():
        for c in row["d0"]:
            by_code[c].append(r)
    out = []
    for r, row in rows.items():
        d0s = sorted(c for c in row["d0"] if isinstance(c, int))
        code = d0s[0] if len(d0s) == 1 and len(row["d0"]) == 1 else None
        spec_name = codes.get(code)
        polling = (code in POLLING and len(by_code[code]) > 1
                   and any(not isinstance(e, int) for e in row["d1"]))
        svc = POLLING[code] if polling else spec_name
        calls = sorted(tree["callers"].get(r, ()))
        wrap = sorted({c for c, mn in calls if c in tree["wrappers"]})
        if svc is None:
            want, want_w, v = None, None, "UNDECODED"
        else:
            want, want_w = (svc + "_Impl", svc) if wrap else (svc, None)
            wrong = [x for x in [r] + wrap if x != (want if x == r else want_w)]
            v = "ok" if not wrong else "rename" if all(is_placeholder(x) for x in wrong) else "MISMATCH"
        out.append({"routine": r, "d0": d0s, "d1": row["d1"], "hooks": sorted(row["hook"]), "spec": spec_name,
                    "service": svc, "polling": polling, "callers": calls, "wrappers": wrap, "want": want,
                    "want_wrapper": want_w, "verdict": v, "where": row["where"]})
    out.sort(key=lambda x: (x["d0"][0] if x["d0"] else 0, x["routine"]))
    return out


# Services named without a function code or a name of the firmware's own (README, "rsm_tsk").
HAND = {"rsm_tsk": "its body undoes sus_tsk (TCB +0x12 count down, the suspend bit 2 cleared or the task made "
                   "ready); sus_tsk's callers call it in mirror order [INFERENCE]"}


EXPORTS_942 = "kn7000/kn7000_sp7001_exports.sym"


def names_942(t, root="."):
    """Program 942's own names for kernel services: {routine: (service, how)}.  A wrapper the export
    table (kn7000_sp7001_exports.sym, generated from it) names keeps its label; a routine an exported
    forwarder `<svc>_X` calls is <svc>."""
    exported = set()
    for ln in open(os.path.join(root, EXPORTS_942), encoding="latin-1"):
        m = re.match(r"^0x[0-9A-Fa-f]{8}\s+(\w+)", ln)
        if m:
            exported.add(m.group(1))
    out = {}
    for w in t["wrappers"]:
        if w in exported:
            out[w] = (w, "export table")
    for fwd in t["callees"]:
        m = re.match(r"^([a-z]{3,4}_[a-z]{3})_X$", fwd)
        if m:
            for c in t["callees"][fwd]:
                out[c] = (m.group(1), f"forwarder {fwd}")
    return out


def services(tree, vs, t942, n942):
    """Every service-call wrapper and its body, plus the bodies a task calls directly, with the names
    the evidence asks for: the function code (section 1's verdicts), else program 942's names carried
    by an identical body (labels and addresses masked)."""
    by_fp = collections.defaultdict(set)
    for r, (svc, how) in n942.items():
        if r in t942["wrappers"]:
            for b in t942["callees"][r]:
                by_fp[t942["fp"][b]].add((svc, how, True))
        else:
            by_fp[t942["fp"][r]].add((svc, how, False))
    code_of = {}
    for v in vs:
        if v["service"]:
            code_of[v["routine"]] = (v["service"], f"code {v['d0'][0]}" + (" (polling)" if v["polling"] else ""))
            for w in v["wrappers"]:
                code_of[w] = (v["service"], f"code {v['d0'][0]}")
    rows = []
    seen = set()
    for w in sorted(tree["wrappers"]):
        for b in sorted(tree["callees"][w]):
            seen.add(b)
            svc, how = code_of.get(b, (None, None))
            if svc is None:
                cand = {x for x in by_fp.get(tree["fp"].get(b), ()) if x[2]}
                if len({c[0] for c in cand}) > 1:
                    cand = {c for c in cand if c[0] == w}
                if len({c[0] for c in cand}) == 1:
                    svc, how = next(iter(cand))[0], "942 " + next(iter(cand))[1]
            if svc is None and w in HAND:
                svc, how = w, "by hand: " + HAND[w]
            rows.append((w, b, svc, how))
    for r, fp in sorted(tree["fp"].items()):
        if r in seen or r in tree["wrappers"]:
            continue
        cand = {x for x in by_fp.get(fp, ()) if not x[2]}
        if r in code_of and not any(r in v["wrappers"] for v in vs):
            svc, how = code_of[r]
            if not any(v["routine"] == r and v["wrappers"] for v in vs):
                rows.append((None, r, svc, how))
        elif len(cand) == 1 and len(fp) > 8:
            c = next(iter(cand))
            rows.append((None, r, c[0], "942 " + c[1]))
    return rows


def fmt_err(e, errs):
    if isinstance(e, int):
        return f"{e} {errs.get(e, '?')}"
    return f"{e} (register)" if e is not None else "-"


def table(rows):
    """Space-padded columns."""
    w = [max(len(r[i]) for r in rows) for i in range(len(rows[0]))]
    return "\n".join("  ".join(c.ljust(w[i]) for i, c in enumerate(r)).rstrip() for r in rows)


def selftest(results, defined, root):
    fails = 0
    by_name = {v: c for c, v in defined.items()}
    for n, c in sorted(ANCHORS_942.items(), key=lambda x: x[1]):
        if by_name.get(n) != c:
            print(f"FAIL spec: {n} is {by_name.get(n)}, program 942 says {c}")
            fails += 1
    if "942" not in results:
        t = scan_tree(TREES["942"][1], root)
        results["942"] = (TREES["942"][0], t, verdicts(t, defined))
    _, t942, vs942 = results["942"]
    for n, c in sorted(ANCHORS_942.items(), key=lambda x: x[1]):
        seen = [v["routine"] for v in vs942
                if c in v["d0"] and (v["routine"] == n or any(x == n for x, _ in v["callers"]))]
        if not seen:
            print(f"FAIL 942: neither the export {n} nor a routine it calls reports {c}")
            fails += 1
        else:
            print(f"ok   942: export {n} = {c} (H'{c & 0xffff:04x}): reported by {', '.join(seen)}")
    callees = collections.defaultdict(set)
    for callee, cs in t942["callers"].items():
        for c, mn in cs:
            callees[c].add(callee)
    for fwd, (c, poll) in sorted(FORWARDERS_942.items()):
        bodies = [v for v in vs942 if c in v["d0"] and v["polling"] == poll]
        hit = [v["routine"] for v in bodies if set(v["wrappers"]) & callees.get(fwd, set())]
        if len(hit) != 1:
            print(f"FAIL 942: {fwd} calls {sorted(callees.get(fwd, ()))}, not the wrapper of the "
                  f"{'polling ' if poll else ''}routine reporting {c}")
            fails += 1
        else:
            print(f"ok   942: forwarder {fwd} calls the wrapper of {hit[0]} ({c}{', polling' if poll else ''})")
    for v in vs942:
        if v["d0"] == [-53] and v["polling"] and "preq_sem" not in v["wrappers"]:
            print(f"FAIL 942: the polling -53 body {v['routine']} is not called by the export preq_sem")
            fails += 1
    for k, (title, t, vs) in results.items():
        bad = 0
        for v in vs:
            if not v["d0"] or len(v["d0"]) != 1 or v["d0"][0] not in defined:
                print(f"FAIL {k}: {v['routine']} reports d0 {sorted(v['d0'], key=str)}: not one defined function code")
                bad += 1
            if v["verdict"] == "MISMATCH":
                print(f"FAIL {k}: {v['routine']} (wrappers {v['wrappers']}) reports {v['d0']}: wants "
                      f"{v['want']}" + (f" behind the wrapper {v['want_wrapper']}" if v["want_wrapper"] else ""))
                bad += 1
        fails += bad
        if not bad:
            print(f"ok   {k}: {len(vs)} reporting routines, each one defined uITRON 3.0 function code, no label disagrees")
    print("selftest:", "PASS" if not fails else f"FAIL ({fails})")
    return fails


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("trees", nargs="*", help="tree keys (default: all): " + " ".join(TREES))
    ap.add_argument("--root", default=".")
    ap.add_argument("--spec", default=SPEC)
    ap.add_argument("--selftest", action="store_true")
    ap.add_argument("--codes", action="store_true")
    ap.add_argument("--placeholders", action="store_true",
                    help="count the func_<ADDR> routine labels of each tree")
    ap.add_argument("--rows", action="store_true", help="print symbol-file rows for the names the services "
                    "table asks for (the routine's address from its func_<ADDR> label)")
    ap.add_argument("--sed", metavar="DIR", help="write DIR/<tree>.sed: one rule per label the services "
                    "table wants changed (the label and every label derived from it)")
    a = ap.parse_args()
    spec = read_spec(a.spec)
    codes, notes = parse_function_codes(spec)
    errs = parse_error_codes(spec)
    defined = {c: v[0] for c, v in codes.items() if v[0] and not v[1]}
    keys = a.trees or list(TREES)
    results = collections.OrderedDict()
    for k in keys:
        title, globs = TREES[k]
        t = scan_tree(globs, a.root)
        results[k] = (title, t, verdicts(t, defined))

    if a.codes:
        print(f"spec: {len(defined)} defined function codes, {len(errs)} error codes")
        for n in notes:
            print("  note:", n)
        used = sorted({c for _, _, vs in results.values() for v in vs for c in v["d0"]})
        for c in used:
            print(f"  {c:5d}  H'{c & 0xffff:04x}  {defined.get(c, '(undefined)')}")
        return

    if a.placeholders:
        for k, (title, t, vs) in results.items():
            print(f"{k:7s} {sum(1 for r in t['routines'] if re.match(r'^func_[0-9A-F]{8}$', r)):6d} func_ routines")
        return

    if a.selftest:
        sys.exit(1 if selftest(results, defined, a.root) else 0)

    if a.rows:
        t942 = results["942"][1] if "942" in results else scan_tree(TREES["942"][1], a.root)
        n942 = names_942(t942, a.root)
        cite = "(uITRON 3.0 sect. 6.3; notes/uitron3-function-codes)"
        for k, (title, t, vs) in results.items():
            info = {v["routine"]: v for v in vs}
            print(f"; ---- {k}: {title}")
            for w, b, svc, how in services(t, vs, t942, n942):
                if not svc:
                    continue
                v = info.get(b)
                if v:
                    c = v["d0"][0]
                    d1 = " / ".join(errs.get(e, "?") if isinstance(e, int) else "the poll's result"
                                    if v["polling"] else "the error its core returns" for e in sorted(v["d1"], key=str))
                    ev = (f"{'/'.join(v['hooks'])} d0 = {c} (H'{c & 0xffff:04x}"
                          + (f", {v['spec']}'s code: the polling variant" if v["polling"] else f", {svc}")
                          + f"), d1 = {d1} {cite}")
                elif how.startswith("942 "):
                    src = how[4:]
                    ev = ("program 942's " + ("export table names the wrapper" if src == "export table"
                                              else f"exported {src.split()[-1]} calls " + ("the wrapper" if w else "it"))
                          + ("" if k == "942" else ", carried here by an identical body"))
                else:
                    ev = how
                for old, new, role in ((w, svc, "wrapper"), (b, svc + "_Impl" if w else svc, "body")):
                    if not old or old == new or not re.match(r"^func_[0-9A-F]{8}$", old):
                        continue
                    if role == "wrapper":
                        note = f"uITRON {svc}: the service-call wrapper (context save, kernel stack, call {svc}_Impl); {ev}"
                    elif w:
                        note = f"{svc}'s body, behind the wrapper {svc}; {ev}"
                    else:
                        note = f"uITRON {svc}, called directly (no wrapper); {ev}"
                    print(f"0x{old[5:]}  {new:<23} ; {note}")
        return

    if a.sed:
        t942 = results["942"][1] if "942" in results else scan_tree(TREES["942"][1], a.root)
        n942 = names_942(t942, a.root)
        os.makedirs(a.sed, exist_ok=True)
        for k, (title, t, vs) in results.items():
            rules = []
            for w, b, svc, how in services(t, vs, t942, n942):
                if not svc:
                    continue
                for old, new in ((w, svc), (b, svc + "_Impl" if w else svc)):
                    if old and old != new:
                        # also inside labels made from it (func_X_entry_L3d, REC_func_X_ArgA0)
                        rules.append(f"s/{old}\\([^0-9A-Za-z]\\|$\\)/{new}\\1/g")
            with open(os.path.join(a.sed, f"{k}.sed"), "w") as fh:
                fh.write(f"# {title}: kernel service names (kn7000/notes/uitron3-function-codes/function_codes.py --sed)\n")
                fh.write("".join(r + "\n" for r in rules))
            print(f"{k}: {len(rules)} rules")
        return

    for k, (title, t, vs) in results.items():
        cnt = collections.Counter(v["verdict"] for v in vs)
        print(f"== {k}: {title}: {len(vs)} routines report errors through KernelErrorHook*"
              + (": " + ", ".join(f"{n} {cnt[n]}" for n in ("ok", "rename", "MISMATCH", "UNDECODED") if cnt[n])
                 if vs else ""))
        if not vs:
            print()
            continue
        rows = [("verdict", "d0", "code", "service", "d1", "routine", "wants", "wrapper", "wants", "other callers")]
        for v in vs:
            d0 = ", ".join(f"{c}" for c in v["d0"])
            code = ", ".join(f"H'{c & 0xffff:04x}" for c in v["d0"])
            d1 = "; ".join(fmt_err(e, errs) for e in sorted(v["d1"], key=str))
            other = sorted({c for c, mn in v["callers"] if c not in v["wrappers"]})
            rows.append((v["verdict"], d0, code,
                         (v["service"] or "?") + (f" (reports {v['spec']}'s code)" if v["polling"] else ""), d1,
                         v["routine"], "=" if v["want"] == v["routine"] else str(v["want"]),
                         ", ".join(v["wrappers"]) or "-",
                         "-" if not v["wrappers"] else "=" if all(w == v["want_wrapper"] for w in v["wrappers"])
                         else str(v["want_wrapper"]),
                         (", ".join(other[:4]) + (f" +{len(other) - 4}" if len(other) > 4 else "")) or "-"))
        print(table(rows))
        print()
    t942 = results["942"][1] if "942" in results else scan_tree(TREES["942"][1], a.root)
    n942 = names_942(t942, a.root)
    print("== The kernel's services: every service-call wrapper (the trap stub a task calls) with its body,")
    print("   and the bodies a task calls directly; the name the evidence asks for: the function code above,")
    print("   else program 942's names (export table / exported forwarder <svc>_X) carried by an identical body")
    for k, (title, t, vs) in results.items():
        sv = services(t, vs, t942, n942)
        if not sv:
            continue
        rows = [("wrapper", "wants", "body", "wants", "evidence")]
        todo = 0
        for w, b, svc, how in sv:
            ww = "-" if w is None else "=" if svc and w == svc else (svc or "?")
            bw = (svc + "_Impl" if w else svc) if svc else "?"
            bw = "=" if bw == b else bw
            todo += (ww not in ("-", "=")) + (bw != "=")
            rows.append((w or "-", ww, b, bw, how or "none: named by hand, or not named"))
        print(f"-- {k}: {len(sv)} services, {todo} labels to change")
        print(table(rows))
        print()


if __name__ == "__main__":
    main()
