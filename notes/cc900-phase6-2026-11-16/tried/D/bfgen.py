#!/usr/bin/env python3
"""Scratch generator (lane_p6 helper D): reads a bitfield-copy routine's hand assembly (show.sh output) and writes
C guesses: struct types for the source and destination records and one `d->f = s->g;` per copied field.
usage: bfgen.py LABEL FILE.s [scc_form]   (prints C to stdout, problems to stderr)
scc_form: 'plain' (d->f = s->g) or 'ne' (d->f = s->g != 0) for 1-bit sources read with ldcf + scc."""
import re, subprocess, sys, os

label, src_file = sys.argv[1], sys.argv[2]
scc_form = sys.argv[3] if len(sys.argv) > 3 else 'plain'
show = os.path.expanduser('~/compartilhado/tmp/cc900-tab/lane_p6/scan/show.sh')
txt = subprocess.run(['bash', show, label, src_file, '2000'], capture_output=True, text=True,
                     cwd='/home/fsanches/compartilhado/disasm-lanes/phase6/v10/maincpu').stdout
lines = [l.strip() for l in txt.split('\n')[1:]]
body = []
for l in lines:
    if not l or l == '----':
        break
    if l.endswith(':'):
        continue
    body.append(re.sub(r'\s+', ' ', l.lower()))
    if l.split()[0] == 'ret':
        break

ptr = {'xwa': ('P1', 0), 'xbc': ('P2', 0)}
slots = {}
start = os.environ.get('BFSTART')
if start:
    i = next(k for k, l in enumerate(body) if re.search(start, l))
    pro = body[:i + 1]
    body = body[i + 1:]
    for l in pro:
        mm = re.match(r'ld \(xsp ?\+ ?(\w+)\), ?(x\w+)$', l)
        if mm and mm.group(2) in ('xwa', 'xbc'):
            slots[int(mm.group(1), 0)] = ptr[mm.group(2)]


def mem(op):
    m = re.match(r'\((x\w+)\s*(?:\+\s*(\w+))?\)$', op.replace(' ', ''))
    if not m or m.group(1) not in ptr:
        raise ValueError('mem ' + op)
    side, off = ptr[m.group(1)]
    return side, off + (int(m.group(2), 0) if m.group(2) else 0)


def width_shift(mask):
    bits = [b for b in range(8) if mask >> b & 1]
    if not bits or bits != list(range(bits[0], bits[-1] + 1)):
        raise ValueError('mask %x' % mask)
    return len(bits), bits[0]


last = None
cond = None
copies = []          # (dst(side,off,shift,width), src(side,off,shift,width), kind)
val = {}             # register -> dict(src=..., shift=, width=, dsh=, kind=)
carry = None
for ins in body:
    m = re.match(r'(\w+) (.*)$', ins)
    if not m:
        if ins == 'ret':
            break
        raise SystemExit('unknown ' + ins)
    op, args = m.group(1), [a.strip() for a in m.group(2).split(',')]
    if op in ('pop', 'push') or (op == 'lda' and args[0] == 'xsp'):
        continue
    mm = re.match(r'\(xsp\s*\+\s*(\w+)\)$', args[1]) if op == 'ld' and len(args) > 1 else None
    if mm and int(mm.group(1), 0) in slots:
        ptr[args[0]] = slots[int(mm.group(1), 0)]
        continue
    if op == 'ld' and args[0] in ('xde', 'xhl', 'xix', 'xiy', 'xiz', 'xbc', 'xwa') and args[1] in ptr:
        ptr[args[0]] = ptr[args[1]]
    elif op == 'lda':
        mm = re.match(r'\((x\w+)\s*\+\s*(\w+)\)$', args[1].replace(' ', ''))
        side, off = ptr[mm.group(1)]
        ptr[args[0]] = (side, off + int(mm.group(2), 0))
    elif op == 'ld' and args[1].startswith('('):
        side, off = mem(args[1])
        val[args[0]] = dict(src=(side, off), shift=0, width=8, dsh=0, kind='byte', masks=0)
    elif op == 'ld' and args[0].startswith('(') and args[1] in val:
        v = val[args[1]]
        side, off = mem(args[0])
        copies.append(((side, off, 0, 8), (v['src'][0], v['src'][1], v['shift'], v['width']), v['kind']))
    elif op == 'srl':
        v = val[args[0]]
        if v['kind'] == 'pre':
            v['kind'] = 'field'
            v['shift'] = int(args[1], 0)
        else:
            v['shift'] += int(args[1], 0)
    elif op == 'jr' and args[0] == 'z':
        cond = val[last]
    elif op == 'setm':
        side, off = mem(args[1])
        copies.append(((side, off, int(args[0]), 1), (cond['src'][0], cond['src'][1], cond['shift'], cond['width']), 'condset'))
    elif op == 'and' and args[0] in val:
        last = args[0]
        mk = int(args[1], 0)
        v = val[args[0]]
        w, s = width_shift(mk)
        if v['masks'] == 0 and v['kind'] == 'byte' and s > 0:
            v['kind'] = 'pre'
            v['premask'] = mk
            v['width'] = w
            v['masks'] += 1
        elif v['masks'] == 0 and v['kind'] == 'byte':
            v['width'] = w
            v['kind'] = 'field'
        v['masks'] += 1
    elif op == 'res' and args[1] in val:
        v = val[args[1]]
        if int(args[0]) == 7 and v['masks'] == 0:
            v['width'] = 7
            v['kind'] = 'field'
            v['masks'] += 1
        elif int(args[0]) == 7:
            v['masks'] += 1
        else:
            raise SystemExit('res ' + ins)
    elif op == 'sla':
        val[args[0]]['dsh'] = int(args[1], 0)
    elif op in ('ldcfm', 'ldcf'):
        side, off = mem(args[1])
        carry = (side, off, int(args[0]), 1)
    elif op in ('stcfm', 'stcf'):
        side, off = mem(args[1])
        copies.append(((side, off, int(args[0]), 1), carry, 'cf'))
    elif op in ('scc8', 'scc'):
        val[args[1]] = dict(src=carry[:2], shift=carry[2], width=1, dsh=0, kind='scc', masks=1)
    elif op == 'andmi8' or (op == 'and' and args[0].startswith('(')):
        side, off = mem(args[0])
        dm = int(args[1], 0)
        dw, ds = width_shift(~dm & 0xff)
        pend = (side, off, ds, dw)
    elif op == 'or' and args[0].startswith('('):
        side, off = mem(args[0])
        v = val[args[1]]
        assert pend[:2] == (side, off), (pend, side, off)
        k = {'pre': 'inplace'}.get(v['kind'], v['kind'])
        copies.append((pend, (v['src'][0], v['src'][1], v['shift'], v['width']), k, v))
    elif op == 'ret':
        break
    else:
        raise SystemExit('unhandled: ' + ins)

