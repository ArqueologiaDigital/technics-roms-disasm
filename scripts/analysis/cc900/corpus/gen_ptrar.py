"""gen_ptrar.py OUT.c: a wrong-code probe for pointer arithmetic, pointer differences and comparisons, pointer walks,
pointers to pointers, arrays of pointers and calls through function pointers (lane_nm's area: the element and
pointer address paths).  One statement per function (a loop or a declaration more where the shape needs it), so a
semcheck DIFFERENT names its shape.  UB-free when called as the probe intends: every relational compare and every
difference is between pointers into the same object (an unsized global array, or two parameters the caller passes
into one array); the large offsets index the unsized arrays (extern T gXu[], of any size).

Element types t: c char, i int, l long, x struct s3 (3 bytes: a size that is not a power of two), s struct s10
(10 bytes).  The unsized arrays gXu[], the global pointers gXp / gXp2, the pointers to pointers gXpp, the arrays of
pointers gXpa[4] are declared for each.

  pa_<t><b><x><o>  p + i / p - i:
     b  base:   g global pointer gXp, q parameter pointer, u unsized array gXu, a &gXu[2], m member pointer gps->pX
     x  index:  k 3, K 0x8001u, L 0x12345L (a long offset past 16 bits), n -2, p int b, u unsigned int ub,
                c char cb, l long lb, g global int gi, e b + 1
     o  op (gXu and &gXu[2] skip a constant offset before the array's start):
                a p + i (returned), s p - i (returned), r *(p + i) read, w *(p - i) = 5 store, i gXp2 = p + i
                (stored to a global pointer; bases g and q only); the struct types read / write member a[1]
  pd_<t><f>        p - q (ptrdiff), int or long: f a q - r (two parameters), b (gXu + b) - gXu, c &gXu[ub] - &gXu[b],
                   d gXp - gXp2, e q - gXp, f long d = r - q (the long result), g (q - r) > 0, h (r - q) / 2,
                   i (gXu + lb) - gXu (a long index)
  pc_<t><f><o><u>  comparisons: f the operands: q q vs r (parameters), g gXp vs gXp2, u gXu + b vs gXu + ub,
                   d *pp vs q (through a pointer to a pointer), k q vs q + b;
                   o the relation: l <, e <=, g >, h >=, q ==, n !=, z !p, y p == 0, b p && q (the truth of both);
                   u the use: v the value returned, i if (..) gi = 1 (a branch)
  pw_<t><k><o>     walks: k the pointer: q parameter, g global gXp, l local copy of q, m member gps->pX;
                   o a *p++ read, b *--p read, c *p-- read, d *++p read, e *p++ = v, f *--p = v, g *p++ += 1,
                   h x = *p++ + *p++ (two in one expression); loops (pw_<t>_<o>): n while (n--) *q++ = 0,
                   s sum of n elements, y copy n from r to q, z the walk to a zero element, r a reverse walk *--e
  pp_<t><k><o>     pointers to pointers: k p parameter T **pp, g global gXpp; o a **pp, b *pp + b, c (*pp)[b],
                   d *pp = q, e (*pp)++, f *(*pp)++, g pp[b][2], h *pp[b], i **pp = 5, j *pp = &gXu[b], k pp[1] - pp[0]
  pr_<t><o>        arrays of pointers gXpa[4]: a *gXpa[b], b gXpa[b][2], c gXpa[2][b], d gXpa[b] = q, e gXpa[b]++,
                   f *gXpa[2]++, g gXpa[b][ub] = 5, h gXpa[cb] - gXpa[0] (same object: the caller's contract),
                   i a local array of two pointers, *la[b & 1], j gXpa[b] == q
  pf_<o>           calls through function pointers (cdecl; -Xr turns them into adecl indirect calls, which the model
                   refuses): arrays of pointers, struct members through a global, a global pointer and a parameter,
                   a parameter function pointer, an array parameter, stores of function pointers, compares, calls
                   whose argument is another indirect call, char / long / void results
Parameters: (int b, unsigned int ub, char cb, long lb, T *q, T *r) unless the shape needs others, so -Xr puts b / ub /
cb in WA / BC / DE and the rest on the stack."""
import sys

