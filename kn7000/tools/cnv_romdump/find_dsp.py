#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# find_dsp.py [--unidasm PATH] -- does the DSP probe's run-time search (romdump_dsp.s DspFind) find the
# firmware's effects-DSP host-port routines in every KN7000 program build we have, and are they the same code?
# The same steps as DspFind, in Python:
#   * sig_dspwait (the handshake wait, 941 0x48404D25) must match once; its operands give the "kernel downloaded"
#     flag (+0x0F) and the "DSP dead" flag (+0x36);
#   * sig_dspregs (2x16 register write, its bus-timing twin, 2x16 read, its twin; 941 0x484052DD) must match once:
#     the write is at +0, the read at +0x3E;
#   * the read's call at body + 6 leads to the index write, the one at body + 0xE to the guarded data read; each
#     target must be preceded by "add -frame, sp" (f8 fe -frame) for the frame its call allocates, and the data
#     read must test the same dead flag ("movbu (dead), d0").
# Then, with unidasm (MAME's universal disassembler), it lists each found routine and every routine it calls,
# with addresses, call targets and RAM operands made symbolic, and compares that with program 941's: "same
# code", or the lines that differ. (Program 893's data-port accessors lack 941's bus-timing bracket around the
# port access -- save 0x32000026, write 0x924, restore -- and use a smaller frame; the logic is the same.)
#   python3 -I find_dsp.py                    # the images under ~/compartilhado/technics_romsets and baserom
import os
import re
import subprocess
import sys
import tempfile
import zipfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import find_fw  # noqa: E402

R = os.path.expanduser('~/compartilhado/technics_romsets')
BR = os.path.expanduser('~/compartilhado/technics-roms-disasm/kn7000/baserom')
UNIDASM = os.path.expanduser('~/compartilhado/kn7000_mame_build/unidasm')
BASE = 0x48400000


def asm_sig(name):
    """a signature as romdump_dsp.s carries it (.word lines, 0x100 = any byte, 0xFFFF = end)"""
    src = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'romdump_dsp.s')).read()
    body = src[src.index(name + ':'):]
    out = []
    for line in body.split('\n')[1:]:
        m = re.match(r'\s+\.word\s+(.*)', line)
        if not m:
            break
        for t in m.group(1).split(','):
            v = int(t.strip(), 0)
            if v == 0xFFFF:
                return out
            out.append(None if v == 0x100 else v)
    return out


def u32(img, o):
    return int.from_bytes(img[o:o + 4], 'little')


def call_target(img, a):
    o = a - BASE
    if img[o] != 0xCD:
        return None, None
    d = img[o + 1] | img[o + 2] << 8
    return a + (d - 0x10000 if d & 0x8000 else d), img[o + 4]


def entry(img, body, frame):
    p = img[body - 3 - BASE:body - BASE]
    return body - 3 if p[:2] == b'\xf8\xfe' and (p[2] + frame) & 0xFF == 0 else None


def find(img):
    """what DspFind finds: dict, or the reason it gives up"""
    w = find_fw.find(img, asm_sig('sig_dspwait'))
    r = find_fw.find(img, asm_sig('sig_dspregs'))
    if len(w) != 1 or len(r) != 1:
        return f'sig_dspwait {len(w)} hit(s), sig_dspregs {len(r)} hit(s)'
    f = {'wait': BASE + w[0], 'downloaded': u32(img, w[0] + 0x0F), 'dead': u32(img, w[0] + 0x36),
         'regwr': BASE + r[0], 'regrd': BASE + r[0] + 0x3E}
    t, fr = call_target(img, f['regrd'] + 9)
    f['idxwr'] = t and entry(img, t, fr)
    t, fr = call_target(img, f['regrd'] + 0x11)
    f['datard'] = t and entry(img, t, fr)
    ok = f['idxwr'] and f['datard'] and img[t - BASE:t - BASE + 2] == b'\xfc\xa8' and u32(img, t - BASE + 2) == f['dead']
    f['ok'] = bool(ok)
    return f


def disasm(img, start, n=0xA0):
    """unidasm listing of [start, start + n), up to the first ret"""
    with tempfile.NamedTemporaryFile(suffix='.bin') as t:
        t.write(img); t.flush()
        out = subprocess.run([UNIDASM, t.name, '-arch', 'mn10300', '-basepc', hex(start), '-skip', str(start - BASE),
                              '-count', str(n)], capture_output=True, text=True).stdout
    lines = []
    for ln in out.splitlines():
        m = re.match(r'([0-9a-f]+): (?:[0-9a-f]{2} )+\s+(.*)', ln)
        if not m:
            continue
        lines.append((int(m.group(1), 16), m.group(2).strip()))
        if m.group(2).startswith(('ret ', 'rets', 'retf')):
            break
    return lines