if not copies:
    raise SystemExit('no copies')
dside = copies[0][0][0]
sside = copies[0][1][0]
assert all(c[0][0] == dside and c[1][0] == sside for c in copies), 'mixed sides'
BYTEPTR_S = ('inplace', 'maskshift')
BYTEPTR_D = ('inplace',)


SIGNED = set()
if scc_form == 'signed':
    SIGNED = {c[1][1:] for c in copies if c[2] == 'scc'}


def layout(fields, tag):
    """fields: set of (off, shift, width).  Returns C struct body and name map."""
    byoff = {}
    for off, sh, w in fields:
        byoff.setdefault(off, set()).add((sh, w))
    mx = max(byoff)
    out = []
    names = {}
    pos = 0
    g = 0
    while pos <= mx:
        if pos not in byoff:
            n = pos
            while n <= mx and n not in byoff:
                n += 1
            while pos < n:
                if pos % 2 or n - pos < 2:
                    out.append('unsigned char g%d;' % pos)
                    pos += 1
                else:
                    ln = (n - pos) & ~1
                    out.append('unsigned char g%d[%d];' % (pos, ln))
                    pos += ln
            continue
        fs = byoff[pos]
        if any(w == 8 for sh, w in fs):
            out.append('unsigned char b%d;' % pos)
            for sh, w in fs:
                names[(pos, sh, w)] = 'b%d' % pos
        else:
            bit = 7
            for sh, w in sorted(fs, key=lambda x: -(x[0] + x[1])):
                top = sh + w - 1
                if top > bit:
                    raise SystemExit('overlap at %d' % pos)
                if top < bit:
                    out.append('unsigned char p%d_%d : %d;' % (pos, bit, bit - top))
                nm = 'f%d_%d' % (pos, sh)
                ty = 'char' if (tag == 's' and (pos, sh, w) in SIGNED) else 'unsigned char'
                out.append('%s %s : %d;' % (ty, nm, w))
                names[(pos, sh, w)] = nm
                bit = sh - 1
            if bit >= 0:
                out.append('unsigned char p%d_%d : %d;' % (pos, bit, bit + 1))
        pos += 1
    if (mx + 1) % 2:
        out.append('unsigned char gend;')
    return out, names


dbody, dnames = layout({c[0][1:] for c in copies if c[2] not in BYTEPTR_D}, 'd')
sbody, snames = layout({c[1][1:] for c in copies if c[2] not in BYTEPTR_S}, 's')
short = os.environ.get('BFTAG', label[:20])
print('struct %s_s {' % short)
for l in sbody:
    print('\t' + l)
print('};')
print('struct %s_d {' % short)
for l in dbody:
    print('\t' + l)
print('};')
p1, p2 = ('s', 'd') if sside == 'P1' else ('d', 's')
t = {'s': 'struct %s_s *s' % short, 'd': 'struct %s_d *d' % short}
print('void %s(%s, %s)\n{' % (label, t[p1], t[p2]))
for c in copies:
    d, s, k = c[0], c[1], c[2]
    if k == 'inplace':
        v = c[3]
        dm = ~(((1 << d[3]) - 1) << d[2]) & 0xff
        print('\t((unsigned char *)d)[%d] = (((unsigned char *)d)[%d] & 0x%x) | (((unsigned char *)s)[%d] & 0x%x);'
              % (d[1], d[1], dm, s[1], v['premask']))
        continue
    if k == 'maskshift':
        v = c[3]
        print('\td->%s = (((unsigned char *)s)[%d] & 0x%x) >> %d;' % (dnames[d[1:]], s[1], v['premask'], v['pshift']))
        continue
    rhs = 's->%s' % snames[s[1:]]
    if k == 'condset':
        print('\tif (%s) d->%s = 1;' % (rhs, dnames[d[1:]]))
        continue
    if k == 'scc' and scc_form == 'ne':
        rhs = '(%s != 0)' % rhs
    print('\td->%s = %s;' % (dnames[d[1:]], rhs))
print('}')