T = {'c': 'char', 'i': 'int', 'l': 'long', 'x': 'struct s3', 's': 'struct s10'}
G = {'c': 'gc', 'i': 'gi', 'l': 'gl', 'x': 'gx', 's': 'gs'}
out = ['/* lane_nm wrong-code probe: pointer arithmetic, differences, comparisons, walks, pointers to pointers,',
       '   arrays of pointers, function pointers; see gen_ptrar.py for the name letters */',
       'struct s3 { char a[3]; };',
       'struct s10 { int a[5]; };',
       'struct pv { char *pc; int *pi; long *pl; struct s3 *px; struct s10 *ps; };',
       'extern struct pv *gps;',
       'extern int gi;']
for t, ty in T.items():
    g = G[t]
    out.append('extern %s %su[], *%sp, *%sp2, **%spp, *%spa[4];' % (ty, g, g, g, g, g))
out += ['struct fs { int (*fi)(int); long (*fl)(long, long); void (*fv)(void); char (*fc)(char); };',
        'extern struct fs gfs, *gpfs;',
        'extern int (*gfa[4])(int);',
        'extern long (*gfl[4])(long);',
        'extern int (*gfp)(int);',
        'extern int fi1(int);']
MEM = {'c': 'pc', 'i': 'pi', 'l': 'pl', 'x': 'px', 's': 'ps'}
IDX = {'k': '3', 'K': '0x8001u', 'L': '0x12345L', 'n': '-2', 'p': 'b', 'u': 'ub', 'c': 'cb', 'l': 'lb', 'g': 'gi',
       'e': '(b + 1)'}
P = 'int b, unsigned int ub, char cb, long lb, %s *q, %s *r'
CONST = {'k': 3, 'K': 0x8001, 'L': 0x12345, 'n': -2}
n = 0


def fn(ret, name, params, body):
    global n
    out.append('%s %s(%s) { %s }' % (ret, name, params, body)); n += 1


def elem(t, e):                    # an element's scalar: the struct types read / write member a[1]
    return '(%s)->a[1]' % e if t in 'xs' else '*(%s)' % e


def scal(t):                       # the scalar type an element read returns
    return {'c': 'char', 'i': 'int', 'l': 'long', 'x': 'char', 's': 'int'}[t]


# pa: p + i / p - i
for t, ty in T.items():
    g = G[t]
    B = {'g': g + 'p', 'q': 'q', 'u': g + 'u', 'a': '&%su[2]' % g, 'm': 'gps->' + MEM[t]}
    for b, base in B.items():
        for x, i in IDX.items():
            for o in 'asrwi':
                name = 'pa_%s%s%s%s' % (t, b, x, o)
                if b in 'ua' and x in CONST and (2 if b == 'a' else 0) + (1 if o in 'ari' else -1) * CONST[x] < 0:
                    continue                               # (before the array's start: undefined)
                if o == 'i' and b not in 'gq': continue    # (the store to a global pointer: two bases)
                if o == 'a': fn(ty + ' *', name, P % (ty, ty), 'return %s + %s;' % (base, i))
                elif o == 's': fn(ty + ' *', name, P % (ty, ty), 'return %s - %s;' % (base, i))
                elif o == 'r': fn(scal(t), name, P % (ty, ty), 'return %s;' % elem(t, '%s + %s' % (base, i)))
                elif o == 'w': fn('void', name, P % (ty, ty), '%s = 5;' % elem(t, '%s - %s' % (base, i)))
                else: fn('void', name, P % (ty, ty), '%sp2 = %s + %s;' % (g, base, i))

# pd: p - q
for t, ty in T.items():
    g = G[t]
    D = {'a': ('int', 'return q - r;'), 'b': ('int', 'return (%su + b) - %su;' % (g, g)),
         'c': ('int', 'return &%su[ub] - &%su[b];' % (g, g)), 'd': ('int', 'return %sp - %sp2;' % (g, g)),
         'e': ('int', 'return q - %sp;' % g), 'f': ('long', 'long d = r - q; return d;'),
         'g': ('int', 'return (q - r) > 0;'), 'h': ('int', 'return (r - q) / 2;'),
         'i': ('long', 'return (%su + lb) - %su;' % (g, g))}
    for f, (ret, body) in D.items():
        fn(ret, 'pd_%s%s' % (t, f), P % (ty, ty), body)