def tree(img, f, start, seen=None, depth=0):
    """the routine at start and the routines it calls inside the program flash (not the library), recursively"""
    seen = {} if seen is None else seen
    if start in seen or depth > 4:
        return seen
    lines = disasm(img, start)
    seen[start] = lines
    for _, ins in lines:
        m = re.match(r'call\s+0x(48[0-9a-f]{6})', ins)
        if m:
            tree(img, f, int(m.group(1), 16), seen, depth + 1)
    return seen


def normalise(lines, names):
    out = []
    for _, ins in lines:
        ins = re.sub(r'0x(48[0-9a-f]{6})', lambda m: names.get(int(m.group(1), 16), 'FW'), ins)
        ins = re.sub(r'0x4c[0-9a-f]{6}', 'LIB', ins)
        ins = re.sub(r'0x5000[0-9a-f]{4}', lambda m: names.get(int(m.group(0), 16), 'RAM'), ins)
        ins = re.sub(r'\((?:0x)?[0-9a-f]+, sp\)', '(S, sp)', ins)              # stack slots move with the frame
        ins = re.sub(r'^(call\s+\S+, \S+|ret\s+\S+), (?:0x)?[0-9a-f]+$', r'\1, FRAME', ins)
        ins = re.sub(r'^add\s+-(?:0x)?[0-9a-f]+, sp$', 'add -FRAME, sp', ins)
        out.append(ins)
    return out


def compare(ref_img, ref, img, f):
    """the routines DspFind found in img and their callees against 941's, in call order"""
    def walk(i, fd):
        names = {fd['dead']: 'DEAD', fd['downloaded']: 'DOWNLOADED'}
        order = []
        for root in ('regrd', 'regwr', 'idxwr', 'datard'):
            body = fd[root] + 3
            names[body] = root.upper()
            t = tree(i, fd, body)
            for a in t:
                if a not in order:
                    order.append(a)
        for k, a in enumerate(order):
            names.setdefault(a, f'F{k}')
        return order, {a: normalise(tree(i, fd, a)[a], names) for a in order}, names
    ro, rl, rn = walk(ref_img, ref)
    to, tl, tn = walk(img, f)
    import difflib
    rows = []
    for k, (ra, ta) in enumerate(zip(ro, to)):
        a, b = rl[ra], tl[ta]
        d = [x for x in difflib.ndiff(a, b) if x[:1] in '-+']
        verdict = 'same code (stack slots and frame sizes aside)' if not d else f'{len(d)} line(s) only in one'
        rows.append((rn[ra], f'{ra:#x}', f'{ta:#x}', verdict, d))
    return rows, len(ro) == len(to)


def images():
    z = zipfile.ZipFile(f'{R}/kn7000.zip')
    out = {'941': find_fw.interleave(z.read('kn7000_program_even.ic17'), z.read('kn7000_program_odd.ic16'))}
    out['942'] = open(f'{BR}/kn7000_program_sp7001.rom', 'rb').read()
    for k, e, o in (('935', 'kn7000_program_even_v1.5_b935.ic17', 'kn7000_program_odd_v1.5_b935.ic16'),
                    ('893', 'kn7000_program_even_v1.3_b893.ic17', 'kn7000_program_odd_v1.3_b893.ic16')):
        out[k] = find_fw.interleave(open(f'{R}/kn7000/{e}', 'rb').read(), open(f'{R}/kn7000/{o}', 'rb').read())
    out['929 (upper half only)'] = bytes(0x200000) + find_fw.interleave(
        open(f'{R}/kn7000/kn7000_program_even_v1.4_b929_upper.ic17', 'rb').read(),
        open(f'{R}/kn7000/kn7000_program_odd_v1.4_b929_upper.ic16', 'rb').read())
    return out


if __name__ == '__main__':
    if '--unidasm' in sys.argv:
        UNIDASM = sys.argv[sys.argv.index('--unidasm') + 1]
    imgs = images()
    ref = find(imgs['941'])
    for k, img in imgs.items():
        f = find(img)
        print(f'== {k}')
        if isinstance(f, str):
            print(f'   not found: {f}')
            continue
        print('   ' + ', '.join(f'{n} {f[n]:#010x}' if isinstance(f[n], int) else f'{n} {f[n]}' for n in
                                 ('regrd', 'regwr', 'idxwr', 'datard', 'wait', 'dead', 'downloaded', 'ok')))
        if k != '941' and f['ok'] and os.path.exists(UNIDASM):
            rows, same_shape = compare(imgs['941'], ref, img, f)
            for name, ra, ta, verdict, diff in rows:
                print(f'   {name:8} 941 {ra} -> {ta}: {verdict}')
                for x in diff:
                    print(f'            {"only in 941:" if x[0] == "-" else "only here:  "} {x[2:]}')
            if not same_shape:
                print('   (the call trees differ in size)')
