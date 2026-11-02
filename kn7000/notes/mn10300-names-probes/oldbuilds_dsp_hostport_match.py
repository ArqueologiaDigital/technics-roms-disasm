#!/usr/bin/env python3
"""oldbuilds_dsp_hostport_match.py -- which routines of program builds 935 / 893 are
941's DSP host-port routines (DspFullReinit, DspWritePMWord, DspWriteDMWord, DspRegWrite
and their unnamed helpers)?

Question: 941 rewrote and moved the DSP boot / host-port code at the front of code
region 1 (941 0x48404D10..0x4840557E); the offset map gives it no 1:1 place in 935 / 893
and tools/port_names_by_code.py carries only DspBootDefaultEffects and DspBootProbe.
This probe decodes 941's block and the 935 / 893 block that holds those two
(0x4840AE62..0x4840B696), splits both at their function starts (every `call`/`calls`
target in code region 1, as gen_program_s.discover_functions does), pairs the
functions IN ORDER and compares their instruction streams with every absolute
address and every branch/call target masked (relocation-masked, like
port_names_by_code.signature but over the WHOLE function, not entry to first return).

Output: one row per pair: 941 start, build start (the prologue when the function has
one, i.e. the address gen_program_s.py labels func_<ADDR>), instruction counts, the number of
instructions that differ after masking, and the 941 name.  "same" = identical masked
stream.  It also prints the 941 entry address of each named routine and the build
address it pairs with (the name goes on the build's entry, 3 bytes past the
`add -N, sp` prologue, as in 941).

Measured 2026-11-02 at c240d1c0b: 35 functions on each side, in the same order; 30 pairs
identical after masking; the 5 that differ are DspPortRead / DspPortWrite (941 sets the bus
control word 0x32000026 to 0x924 around the data-port access), DspPortWriteChecked /
DspPortWriteSlow (a callee's frame size) and DspDebugPrintHex16 (941's dead `nop; ret`).
b935 prints the same table (the block is at the same addresses in 935 and 893).

Run (from kn7000/, read-only on the baseroms):
    UNIDASM=/home/fsanches/compartilhado/mame-sony-video/unidasm \
        python3 -I notes/mn10300-names-probes/oldbuilds_dsp_hostport_match.py [b893|b935]
"""
import os, re, subprocess, sys

UNIDASM = os.environ.get("UNIDASM", "/home/fsanches/compartilhado/mame-sony-video/unidasm")
BASE = 0x48400000
ROMS = {"941": "baserom/kn7000_program.rom", "b935": "baserom/kn7000_program_b935.rom",
        "b893": "baserom/kn7000_program_b893.rom"}
R1_END = {"941": 0x186000, "b935": 0x18595C, "b893": 0x1846A0}
BLOCK = {"941": (0x48404D10, 0x4840557E), "b935": (0x4840AE62, 0x4840B696),
         "b893": (0x4840AE62, 0x4840B696)}
NAMES941 = {}           # 941 entry -> name, from the committed 941 symbol files
INSN = re.compile(r"([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s+(\S+)\s*(.*)$")


def decode(rom, lo, hi):
    """linear decode [lo, hi) CPU; the F4 page is 2 bytes (unidasm length bug)."""
    d = open(rom, "rb").read()
    out, cur = [], lo
    while cur < hi:
        txt = subprocess.run([UNIDASM, rom, "-arch", "mn10300", "-basepc", f"0x{cur:x}",
                              "-skip", f"0x{cur - BASE:x}", "-count", str(hi - cur)],
                             capture_output=True, text=True).stdout
        restart = False
        for line in txt.splitlines():
            m = INSN.match(line)
            if not m:
                continue
            a = int(m.group(1), 16)
            by = bytes.fromhex(m.group(2).replace(" ", ""))
            if by == b"\xf4":
                out.append((a, d[a - BASE:a - BASE + 2], m.group(3), m.group(4).strip()))
                cur = a + 2
                restart = True
                break
            out.append((a, by, m.group(3), m.group(4).strip()))
            cur = a + len(by)
            if cur >= hi:
                break
        if not restart:
            break
    return out