# pc: comparisons
REL = {'l': '<', 'e': '<=', 'g': '>', 'h': '>=', 'q': '==', 'n': '!='}
for t, ty in T.items():
    g = G[t]
    OPS = {'q': ('q', 'r'), 'g': (g + 'p', g + 'p2'), 'u': ('%su + b' % g, '%su + ub' % g), 'd': ('*%spp' % g, 'q'),
           'k': ('q', 'q + b')}
    for f, (a, c) in OPS.items():
        for o in 'legh' 'qnzyb':
            if o in REL: e = '(%s) %s (%s)' % (a, REL[o], c)
            elif o == 'z': e = '!(%s)' % a
            elif o == 'y': e = '(%s) == 0' % a
            else: e = '(%s) && (%s)' % (a, c)
            if o in 'zyb' and f in 'uk': continue          # (a computed address is never null)
            fn('int', 'pc_%s%s%sv' % (t, f, o), P % (ty, ty), 'return %s;' % e)
            fn('void', 'pc_%s%s%si' % (t, f, o), P % (ty, ty), 'if (%s) gi = 1;' % e)

# pw: walks
for t, ty in T.items():
    g = G[t]; s = scal(t)
    K = {'q': 'q', 'g': g + 'p', 'l': 'p', 'm': 'gps->' + MEM[t]}
    for k, p in K.items():
        pre = '%s *p = q; ' % ty if k == 'l' else ''
        post = ' gi = (int)(p - q);' if k == 'l' else ''   # (the local's final value observed)
        if t in 'xs':
            F = {'a': ('%s y = (%s++)->a[1];' % (s, p), 'y'), 'b': ('%s y = (--%s)->a[1];' % (s, p), 'y'),
                 'e': ('(%s++)->a[1] = b;' % p, None), 'f': ('(--%s)->a[1] = b;' % p, None)}
        else:
            F = {'a': ('%s y = *%s++;' % (s, p), 'y'), 'b': ('%s y = *--%s;' % (s, p), 'y'),
                 'c': ('%s y = *%s--;' % (s, p), 'y'), 'd': ('%s y = *++%s;' % (s, p), 'y'),
                 'e': ('*%s++ = b;' % p, None), 'f': ('*--%s = b;' % p, None), 'g': ('*%s++ += 1;' % p, None),
                 'h': ('%s y = *%s++; y += *%s++;' % (s, p, p), 'y')}
        for o, (st, rv) in F.items():
            if rv: fn(s, 'pw_%s%s%s' % (t, k, o), P % (ty, ty), pre + st + post + ' return %s;' % rv)
            else: fn('void', 'pw_%s%s%s' % (t, k, o), P % (ty, ty), pre + st + post)
    z = '0' if t not in 'xs' else None
    if t not in 'xs':
        fn('void', 'pw_%s_n' % t, P % (ty, ty), 'int n = b; while (n--) *q++ = 0;')
        fn(s, 'pw_%s_s' % t, P % (ty, ty), '%s s = 0; int n = b; while (n-- > 0) s += *q++; return s;' % s)
        fn('void', 'pw_%s_y' % t, P % (ty, ty), 'int n = b; while (n--) *q++ = *r++;')
        fn('int', 'pw_%s_z' % t, P % (ty, ty), '%s *p = q; while (*p++) ; return p - q;' % ty)
        fn(s, 'pw_%s_r' % t, P % (ty, ty), '%s s = 0; %s *e = q + b; while (e > q) s += *--e; return s;' % (s, ty))
    else:
        fn('void', 'pw_%s_n' % t, P % (ty, ty), 'int n = b; while (n--) (q++)->a[1] = 0;')
        fn('void', 'pw_%s_y' % t, P % (ty, ty), 'int n = b; while (n--) *q++ = *r++;')
        fn(s, 'pw_%s_r' % t, P % (ty, ty), '%s s = 0; %s *e = q + b; while (e > q) s += (--e)->a[1]; return s;' % (s, ty))

