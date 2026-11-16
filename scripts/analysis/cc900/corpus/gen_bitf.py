"""gen_bitf.py OUT.c: a probe for bit-fields (lane_o3), for semcheck and for V4.23's allocation.  Phase 6 found that
V4.23 puts the first field of struct { unsigned int status:8; unsigned int rest:8; } at the HIGH end of its 16-bit
unit (ld HL,(_s) / srl 0x8,HL for s.status), while the model ignored bit-fields altogether (wrong code).  This probe
shows the allocation (sizeof, the shifts and masks of each field), and reads, writes and op= at widths 1-16, signed
and unsigned, through a global and through a pointer.  No undefined or implementation-defined behaviour on purpose:
every value written to a signed field is in its range (a constant chosen so, or a parameter masked and offset), an
unsigned field takes any value (truncation is defined).  Names: bf_<struct>_<field>_<kind>, kinds:
  r  return g.f          p  return gp->f        k  g.f = constant      v  g.f = parameter (masked for signed)
  w  gp->f = parameter   a  g.f += 1 (op=)      o  g.f |= 1 (unsigned) / g.f -= 1 (signed)
  c  if (g.f == constant) gi3 = 1; else gi3 = 2  x  return g.f + g.f2 (two fields of one unit)
and bf_<struct>_size: return sizeof(struct)."""
import sys
S = {
    'b1': [('unsigned int', 'a', 1), ('unsigned int', 'b', 3), ('unsigned int', 'c', 4), ('unsigned int', 'd', 8)],
    'b2': [('unsigned int', 'a', 5), ('unsigned int', 'b', 7), ('unsigned int', 'c', 9)],
    'b3': [('int', 's', 3), ('int', 't', 13)],
    'b4': [('unsigned int', 'w', 16), ('unsigned int', 'x', 1)],
    'b5': [('char', 'c', None), ('unsigned int', 'f', 4), ('unsigned int', 'g', 12)],
    'b6': [('unsigned int', 'a', 4), ('unsigned int', '', 0), ('unsigned int', 'b', 4)],
    'b7': [('int', 'm', 1), ('unsigned int', 'n', 2), ('int', 'o', 6), ('unsigned int', 'q', 7)],
    'b8': [('unsigned int', 'h', 12), ('int', 'i', 4), ('unsigned int', 'j', 10)],
}
out = ['/* lane_o3 probe: bit-fields; see gen_bitf.py for the name letters */', 'extern int gi3;']
F = []
for sn, fields in S.items():
    body = ' '.join('%s %s;' % (t, n) if w is None else ('%s %s : %d;' % (t, n, w) if n else '%s : %d;' % (t, w))
                    for t, n, w in fields)
    out.append('struct %s { %s };' % (sn, body))
    out.append('extern struct %s g%s, *gp%s;' % (sn, sn, sn))
    F.append('int bf_%s_size(void) { return sizeof(struct %s); }' % (sn, sn))
    bits = [(t, n, w) for t, n, w in fields if w and n]
    for t, n, w in bits:
        signed = not t.startswith('unsigned')
        g, p = 'g%s.%s' % (sn, n), 'gp%s->%s' % (sn, n)
        hi = (1 << (w - 1)) - 1 if signed else (1 << w) - 1
        k = hi // 2 if hi > 1 else hi                           # a constant in range
        rt = 'int' if signed else 'unsigned int'
        val = '(v & %d) - %d' % ((1 << w) - 1, 1 << (w - 1)) if signed else 'v'   # in [-2^(w-1), 2^(w-1)-1]
        if signed and w == 16: val = 'v'
        F.append('%s bf_%s_%s_r(void) { return %s; }' % (rt, sn, n, g))
        F.append('%s bf_%s_%s_p(void) { return %s; }' % (rt, sn, n, p))
        F.append('void bf_%s_%s_k(void) { %s = %d; }' % (sn, n, g, k))
        F.append('void bf_%s_%s_v(int v) { %s = %s; }' % (sn, n, g, val))
        F.append('void bf_%s_%s_w(int v) { %s = %s; }' % (sn, n, p, val))
        if signed:                                              # op= that stays in range: read is in range, +1 / -1
            F.append('void bf_%s_%s_a(void) { if (%s < %d) %s += 1; }' % (sn, n, g, hi, g))
            F.append('void bf_%s_%s_o(void) { if (%s > %d) %s -= 1; }' % (sn, n, g, -(1 << (w - 1)), g))
        else:
            F.append('void bf_%s_%s_a(void) { %s += 1; }' % (sn, n, g))
            F.append('void bf_%s_%s_o(void) { %s |= 1; }' % (sn, n, g))
        F.append('void bf_%s_%s_c(void) { if (%s == %d) gi3 = 1; else gi3 = 2; }' % (sn, n, g, k))
    if len(bits) >= 2:
        F.append('int bf_%s_x(void) { return g%s.%s + g%s.%s; }' % (sn, sn, bits[0][1], sn, bits[1][1]))
out += F
open(sys.argv[1], 'w').write('\n'.join(out) + '\n')
print(len(F), 'functions')
