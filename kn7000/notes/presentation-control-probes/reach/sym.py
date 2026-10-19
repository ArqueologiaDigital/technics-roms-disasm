import re, bisect, sys
SYMS = []
for f in ('kn7000.sym', 'kn7000_manual.sym', 'kn7000_exports_from_942.sym'):
    for l in open('/home/fsanches/compartilhado/technics-roms-disasm/kn7000/' + f):
        m = re.match(r'^0x([0-9A-Fa-f]+)\s+(\S+)', l)
        if m: SYMS.append((int(m.group(1), 16), m.group(2)))
SYMS.sort()
ADDRS = [a for a, _ in SYMS]
def near(a):
    i = bisect.bisect_right(ADDRS, a) - 1
    return '%s+0x%x' % (SYMS[i][1], a - SYMS[i][0]) if i >= 0 else '?'
if __name__ == '__main__':
    for x in sys.argv[1:]:
        print(x, near(int(x, 16)))
