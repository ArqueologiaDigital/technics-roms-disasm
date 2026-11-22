#!/usr/bin/env python3
"""sub_screen.py OUT_PREFIX [MIN_MEMBERS]: which untried sub-CPU routines look compiled, and which are look-alikes?

QUESTION ANSWERED / WHY: lane_p6's new_pool.py / families.py / xr_screen.py (notes/cc900-phase6-2026-11-16/) found
main-CPU candidates its earlier pools missed; this is the same three steps for the v1.42 sub-CPU payload.
1. Pool: every routine of survey.tsv (call targets after a flow end, v142 addresses) that no C defines yet --
   not v142/subcpu/cc900/*.c, not cc900-staged/*.c, not any probe scripts/analysis/cc900/corpus/firmware/sub_*.c
   (tried before, by anyone; `cc900-name:` short names mapped) -- and that is not hand assembly (survey's `hand`
   column), not Toshiba's double library (subcpu_fp_math.s) and not an inner label of a built function (its label
   line no longer in the hand source).  Unlike pools.py, routines with memory-to-memory moves are kept.
2. Screen (xr_screen.py's metrics on the hand source, label to the next survey routine): push (XIZ / IZ saved in the
   first 4 instructions), frame, spill / reld / sr (parameter spills and reloads), hand (ei / di / ldc / swi / reti /
   link / unlk / djnz / xor r,r).  Bank-register forms are NOT hand marks here: V4.23 writes them on this payload
   (README, "The survey"); `lda xR,(constant)` is reported (ldac) but not used against a routine, because the
   payload's -Xr code has them (Audio_Process_DSP's `lda xwa,(17256:16)`).  Family: (push or frame) and
   (sr >= 1 or reld >= 2) and hand == 0.
3. Families (families.py): the shape of each screened routine in the built v142 ELF (mnemonics, registers kept,
   numbers N); routines with the same shape, largest first (members x bytes).
Writes OUT_PREFIX.pool (bytes address routine group hand_source), OUT_PREFIX.screen (screened, largest first),
OUT_PREFIX.screen.all (every pool row with its metrics) and OUT_PREFIX.families; prints the counts.

    python3 -B notes/cc900-c-subcpu-2026-11-16/sub_screen.py notes/cc900-c-subcpu-2026-11-16/screen/sub_2026-11-22 2
    (from the repository root; needs the built rebuilt_ROMs/kn5000_subprogram_v142.llvm.elf)
"""
import collections
import glob
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'build'))
import cc900_firmware_c as fw                                # noqa: E402

TREE = os.path.join(REPO, 'v142', 'subcpu')
FUNC = re.compile(r'^[\w][\w\s\*]*?\b(\w+)\s*\([^;{)]*\)\s*\{', re.M)
HAND = [r'\bei\b|\bdi\b', r'\bldc\b', r'\bswi\b', r'\breti\b', r'\blink\b|\bunlk\b', r'\bdjnz\b',
        r'\bxor\s+(\w+),\s*\1\b']
