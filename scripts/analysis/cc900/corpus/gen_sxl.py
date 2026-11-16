"""gen_sxl.py OUT.c: a mini-probe (lane_o3) for the adecl stack layout of small structs beside other stack arguments.
stc's .st_pc_4 showed V4.23 pushing z4(gl1, g42, gd1)'s double first and its 4-byte struct last, against .st_pc_8's
left-to-right order (struct, then double); the model refuses that shape (fix 09 ADECL_SMALL_STRUCT_STACK) until a
listing shows where the callee expects each argument.  Each signature appears twice: a definition that stores every
parameter to a global (sx_d_<k>, the callee side: which (XSP+n) each parameter is read from, and the retd count) and a
call of an extern with the same parameter list from globals (sx_c_<k>, the caller side: the push order).  Meant for
-Xr (Xr, O3XSXr); the cdecl sets are the control.  No undefined behaviour: every parameter and global is read as
stored.  Names: sx_<d|c>_<k>, k below (L long, I int, C char, D double, s2 / s4 / s8 a struct of 2 / 4 / 8 bytes)
  a  (L, s4, D)   b  (s4, D)      c  (D, s4)      d  (I, I, I, s4, D)   e  (L, s4, L, L)
  f  (L, s4, s4)  g  (L, D, s4)   h  (s4, s8)     i  (C, s4, D, I)      j  (L, s2, D)
  k  (s2, D)      l  (L, s8, D)   (l: the 8-byte control, the order .st_pc_8 showed)"""
import sys
T = {'L': 'long', 'I': 'int', 'C': 'char', 'D': 'double', 's2': 'struct s2', 's4': 'struct s4', 's8': 'struct s8'}
SIGS = {'a': ['L', 's4', 'D'], 'b': ['s4', 'D'], 'c': ['D', 's4'], 'd': ['I', 'I', 'I', 's4', 'D'],
        'e': ['L', 's4', 'L', 'L'], 'f': ['L', 's4', 's4'], 'g': ['L', 'D', 's4'], 'h': ['s4', 's8'],
        'i': ['C', 's4', 'D', 'I'], 'j': ['L', 's2', 'D'], 'k': ['s2', 'D'], 'l': ['L', 's8', 'D']}
out = ['/* lane_o3 mini-probe: adecl stack layout of small structs; see gen_sxl.py */',
       'struct s2 { int a; }; struct s4 { int a, b; }; struct s8 { long a; int b, c; };']
G = {}                                         # the globals: one source and one destination per (type, position)
def glob(t, i, role):
    n = 'g%s_%s%d' % (role, t, i); G[n] = T[t]; return n
F = []
for k, sig in SIGS.items():
    ps = ', '.join('%s p%d' % (T[t], i) for i, t in enumerate(sig))
    F.append('void sx_d_%s(%s) { %s }' % (k, ps, ' '.join('%s = p%d;' % (glob(t, i, 'o'), i) for i, t in enumerate(sig))))
    out_ext = 'extern void x_%s(%s);' % (k, ', '.join(T[t] for t in sig))
    F.append('%s\nvoid sx_c_%s(void) { x_%s(%s); }' % (out_ext, k, k, ', '.join(glob(t, i, 'i') for i, t in enumerate(sig))))
out += ['extern %s %s;' % (ty, n) for n, ty in sorted(G.items())]
out += F
open(sys.argv[1], 'w').write('\n'.join(out) + '\n')
print(len(SIGS) * 2, 'functions')