def call_targets(key):
    txt = subprocess.run([UNIDASM, ROMS[key], "-arch", "mn10300", "-basepc", f"0x{BASE + 0x80:x}",
                          "-skip", "0x80", "-count", str(R1_END[key] - 0x80)],
                         capture_output=True, text=True).stdout
    t = set()
    for line in txt.splitlines():
        m = re.match(r"[0-9a-f]+:\s+(?:[0-9a-f]{2} )+\s+calls?\s+0x([0-9a-f]+)", line)
        if m:
            t.add(int(m.group(1), 16))
    return t


def mask(mn, ops):
    ops = re.sub(r"0x[0-9a-f]{6,8}", "ADDR", ops)       # absolute addresses, targets
    return f"{mn} {ops}"


def split(insns, starts):
    """functions at the call targets; a `movm`/`add -N, sp` prologue just before a
    call target (the target is then its register-save entry) starts the function,
    and so does such a prologue straight after a return."""
    pro = set()
    for i, (a, by, mn, ops) in enumerate(insns):
        if a in starts:
            j = i
            while j > 0 and (insns[j - 1][2] == "movm" and ops != "" and insns[j - 1][3].endswith("(sp)")
                             or insns[j - 1][2] == "add" and re.fullmatch(r"-\S+, sp", insns[j - 1][3])):
                j -= 1
            pro.add(insns[j][0])
        # a prologue straight after a return starts a function too (one that is
        # reached only through a pointer, or never: 941's 0x48404DB4, 0x4840516F)
        if i and insns[i - 1][2] in ("ret", "retf", "rets", "rti") and (
                mn == "movm" or mn == "add" and re.fullmatch(r"-\S+, sp", ops)):
            pro.add(a)
    fns, cur = [], None
    for a, by, mn, ops in insns:
        if a in pro or cur is None:
            cur = [a, []]
            fns.append(cur)
        cur[1].append(mask(mn, ops))
    return fns


def main():
    key = sys.argv[1] if len(sys.argv) > 1 else "b893"
    for path in ("kn7000.sym", "kn7000_manual.sym"):
        for line in open(path):
            m = re.match(r"0x([0-9A-Fa-f]{8})\s+(\S+)", line)
            if m and not line.lstrip().startswith(";"):
                NAMES941.setdefault(int(m.group(1), 16), m.group(2))
    A = split(decode(ROMS["941"], *BLOCK["941"]), call_targets("941"))
    B = split(decode(ROMS[key], *BLOCK[key]), call_targets(key))
    print(f"941 block {BLOCK['941'][0]:#x}..{BLOCK['941'][1]:#x}: {len(A)} functions; "
          f"{key} block {BLOCK[key][0]:#x}..{BLOCK[key][1]:#x}: {len(B)} functions")
    same = 0
    for (a, ia), (b, ib) in zip(A, B):
        nd = sum(x != y for x, y in zip(ia, ib)) + abs(len(ia) - len(ib))
        same += nd == 0
        # a 941 name sits on the entry 3 bytes in when the function starts with `add -N, sp`
        k = next((k for k in range(0, 5) if a + k in NAMES941), None)
        nm = NAMES941[a + k] if k is not None else ""
        ent = a + (k or 0)
        print(f"941 {a:#010x}  {key} {b:#010x}  insns {len(ia):3d}/{len(ib):3d}  "
              f"{'same' if nd == 0 else f'{nd} differ':>9}  {nm}"
              + (f"  -> {key} entry {b + (ent - a):#010x}" if nm else ""))
        if nd and "-v" in sys.argv:
            for x, y in zip(ia, ib):
                if x != y:
                    print(f"      941: {x:<40} {key}: {y}")
    print(f"{same} of {min(len(A), len(B))} pairs identical after masking")


main()
