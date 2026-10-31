# Question: what are the bytes after 0x82 in a KN6000/KN7000 .SQT track's last cell?
# Usage: python3 sqt_tails.py <floppy dir>   (needs make -C floppy gate-kn6000 gate-kn7000 built first)
import glob, os, sys, collections
FL = sys.argv[1] if len(sys.argv) > 1 else '.'
sys.path.insert(0, os.path.join(FL, 'tools', 'kd'))
import kn_sqt
u16 = kn_sqt.u16

def chains(p1, p2):
    rl = kn_sqt.RECORD_LEN.get(p1[5:7]); n = len(p2) // 256; owner = {}; out = []
    for s in range(len(p1) // rl):
        for t in range(16):
            e = s * rl + 0xD0 + 3 * t
            fl, c = p1[e], u16(p1, e + 1)
            if not fl & 0x80 or c in (0, 0xFFFF):
                continue
            cells = []
            while 1 <= c <= n and c not in owner and c not in cells:
                cells.append(c); c = u16(p2, (c - 1) * 256 + 3)
            for cc in cells: owner[cc] = (s, t)
            out.append((s, t, cells))
    return out, owner

def parse_from(b):
    """events parse of a stale run: (#bytes consumed by whole events, stop reason)"""
    toks, why = kn_sqt.tokens(b)
    used = toks[-1][0] + toks[-1][1] if toks else 0
    return used, why, toks

def main():
    stats = collections.Counter()
    for p2f in sorted(glob.glob(os.path.join(FL, 'build', 'kn[67]000', '*', '*.sqt.p2.ref'))):
        p1 = open(p2f.replace('.p2.ref', '.p1.ref'), 'rb').read(); p2 = open(p2f, 'rb').read()
        ch, owner = chains(p1, p2)
        for s, t, cells in ch:
            stream = b''.join(p2[(c - 1) * 256 + 5:c * 256] for c in cells)
            toks, why = kn_sqt.tokens(stream)
            if why: continue
            end = toks[-1][0] + toks[-1][1]
            k = end // 251
            if k >= len(cells): continue
            c = cells[k]; lo = 251 * k
            rest = stream[end:251 * (k + 1)]
            if not rest or len(set(rest)) == 1: continue
            off = (c - 1) * 256 + 5 + end - lo
            # 1. copy of the same in-cell bytes of another cell?
            same = [cc for cc in range(1, len(p2) // 256 + 1) if cc != c and p2[(cc - 1) * 256 + 5 + end - lo:cc * 256] == rest]
            # 2. occurs elsewhere in the file?
            where = p2.find(rest); where2 = p2.find(rest, where + 1) if where == off else where
            # 3. parse as events from its first byte, after skipping k bytes (k = 0..7)
            best = None
            for sk in range(0, min(12, len(rest))):
                used, w, tk = parse_from(rest[sk:])
                if best is None or used > best[1]: best = (sk, used, w)
                if sk + used == len(rest) or (w and 'ends before' in w):
                    best = (sk, used, w); break
            tag = 'cellcopy' if same else ('elsewhere' if where2 not in (-1, off) else 'unique')
            stats[tag] += 1
            full = best[0] + best[1]
            stats['parse_to_end' if best[2] and ('ends before' in best[2] or 'tick at the end' in best[2]) else ('parse_82' if best[2] is None else 'parse_stop')] += 1
            print('%s s%d t%d cell %d +%d len %d: %s same=%s where=%s | skip %d events %d/%d %s' % (
                os.path.relpath(p2f, FL), s + 1, t + 1, c, end - lo, len(rest), tag, same[:4], where2, best[0], best[1], len(rest) - best[0], best[2]))
    print(stats)


if __name__ == '__main__':
    main()