# pp: pointers to pointers
for t, ty in T.items():
    g = G[t]; s = scal(t)
    for k in 'pg':
        pp = 'pp' if k == 'p' else g + 'pp'
        par = 'int b, unsigned int ub, %s *q, %s **pp' % (ty, ty)
        mem = lambda e: '(%s)->a[1]' % e if t in 'xs' else '*(%s)' % e
        F = {'a': (s, 'return %s;' % mem('*' + pp)), 'b': (ty + ' *', 'return *%s + b;' % pp),
             'c': (s, 'return %s;' % ('(*%s)[b].a[1]' % pp if t in 'xs' else '(*%s)[b]' % pp)),
             'd': ('void', '*%s = q;' % pp), 'e': ('void', '(*%s)++;' % pp),
             'f': (s, 'return %s;' % mem('(*%s)++' % pp)),
             'g': (s, 'return %s;' % ('%s[b][2].a[1]' % pp if t in 'xs' else '%s[b][2]' % pp)),
             'h': (s, 'return %s;' % mem('%s[b]' % pp)), 'i': ('void', '%s = 5;' % mem('*' + pp)),
             'j': ('void', '*%s = &%su[b];' % (pp, g)), 'k': ('int', 'return %s[1] - %s[0];' % (pp, pp))}
        for o, (ret, body) in F.items():
            fn(ret, 'pp_%s%s%s' % (t, k, o), par, body)

# pr: arrays of pointers
for t, ty in T.items():
    g = G[t]; s = scal(t); pa = g + 'pa'
    mem = lambda e: '(%s)->a[1]' % e if t in 'xs' else '*(%s)' % e
    sub = lambda e, i: '%s[%s].a[1]' % (e, i) if t in 'xs' else '%s[%s]' % (e, i)
    F = {'a': (s, 'return %s;' % mem('%s[b]' % pa)), 'b': (s, 'return %s;' % sub('%s[b]' % pa, 2)),
         'c': (s, 'return %s;' % sub('%s[2]' % pa, 'b')), 'd': ('void', '%s[b] = q;' % pa),
         'e': ('void', '%s[b]++;' % pa), 'f': (s, 'return %s;' % mem('%s[2]++' % pa)),
         'g': ('void', '%s = 5;' % sub('%s[b]' % pa, 'ub')), 'h': ('int', 'return %s[cb] - %s[0];' % (pa, pa)),
         'i': (s, '%s *la[2]; la[0] = q; la[1] = %sp; return %s;' % (ty, g, mem('la[b & 1]'))),
         'j': ('int', 'return %s[b] == q;' % pa)}
    for o, (ret, body) in F.items():
        fn(ret, 'pr_%s%s' % (t, o), P % (ty, ty), body)

# pf: function pointers
PF = 'int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q'
F = {'a': ('int', 'return gfa[b](ub);'), 'b': ('int', 'return gfa[2](b);'), 'c': ('int', 'return (*gfa[cb])(3);'),
     'd': ('int', 'return gfs.fi(b);'), 'e': ('long', 'return gpfs->fl(lb, 1);'), 'f': ('void', 'gpfs->fv();'),
     'g': ('int', 'return q->fi(b);'), 'h': ('int', 'return (*fp)(b);'), 'i': ('int', 'return fp(b) + 1;'),
     'j': ('int', 'return fpa[b](ub);'), 'k': ('void', 'gfa[b] = gfp;'), 'm': ('void', 'gpfs->fi = fp;'),
     'n': ('int', 'return gfa[b] == gfp;'), 'o': ('int', 'return gfa[b](1) + gfa[ub](2);'),
     'p': ('int', 'return gfa[b](gfa[0](cb));'), 'q': ('char', 'return gfs.fc(cb);'),
     'r': ('long', 'return gfl[b](lb) * 2;'), 's': ('int', 'return gfp(b);'), 't': ('void', 'gfa[1] = fi1;'),
     'u': ('int', 'int (*f)(int) = b ? gfa[0] : fp; return f(ub);'), 'v': ('void', 'q->fv(); gpfs->fv();'),
     'w': ('int', 'return gfp != 0 ? gfp(b) : 0;'), 'x': ('long', 'return q->fl(lb, b) + gpfs->fl(1, lb);'),
     'y': ('int', 'return (b ? gfa[1] : gfa[2])(cb);'), 'z': ('int', 'return fpa[2](b) - fpa[b](2);')}
for o, (ret, body) in F.items():
    fn(ret, 'pf_%s' % o, PF, body)

open(sys.argv[1], 'w').write('\n'.join(out) + '\n')
print(n, 'functions')
