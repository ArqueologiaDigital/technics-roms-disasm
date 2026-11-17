#!/usr/bin/env python3
"""Which sub-CPU near misses stop at one of the idioms the probes found (README "Idioms found by systematic probes")?

QUESTION ANSWERED: for every v1.42 function that no C of ours matches yet, take its best attempt (the largest first
difference in verdicts/*.tsv), rebuild our bytes from that listing and look at the bytes at the first difference:

    extend    ours has an extz / exts within 6 bytes that the ROM does not have        -> class (c): declare the
              callee's parameter plain char
    const     the ROM loads an immediate there that ours loads later                   -> class (b): the constant
              through a local
    reload    ours reads a stack slot there that it stored just before                 -> class (a): a second local
              that receives the value, the kept local assigned from it
    retcopy   the ROM copies a 32-bit register (ld XDE,XHL and the like) after a call  -> the XHL -> XDE probe
    -         none of these

Only bytes, offsets and names are printed, no line of the Toshiba listing.

    python3 -B notes/cc900-c-subcpu-2026-11-16/idiom_scan.py [--tsv OUT]     (repository root)
"""
import csv, glob, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import sub_v423 as S                                          # noqa: E402
import check_bytes                                            # noqa: E402

RUNS = os.path.expanduser('~/compartilhado/cc900-oracle/runs')


def matched():
    done = set()
    with open(os.path.join(HERE, 'staged_v423.tsv')) as fh:
        for r in csv.DictReader((x for x in fh if not x.startswith('#')), delimiter='\t'):
            if r.get('result') == 'MATCH':
                done.add(r['function'])
    return done


def best_attempts(done):
    best = {}
    for p in sorted(glob.glob(os.path.join(HERE, 'verdicts', '*-sub-*.tsv'))):
        run = os.path.basename(p).split('.')[0]
        with open(p) as fh:
            for r in csv.DictReader(fh, delimiter='\t'):
                fn, bd = r.get('function'), r.get('best_diff') or ''
                if not fn or fn in done or not bd.startswith('+'):
                    continue
                at, where = bd.split()[0], bd.split()[1]
                at = int(at[1:])
                if fn not in best or at > best[fn][0]:
                    best[fn] = (at, run, where)
    return best


def listing(run, where):
    stem, opt = where.split('@')
    for pat in ('out/v423/%s/sub/%s.asm', 'out/v423/%s/sub/v142/%s.asm'):
        p = os.path.join(RUNS, run, pat % (opt, stem))
        if os.path.exists(p):
            return p, stem
    return None, stem


def is_ext(b, i):
    return i + 1 < len(b) and (b[i] & 0xc8) == 0xc8 and b[i + 1] in (0x12, 0x13)


def has_ext(b, lo, hi):
    return any(is_ext(b, i) for i in range(lo, min(hi, len(b) - 1)))


def classify(ours, rom, at):
    if has_ext(ours, at, at + 6) and not has_ext(rom, at, at + 6):
        return 'extend'
    op = rom[at] if at < len(rom) else None
    if op is not None and (0x20 <= op <= 0x27 or 0x30 <= op <= 0x37 or 0x40 <= op <= 0x47):
        n = {2: 2, 3: 3, 4: 5}[op >> 4]
        ins = bytes(rom[at:at + n])
        if ins in bytes(ours[at + 1:at + 24]):
            return 'const'
    if at + 2 < len(ours) and ours[at] in (0x8f, 0x9f, 0xaf, 0xbf) and 0x20 <= ours[at + 2] <= 0x27:
        d = ours[at + 1]
        for j in range(max(0, at - 8), at):
            if ours[j] in (0x8f, 0x9f, 0xaf, 0xbf) and ours[j + 1] == d and 0x40 <= ours[j + 2] <= 0x67:
                return 'reload'
    for j in range(max(0, at - 4), at + 2):
        if j + 1 < len(rom) and 0xe8 <= rom[j] <= 0xef and 0x88 <= rom[j + 1] <= 0x8f and j >= 4 \
                and rom[j - 4] == 0x1d:
            return 'retcopy'
    return '-'


def main():
    a = sys.argv[1:]
    done = matched()
    ref = check_bytes.load_reference(os.path.join(S.REPO, 'symbols', 'subcpu_symbols_reference.txt'))
    romimg = open(os.path.join(S.REPO, 'original_ROMs', 'kn5000_subprogram_v142.rom'), 'rb').read()
    rows = []
    for fn, (at, run, where) in sorted(best_attempts(done).items()):
        lst, stem = listing(run, where)
        if lst is None or fn not in ref:
            continue
        S.KEEP_BYTES = {}
        c = S.find_c(stem)
        S.compare(lst, 'v142/subcpu', [c] if c else [])
        ours = S.KEEP_BYTES.get(fn)
        if ours is None:
            continue
        off = S.rom_offset(ref[fn])
        rom = romimg[off:off + max(len(ours), at + 32)]
        rows.append((fn, len(ours), at, classify(ours, rom, at), run, where))
    for r in sorted(rows, key=lambda r: (r[3], -r[1])):
        print('%-36s %5d B  +%-4d %-8s %s %s' % r)
    if '--tsv' in a:
        with open(a[a.index('--tsv') + 1], 'w') as fh:
            fh.write('function\tbytes\tfirst_diff\tidiom\trun\tattempt\n')
            for r in rows:
                fh.write('\t'.join(map(str, r)) + '\n')


if __name__ == '__main__':
    main()