LABEL = re.compile(r'^([A-Za-z_.]\w*):')
STORE = re.compile(r'^\s*ld\s+\(xsp\s*\+\s*(\d+)\)\s*,\s*(\w+)\s*$')
LOAD = re.compile(r'^\s*ld\s+(\w+)\s*,\s*\(xsp\s*\+\s*(\d+)\)\s*$')
PARAM = {'xwa', 'xbc', 'xde', 'wa', 'bc', 'de', 'a', 'c', 'e'}
OBJ = re.compile(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*\t(\S+)\s*(.*)$')


def defined(paths):
    out = set()
    for p in paths:
        t = open(p, encoding='latin-1').read()
        names = dict(re.findall(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', t))
        out |= {names.get(n, n) for n in FUNC.findall(t)}
    return out


def metrics(body):
    head = body[:4]
    push = any(re.match(r'push\w*\s+(xiz|iz)\b', x) for x in head)
    frame = any(re.match(r'(lda\s+xsp\s*,\s*\(xsp\s*-|dec\s+\d+\s*,\s*xsp)', x) for x in head)
    slots = {m.group(1) for x in body[:8] for m in [STORE.match(x)] if m and m.group(2) in PARAM}
    reld = sum(1 for x in body[8:] for m in [LOAD.match(x)] if m and m.group(2) in slots)
    sr = sum(1 for a, b in zip(body, body[1:]) for m, n in [(STORE.match(a), LOAD.match(b))]
             if m and n and m.group(1) == n.group(2))
    ldac = sum(1 for x in body if re.match(r'lda\s+x\w+\s*,\s*\((?!\s*x(wa|bc|de|hl|ix|iy|iz|sp)\b)', x))
    hand = sum(1 for x in body for rx in HAND if re.search(rx, x))
    return push, frame, len(slots), reld, sr, ldac, hand


def norm(ops):
    return re.sub(r'\s+', '', re.sub(r'0x[0-9a-f]+|\b\d+\b', 'N', ops))


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    prefix, mn = sys.argv[1], int(sys.argv[2]) if len(sys.argv) > 2 else 2
    os.makedirs(os.path.dirname(os.path.abspath(prefix)), exist_ok=True)
    rows = [l.rstrip('\n').split('\t') for l in open(os.path.join(HERE, 'survey.tsv'))][1:]
    done = defined(glob.glob(TREE + '/cc900/*.c') + glob.glob(TREE + '/cc900-staged/*.c')
                   + glob.glob(os.path.join(REPO, 'scripts/analysis/cc900/corpus/firmware/sub_*.c')))
    routines = {r[3] for r in rows}
    texts = {}
    pool = []
    for r in rows:
        addr, size, name, f, cls = int(r[0], 16), r[1], r[3], r[4], r[5]
        if size == 'None' or cls == 'hand' or f == 'subcpu_fp_math.s' or name in done:
            continue
        if f not in texts:
            texts[f] = open(os.path.join(TREE, f), 'rb').read().decode('latin-1').split('\n')
        L = texts[f]
        s = next((i for i, l in enumerate(L) if l.startswith(name + ':') and '.include' not in l), None)
        if s is None:
            continue                                           # built (spliced) or an inner label of a built body
        body = []
        for l in L[s + 1:]:
            m = LABEL.match(l)
            if m and m.group(1) in routines:
                break
            c = l.split(';', 1)[0]
            if m:
                c = c[len(m.group(0)):]
            if c.strip():
                body.append(c.strip())
        pool.append((int(size), addr, name, r[15] if len(r) > 15 else '-', f, body))
    pool.sort(key=lambda x: -x[0])
    with open(prefix + '.pool', 'w') as fh:
        for n, a, name, g, f, _ in pool:
            fh.write('%5d %06x %-44s %-4s %s\n' % (n, a, name, g, f))
    scr = []
    with open(prefix + '.screen.all', 'w') as fh:
        for n, a, name, g, f, body in pool:
            push, frame, spill, reld, sr, ldac, hand = metrics(body)
            fam = (push or frame) and (sr >= 1 or reld >= 2) and hand == 0
            fh.write('%d %5d %06x %-44s %-40s push=%d frame=%d spill=%d reld=%d sr=%d ldac=%d hand=%d n=%d\n'
                     % (fam, n, a, name, f, push, frame, spill, reld, sr, ldac, hand, len(body)))
            if fam:
                scr.append((n, a, name, f))
    with open(prefix + '.screen', 'w') as fh:
        fh.write('# sub_screen.py: %d of %d untried routines show the unoptimised -Xr shape, %d B\n'
                 % (len(scr), len(pool), sum(x[0] for x in scr)))
        for n, a, name, f in scr:
            fh.write('%5d %06x %-44s %s\n' % (n, a, name, f))
    elf = os.path.join(REPO, 'rebuilt_ROMs', 'kn5000_subprogram_v142.llvm.elf')
    out = subprocess.run([os.path.join(fw.LLVM_BIN, 'llvm-objdump'), '-d', elf], capture_output=True, text=True,
                         check=True).stdout
    ins = {}
    for l in out.splitlines():
        m = OBJ.match(l)
        if m:
            ins[int(m.group(1), 16)] = (len(m.group(2).split()), m.group(3), norm(m.group(4)))
    fam = collections.defaultdict(list)
    for n, a, name, f in scr:
        shape, at = [], a
        while at < a + n and at in ins:
            k, mnem, ops = ins[at]
            shape.append(mnem + ' ' + ops)
            at += k
        if at == a + n and shape:
            fam[tuple(shape)].append((name, n, f))
    big = sorted((v for v in fam.values() if len(v) >= mn), key=lambda v: -len(v) * v[0][1])
    with open(prefix + '.families', 'w') as fh:
        for v in big:
            fh.write('%3d members x %4d B  %s\n' % (len(v), v[0][1], ' '.join(x[0] for x in v)))
    print('pool %d routines, %d B; screen %d routines, %d B; %d families of >= %d members'
          % (len(pool), sum(x[0] for x in pool), len(scr), sum(x[0] for x in scr), len(big), mn))


if __name__ == '__main__':
    main()
