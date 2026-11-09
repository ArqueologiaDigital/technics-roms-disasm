#!/usr/bin/env python3
"""Semantic check of the cc900 reference model: does the model's code compute what the oracle's code computes?

usage: python3 -I -B semcheck.py ORACLE_DIR FILE.c [FILE.c ...] [--opt none|O3XS] [--adecl] [--personality P]
                                  [-DNAME[=V] ...] [-IDIR ...] [--trials N] [--limit STEPS] [--only NAME[,NAME]]
                                  [--model-dir DIR] [--verbose]
       python3 -I -B semcheck.py --ledger [--all-compilers] [--library] [--results FILE.md] [--trials N] [--jobs N]
                                 [--model-dir DIR]

The first form takes the same arguments as score.py.  For every function of every FILE.c it compiles the function
with the model (codegen.compile_unit, the options score.py would use) and takes the oracle's code from ORACLE_DIR's
listing, then runs both in interp.py on the same random inputs (semcheck.md says how they are made) and compares
what is observable: the return value, every byte written outside the stack, the calls made (callee, arguments and
the memory state at the call), XSP after the return and XIZ.  It prints one line per file and option set (checked,
equal, DIFFERENT, not checked) and one line per DIFFERENT function with the first differing output.  Exit status 1
when any function is DIFFERENT.

--ledger runs every micro/ and probes/ row of ledger.sh (only the V4.23 compiler unless --all-compilers), and with
--library also the 1997 library row (V4.23, -O3 -XS; FP functions are not checked); with --results it writes the
summary tables.  --model-dir DIR imports codegen/frontend/listing from DIR instead (an older
revision extracted with `git archive`), to see whether a known bug is caught.
"""
import os, sys, re, struct, zlib, random, subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
CC900 = os.path.dirname(HERE)

def _arg(a, k, default=None):
    return a[a.index(k) + 1] if k in a else default

ARGV = sys.argv[1:]
MODEL_DIR = os.path.abspath(_arg(ARGV, '--model-dir', HERE))
sys.path.insert(0, HERE)
if MODEL_DIR != HERE: sys.path.insert(0, MODEL_DIR)
import interp
import frontend, listing, codegen

# ---------------------------------------------------------------- address space (24-bit)

STACK_LO, STACK_HI = 0x0E0000, 0x0F1000      # never compared: frames differ legitimately
ARGS = 0x0F0000 - 0x100                     # XSP at entry: the return address; arguments above
GLOB_BASE = 0x100000                        # the unit's globals, in name order
UNK_BASE = 0x200000                         # other data symbols, by name hash
BUF_BASE = 0x400000                         # what pointer arguments and pointer globals point to
RET_BUF = 0x500000                          # pointers returned by stubs; the hidden result buffer
FUNC_BASE = 0x700000                        # function symbols and function pointers
HELPERS = ('C9H_mulls', 'C9H_mullu', 'C9H_divls', 'C9H_divlu', 'C9H_remls', 'C9H_remlu')
LIMIT = 10000

def in_stack(a): return STACK_LO <= (a & 0xFFFFFF) < STACK_HI

def mix(*xs):
    return zlib.crc32(repr(xs).encode()) & 0xFFFFFFFF

# ---------------------------------------------------------------- types and the ABI

def slot_size(t):
    """bytes a cdecl argument of type t takes on the stack"""
    if t.kind in ('ptr', 'array', 'func'): return 4
    if t.kind == 'int': return 2 if t.size <= 2 else 4
    if t.kind == 'float': return t.size
    if t.kind == 'struct': return (t.size + 1) // 2 * 2
    raise interp.Unsupported('argument type %s' % t.spell)

def mem_result(t):
    """a result returned through a hidden pointer (cdecl): double, long double, struct over 4 bytes"""
    return t is not None and ((t.kind == 'float' and t.size > 4) or (t.kind == 'struct' and t.size > 4))

ADECL_REGS = [('A', 'WA', 'XWA'), ('C', 'BC', 'XBC'), ('E', 'DE', 'XDE')]

def layout(types, adecl):
    """-> list of ('reg', name, bits) or ('stack', offset from XSP+4, size, slot) per argument, total stack bytes"""
    out = [None] * len(types); stack = []
    for i, t in enumerate(types):
        if adecl and i < 3 and t.kind not in ('struct',) and not (t.kind == 'float' and t.size > 4):
            n = 1 if (t.kind == 'int' and t.size == 1) else 2 if (t.kind == 'int' and t.size == 2) else 4
            name = ADECL_REGS[i][{1: 0, 2: 1, 4: 2}[n]]
            out[i] = ('reg', name, 8 * n)
        else:
            if adecl and t.kind == 'struct': raise interp.Unsupported('struct argument under adecl')
            stack.append(i)
    off = 0
    order = reversed(stack) if adecl else stack       # adecl pushes left to right: the last is nearest
    for i in order:
        s = slot_size(types[i]); out[i] = ('stack', off, types[i].size if types[i].kind != 'int' else s, s); off += s
    return out, off

# ---------------------------------------------------------------- value generation

def gen_int(rng, bits, signed, mode):
    mask = (1 << bits) - 1
    if mode == 'small': v = rng.randint(-2, 9) if signed else rng.randint(0, 9)
    elif mode == 'edge':
        v = rng.choice([0, 1, 2, 3, -1, -2, 1 << (bits - 1), (1 << (bits - 1)) - 1, mask, 0x7f, 0x80, 0xff,
                        0x100, 0x7fff, 0x8000, 0xffff, 0x10000])
    else: v = rng.getrandbits(bits)
    return v & mask

class World:
    """the symbols and initial memory shared by the model's run and the oracle's (one function, one trial)"""
    def __init__(s, unit, data_blocks):
        s.unit = unit
        gl = sorted(n for n, d in unit.decls.items() if d.kind == 'global' and not n.startswith('__'))
        fn = sorted(n for n, d in unit.decls.items() if d.kind == 'func')
        s.addr = {}; s.decl_of = {}; a = GLOB_BASE
        for n in gl:
            d = unit.decls[n]; s.addr['_' + n] = a; s.decl_of[a] = d
            a += (max(d.ty.size, 2) + 0x200 + 0x3FF) // 0x400 * 0x400
        for k, n in enumerate(fn):
            s.addr['_' + n] = FUNC_BASE + 0x20 * k; s.addr['.' + n] = FUNC_BASE + 0x20 * k + 0x10
        s.names = {}
        for n, v in s.addr.items(): s.names.setdefault(v, n)
        s.globals = [(n, unit.decls[n]) for n in gl]
        s.data_blocks = data_blocks           # symbol -> {offset: byte} from the oracle listing's data definitions

    def symaddr(s, name):
        if name not in s.addr:
            if name.startswith(('_', '.')) or name in HELPERS or name.startswith('C9H_'):
                if name.startswith('C9H_') or name.startswith('._f'):
                    v = FUNC_BASE + 0x8000 + (zlib.crc32(name.encode()) % 0x800) * 0x10
                else:
                    v = UNK_BASE + (zlib.crc32(name.encode()) % 0x8000) * 0x20
                s.addr[name] = v; s.names.setdefault(v, name)
            else:
                raise interp.Unsupported('undefined label %s' % name)
        return s.addr[name]

    def sym_name(s, a):
        a &= 0xFFFFFF
        if a in s.names: return s.names[a]
        best = None
        for n, v in s.addr.items():
            if v <= a and (best is None or v > s.addr[best]) and not n.startswith('.'): best = n
        if best is not None and a - s.addr[best] < 0x1000: return '%s+%d' % (best, a - s.addr[best])
        return '0x%06x' % a

class Trial:
    def __init__(s, world, seed, mode):
        s.w = world; s.seed = seed; s.mode = mode; s.preset = {}; s.nbuf = 0
        s.consts = set()
        for n, d in world.globals:
            base = world.addr['_' + n]
            blk = world.data_blocks.get('_' + n)
            if blk:                                           # defined with an initialiser in the file
                for o, b in blk.items(): s.preset[base + o] = b
                if getattr(d, 'const', False): s.consts.add(n)
                continue
            s.fill(d.ty, base, random.Random(mix(seed, n)), s.preset)

    def new_buf(s):
        s.nbuf += 1
        return BUF_BASE + s.nbuf * 0x4000 + 0x2000

    def fill(s, t, a, rng, out):
        if t.kind == 'int':
            v = gen_int(rng, 8 * t.size, t.signed, s.mode)
            for k in range(t.size): out[a + k] = (v >> (8 * k)) & 0xFF
        elif t.kind == 'ptr':
            v = (FUNC_BASE + 0x4000 + 0x10 * rng.randint(0, 15)) if t.base is not None and t.base.kind == 'func' \
                else s.new_buf()
            for k in range(4): out[a + k] = (v >> (8 * k)) & 0xFF
        elif t.kind == 'array':
            for i in range(min(t.count or 0, 256)): s.fill(t.base, a + i * t.base.size, rng, out)
        elif t.kind == 'struct':
            for k in range(t.size): out[a + k] = rng.getrandbits(8)
            for fname, ft, off in t.rec or []: s.fill(ft, a + off, rng, out)
        elif t.kind == 'float':
            if s.mode == 'full': b = bytes(rng.getrandbits(8) for _ in range(t.size))
            else: b = struct.pack('<f' if t.size == 4 else '<d', float(rng.randint(-3, 9)))[:t.size]
            for k, c in enumerate(b): out[a + k] = c
        else:
            for k in range(max(t.size, 0)): out[a + k] = rng.getrandbits(8)

    def init_byte(s, a):
        v = s.preset.get(a)
        if v is not None: return v
        h = mix(s.seed, a)
        if s.mode == 'small': return (h % 6) if a % 2 == 0 else 0
        return h & 0xFF

    def arg_value(s, t, rng):
        """-> int (the argument's bytes, little-endian) for a parameter of type t"""
        out = {}
        s.fill(t, 0, rng, out)
        return sum(out.get(k, 0) << (8 * k) for k in range(t.size))

# ---------------------------------------------------------------- calls out of the function

def call_sites(fn):
    """callee name (or '*' for a call through a pointer) -> (argument types, result type), when every call agrees"""
    sites = {}
    def walk(n):
        if isinstance(n, list):
            for x in n: walk(x)
            return
        if not isinstance(n, frontend.N): return
        if n.k == 'call':
            f = n.fn
            while f.k in ('noop', 'decay') : f = f.e
            name = f.decl.name if f.k == 'var' and f.decl.kind == 'func' else '*'
            sig = ([a.ty for a in n.args], n.ty)
            key = tuple(slot_size(t) if t is not None else 0 for t in sig[0])
            sites.setdefault(name, []).append((key, sig))
        for k, v in n.__dict__.items():
            if k in ('decl', 'var', 'ty', 'cty'): continue
            walk(v)
    walk(fn.body)
    out = {}
    for name, l in sites.items():
        out[name] = l[0][1] if all(k == l[0][0] for k, _ in l) else None
    return out

def helper(name, a, b):
    sa, sb = interp.sext(a, 32), interp.sext(b, 32)
    if name == 'C9H_mulls' or name == 'C9H_mullu': return (a * b) & 0xFFFFFFFF
    if name in ('C9H_divlu', 'C9H_remlu'):
        if b == 0: return 0xFFFFFFFF if name == 'C9H_divlu' else a
        return (a // b if name == 'C9H_divlu' else a % b) & 0xFFFFFFFF
    if b == 0: return 0xFFFFFFFF if name == 'C9H_divls' else a
    q = abs(sa) // abs(sb)
    if (sa < 0) != (sb < 0): q = -q
    return (q if name == 'C9H_divls' else sa - q * sb) & 0xFFFFFFFF

CLOBBER = ['XWA', 'XBC', 'XDE', 'XHL', 'XIX', 'XIY']

class Hooks:
    def __init__(s, trial, sites, file_adecl):
        s.t = trial; s.w = trial.w; s.sites = sites; s.adecl = file_adecl; s.calls = []

    def mem_state(s, m):
        return frozenset((a, m.mem[a]) for a in m.written if not in_stack(a) and m.mem[a] != s.t.init_byte(a))

    def clobber(s, m, k):
        for j, r in enumerate(CLOBBER):
            m.set(interp.REGS[r], (0xA5C30F96 ^ (0x01020304 * (j + 1)) ^ (0x9E3779B1 * k)) & 0xFFFFFFFF)
        m.S, m.Z, m.V, m.C, m.H, m.N = k % 2 == 0, k % 3 == 0, k % 5 == 0, k % 2 == 1, False, False

    def call(s, m, addr, tail):
        name = s.w.names.get(addr & 0xFFFFFF)
        k = len(s.calls)
        if name in HELPERS:
            r = helper(name, m.get(interp.REGS['XWA']), m.get(interp.REGS['XBC']))
            s.clobber(m, 1000 + k); m.set(interp.REGS['XHL'], r)
            return 0
        if name is not None and (name.startswith('C9H_') or name.startswith('._f')):
            raise interp.Unsupported('runtime helper %s' % name)
        if name is None:
            name = '*0x%06x' % (addr & 0xFFFFFF); conv = s.adecl; key = '*'
        else:
            conv = name.startswith('.'); key = name[1:]
        sig = s.sites.get(key) if key in s.sites else s.sites.get('*') if name.startswith('*') else None
        sp = m.r[interp.XSP] + 4
        args = None; pop = 0
        if sig is not None:
            types, ret = sig
            hidden = (not conv) and mem_result(ret)
            if conv and mem_result(ret): raise interp.Unsupported('adecl callee with a memory result')
            lay, stackbytes = layout(([frontend.parse_type('char *', frontend.Records(), {})] if hidden else []) + types, conv)
            args = []
            for i, (L, t) in enumerate(zip(lay, ([None] if hidden else []) + types)):
                if L[0] == 'reg': v = m.get(interp.REGS[L[1]])
                else: v = m.rd(sp + L[1], L[3])
                if t is None:                                  # the hidden result pointer
                    args.append(('result', 'stack' if in_stack(v) else s.w.sym_name(v))); continue
                if t.kind in ('ptr', 'array') and in_stack(v):  # address of a local: what it points to
                    n = max(1, min(t.base.size if t.base is not None and t.base.size else 2, 16))
                    args.append(('&local', tuple(m.rd8(v + j) for j in range(n))))
                else: args.append(v)
            pop = stackbytes if conv else 0
            args = tuple(args)
        rec = (name, args, s.mem_state(m))
        s.calls.append(rec)
        h = mix(s.t.seed, name, args, k)
        s.clobber(m, k)
        if sig is not None:
            types, ret = sig
            if ret is not None and ret.kind != 'void':
                if mem_result(ret):
                    p = m.rd(sp, 4)
                    for j in range(ret.size): m.wr8(p + j, mix(h, j))
                else:
                    n = ret.size
                    if ret.kind in ('ptr', 'array'): v = RET_BUF + (h % 64) * 0x100
                    elif s.t.mode == 'small' and ret.kind == 'int': v = h % 5
                    else: v = h
                    reg = {1: 'L', 2: 'HL', 4: 'XHL'}.get(n)
                    if reg is None: raise interp.Unsupported('callee result of %d bytes' % n)
                    m.set(interp.REGS[reg], v)
        # the callee may change any global (not const ones): give the non-const globals new values
        for n, d in s.w.globals:
            if n in s.t.consts or getattr(d, 'const', False) or d.ty.size > 256: continue
            out = {}
            s.t.fill(d.ty, s.w.addr['_' + n], random.Random(mix(h, n, 'callee')), out)
            for a, b in out.items(): m.wr8(a, b)
        return pop

# ---------------------------------------------------------------- one function

def run_one(prog, trial, fn, file_adecl, argvals, limit):
    m = interp.Machine(trial.init_byte)
    for j, r in enumerate(interp.R32[:7]):
        m.set(interp.REGS[r], (0x5A3C9600 + 0x11111111 * (j + 1)) & 0xFFFFFFFF)
    m.Z = m.C = m.S = m.V = True
    types = [p.ty for p in fn.params]
    hidden = (not file_adecl) and mem_result(fn.ret)
    lay, stackbytes = layout(([frontend.parse_type('char *', frontend.Records(), {})] if hidden else []) + types,
                             file_adecl)
    vals = ([RET_BUF + 0x8000] if hidden else []) + list(argvals)
    for L, v, t in zip(lay, vals, ([None] if hidden else []) + types):
        if L[0] == 'reg': m.set(interp.REGS[L[1]], v)
        else:
            n = L[3]
            if t is not None and t.kind == 'int' and t.size < n:          # the caller's extension
                v = (interp.sext(v, 8 * t.size) if t.signed else v) & ((1 << (8 * n)) - 1)
            m.wr(ARGS + 4 + L[1], n, v)
    m.wr(ARGS, 4, interp.RET_MAGIC); m.r[interp.XSP] = ARGS
    m.written.clear()
    h = Hooks(trial, call_sites(fn), file_adecl)
    status = 'ok'
    try: interp.run(prog, m, h, limit)
    except interp.StepLimit: status = 'steps'
    except interp.Crash as ex: status = 'crash: %s' % ex
    out = {'status': status, 'calls': h.calls, 'mem': h.mem_state(m)}
    if status == 'ok':
        rt = fn.ret
        if rt is not None and rt.kind != 'void' and not hidden:
            n = rt.size; reg = {1: 'L', 2: 'HL', 4: 'XHL'}.get(n)
            out['ret'] = m.get(interp.REGS[reg]) if reg else None
        out['xsp'] = m.r[interp.XSP] - ARGS
        out['xiz'] = m.get(interp.REGS['XIZ'])
    return out

def describe_args(fn, vals):
    return ', '.join('%s=%s' % (p.name, hex(v)) for p, v in zip(fn.params, vals))

def compare(a, b, w):
    """first difference between the model's outcome a and the oracle's b, or None"""
    if a['status'] != b['status']: return 'status: model %s, oracle %s' % (a['status'], b['status'])
    for i, (x, y) in enumerate(zip(a['calls'], b['calls'])):
        if x[0] != y[0]: return 'call %d: model calls %s, oracle %s' % (i + 1, x[0], y[0])
        if x[1] != y[1]: return 'call %d to %s: model args %s, oracle %s' % (i + 1, x[0], fmt(x[1]), fmt(y[1]))
        if x[2] != y[2]:
            return 'call %d to %s: memory differs at the call (%s)' % (i + 1, x[0], memdiff(x[2], y[2], w))
    if len(a['calls']) != len(b['calls']):
        return 'calls: model makes %d, oracle %d' % (len(a['calls']), len(b['calls']))
    if a['status'] != 'ok': return None
    if a.get('ret') != b.get('ret'):
        return 'return value: model 0x%x, oracle 0x%x' % (a['ret'], b['ret'])
    if a['mem'] != b['mem']: return 'memory: %s' % memdiff(a['mem'], b['mem'], w)
    if a['xsp'] != b['xsp']: return 'XSP after return: model +%d, oracle +%d' % (a['xsp'], b['xsp'])
    if a['xiz'] != b['xiz']: return 'XIZ not preserved: model 0x%x, oracle 0x%x' % (a['xiz'], b['xiz'])
    return None

def fmt(args):
    if args is None: return '?'
    return '(' + ', '.join(hex(x) if isinstance(x, int) else str(x) for x in args) + ')'

def memdiff(x, y, w):
    dx, dy = dict(x), dict(y)
    addrs = sorted(set(dx) | set(dy), key=lambda a: (dx.get(a) == dy.get(a), a))
    a = addrs[0]
    f = lambda v: '%02x' % v if v is not None else 'unchanged'
    return '%s: model %s, oracle %s' % (w.sym_name(a), f(dx.get(a)), f(dy.get(a)))

FP_CALL = re.compile(r'\b(cal|call|j)\s+\._f')

def check_function(fn, name, mlines, olines, unit, data_blocks, adecl, trials, limit, seed0):
    """-> ('equal', None) | ('DIFFERENT', reason) | ('not checked', reason)"""
    if mlines is None: return 'not checked', 'model has no code for it'
    if olines is None: return 'not checked', 'no oracle code'
    for side, lines in (('model', mlines), ('oracle', olines)):
        for l in lines:
            if FP_CALL.search(l): return 'not checked', 'calls an FP helper'
            if re.search(r'\bC9H_', l) and not any(h in l for h in HELPERS):
                return 'not checked', 'runtime helper ' + re.search(r'C9H_\w+', l).group(0)
    if adecl and mem_result(fn.ret): return 'not checked', 'adecl memory result'
    w = World(unit, data_blocks)
    try: po = interp.Program(olines, w.symaddr)
    except interp.Unsupported as ex: return 'not checked', 'interp (oracle code): %s' % ex
    try: pm = interp.Program(mlines, w.symaddr)
    except interp.Unsupported as ex:
        msg = str(ex)
        if msg.startswith('undefined label'): return 'DIFFERENT', 'model code uses an %s it never defines' % msg
        return 'not checked', msg if msg.startswith('model:') else 'interp (model code): %s' % msg
    try:
        for p in fn.params: slot_size(p.ty)
        layout([p.ty for p in fn.params], adecl)
    except interp.Unsupported as ex: return 'not checked', str(ex)
    inconclusive = 0; done = 0; ndiff = 0; dmodes = set(); first = None
    modes = ['small', 'edge', 'full', 'small']
    for t in range(trials):
        seed = mix(seed0, name, t); mode = modes[t % 4]
        try:
            outs = []
            for prog in (pm, po):
                tr = Trial(w, seed, mode)
                rng = random.Random(mix(seed, 'args'))
                vals = [tr.arg_value(p.ty, rng) for p in fn.params]
                outs.append(run_one(prog, tr, fn, adecl, vals, limit))
            a, b = outs
            if (a['status'] == 'steps') != (b['status'] == 'steps'):     # one side may just be slower
                outs = []
                for prog in (pm, po):
                    tr = Trial(w, seed, mode); rng = random.Random(mix(seed, 'args'))
                    vals = [tr.arg_value(p.ty, rng) for p in fn.params]
                    outs.append(run_one(prog, tr, fn, adecl, vals, limit * 4))
                a, b = outs
        except interp.Unsupported as ex: return 'not checked', 'interp: %s' % ex
        if a['status'] == 'steps' and b['status'] == 'steps': inconclusive += 1; continue
        d = compare(a, b, w)
        done += 1
        if d:
            ndiff += 1; dmodes.add(mode)
            if first is None: first = '%s [trial %d, %s; %s]' % (d, t, mode, describe_args(fn, vals))
    if first is not None:
        return 'DIFFERENT', '%s; %d of %d trials differ (%s)' % (first, ndiff, done, '/'.join(
            x for x in ('small', 'edge', 'full') if x in dmodes))
    if done == 0: return 'not checked', 'step limit on every trial'
    return 'equal', None

def data_blocks_of(want, unit):
    """symbol -> {offset: byte}: the global variables a listing defines (db/dw/dl lines under the symbol)"""
    fnames = {'_' + f.name for f in unit.functions} | {'.' + f.name for f in unit.functions}
    out = {}
    for name, lines in want.items():
        if name in fnames: continue
        body = [l for l in lines[1:] if 'section' not in l]
        if not body or not all(l.split()[0] in ('db', 'dw', 'dl', 'dd', 'align', 'fdatad', 'ds') for l in body): continue
        try:
            p = interp.Program([name + 'x__:'] + body, lambda s: 0, data_base=0)
        except Exception: continue
        out[name] = dict(p.data)
    return out

# ---------------------------------------------------------------- driving

def run_set(odir, files, opt, adecl, personality, defines, incs, trials, limit, only=None, verbose=False, seed0=1):
    """-> list of (file, function, verdict, reason)"""
    import score
    res = []
    for f in files:
        op = score.oracle_path(odir, f)
        if not os.path.exists(op): continue
        want = listing.split(open(op, encoding='latin-1').read())
        try: unit = frontend.load(f, defines, incs, adecl=adecl)
        except Exception as ex:
            res.append((os.path.basename(f), '*', 'not checked', 'front end failed')); continue
        got = codegen.compile_unit(unit, opt=opt, adecl=adecl, personality=personality)
        blocks = data_blocks_of(want, unit)
        for fn in unit.functions:
            fa = adecl or getattr(fn, 'adecl_attr', False)
            name = ('.' if fa else '_') + fn.name
            if only and fn.name not in only: continue
            try:
                v, why = check_function(fn, name, got.get(name), want.get(name), unit, blocks, fa, trials, limit, seed0)
            except Exception as ex:
                v, why = 'not checked', 'semcheck error: %s: %s' % (type(ex).__name__, str(ex)[:80])
            res.append((os.path.basename(f), name, v, why))
            if verbose: print('  %-24s %-24s %s %s' % (os.path.basename(f), name, v, why or ''))
    return res

def summarise(res):
    c = {'equal': 0, 'DIFFERENT': 0, 'not checked': 0}
    for _, _, v, _ in res: c[v] += 1
    return c

def ledger_rows(all_compilers, library=False):
    text = open(os.path.join(HERE, 'ledger.sh')).read()
    text = re.sub(r'^row\(\) \{.*\}$', lambda _: "row() { printf '%s\\037' \"$@\"; printf '\\036'; }", text,
                  count=1, flags=re.M)
    r = subprocess.run(['sh', '-c', text], cwd=CC900, capture_output=True, text=True)
    rows = []
    for rec in r.stdout.split('\x1e'):
        f = [x for x in rec.split('\x1f')]
        if len(f) < 4: continue
        f = f[:-1] if f[-1] == '' else f
        label, corpus, rest = f[0], f[1], f[2:]
        lib = library and corpus == '1997 LIB/SRC'         # --library: the 1997 library row too (V4.23's personality)
        if not corpus.startswith(('micro/', 'probes/')) and not lib: continue
        odir = rest[0]; files = []; opts = rest[1:]
        if lib and _arg(opts, '--personality', 'v4.23') != 'v4.23': continue
        while opts and not opts[0].startswith('-'): files.append(opts.pop(0))
        if not all_compilers and '/v423/' not in odir: continue
        opt = _arg(opts, '--opt'); adecl = '--adecl' in opts; pers = _arg(opts, '--personality', 'v4.23')
        base = os.path.basename(os.path.normpath(odir))
        if base in ('micro', 'probes'): base = os.path.basename(os.path.dirname(os.path.normpath(odir)))
        if opt is None: opt = 'O3XS' if base.startswith('O3XS') else 'none'
        if base.endswith('Xr'): adecl = True
        sets = base
        rows.append(dict(label=label, corpus=corpus, odir=odir, files=[os.path.join(CC900, x) for x in files],
                         opt=opt, adecl=adecl, personality=pers, optset=sets,
                         defines=[x[2:] for x in opts if x.startswith('-D')],
                         incs=[x[2:] for x in opts if x.startswith('-I')]))
    return rows

def table(header, rows):
    w = [max(len(str(r[i])) for r in [header] + rows) for i in range(len(header))]
    line = lambda r: '| ' + ' | '.join(str(c).ljust(w[i]) for i, c in enumerate(r)) + ' |'
    return '\n'.join([line(header), '|' + '|'.join('-' * (x + 2) for x in w) + '|'] + [line(r) for r in rows])

def main():
    a = ARGV
    trials = int(_arg(a, '--trials', 48)); limit = int(_arg(a, '--limit', LIMIT))
    only = set(_arg(a, '--only').split(',')) if '--only' in a else None
    verbose = '--verbose' in a
    if '--ledger' in a:
        rows = ledger_rows('--all-compilers' in a, '--library' in a)
        seen = set(); table_rows = []; diffs = []; totals = {}; reasons = {}; todo = []
        for r in rows:
            key = (r['odir'], tuple(r['files']), r['opt'], r['adecl'], r['personality'])
            if key in seen: continue
            seen.add(key); todo.append(r)
        jobs = int(_arg(a, '--jobs', 1))
        work = [(r['odir'], r['files'], r['opt'], r['adecl'], r['personality'], r['defines'], r['incs'],
                 trials, limit, only, verbose) for r in todo]
        if jobs > 1:
            import multiprocessing
            with multiprocessing.Pool(jobs) as pool: results = pool.starmap(run_set, work, chunksize=1)
        else: results = [run_set(*w) for w in work]
        for r, res in zip(todo, results):
            c = summarise(res); n = c['equal'] + c['DIFFERENT']
            run = r['label'].split(',')[0].replace('run ', '')
            comp = r['label'].split(',')[1].strip().split()[0]
            table_rows.append([run, comp, r['corpus'], n, c['equal'], c['DIFFERENT'], c['not checked']])
            t = totals.setdefault(comp, [0, 0, 0, 0])
            t[0] += n; t[1] += c['equal']; t[2] += c['DIFFERENT']; t[3] += c['not checked']
            for f, fn, v, why in res:
                if v == 'DIFFERENT': diffs.append([f, comp, fn, why])
                if v == 'not checked':
                    k = re.sub(r'(0x[0-9a-f]+|\d+)', 'N', why.split(':')[0] if why.startswith('interp') else why)[:70]
                    reasons[(comp, k)] = reasons.get((comp, k), 0) + 1
            print('%-44s %-12s %-22s checked %4d  equal %4d  DIFFERENT %3d  not checked %3d' % (
                run, comp, r['corpus'], n, c['equal'], c['DIFFERENT'], c['not checked']), flush=True)
        print()
        for comp, t in totals.items():
            print('TOTAL %-14s checked %5d  equal %5d  DIFFERENT %4d  not checked %4d' % (comp, *t))
        for d in diffs: print('DIFFERENT %s %s %s: %s' % tuple(d))
        out = _arg(a, '--results')
        if out:
            write_results(out, table_rows, totals, diffs, reasons, trials, limit)
        sys.exit(1 if diffs else 0)
    opt = _arg(a, '--opt'); adecl = '--adecl' in a; personality = _arg(a, '--personality', 'v4.23')
    defines = [x[2:] for x in a if x.startswith('-D')]; incs = [x[2:] for x in a if x.startswith('-I')]
    vals = ('--opt', '--personality', '--trials', '--limit', '--only', '--model-dir', '--results', '--jobs')
    pos = [x for i, x in enumerate(a) if not x.startswith('-') and (i == 0 or a[i - 1] not in vals)]
    odir, files = pos[0], pos[1:]
    base = os.path.basename(os.path.normpath(odir))
    if base in ('micro', 'probes'): base = os.path.basename(os.path.dirname(os.path.normpath(odir)))
    if opt is None: opt = 'O3XS' if base.startswith('O3XS') else 'none'
    if base.endswith('Xr'): adecl = True
    anydiff = False
    for f in files:
        res = run_set(odir, [f], opt, adecl, personality, defines, incs, trials, limit, only, verbose)
        c = summarise(res)
        print('%-24s %-8s checked %3d  equal %3d  DIFFERENT %3d  not checked %3d' % (
            os.path.basename(f), base, c['equal'] + c['DIFFERENT'], c['equal'], c['DIFFERENT'], c['not checked']))
        for fl, fn, v, why in res:
            if v == 'DIFFERENT': anydiff = True; print('  DIFFERENT %s: %s' % (fn, why))
            elif v == 'not checked' and verbose is False and '--why' in a: print('  not checked %s: %s' % (fn, why))
    sys.exit(1 if anydiff else 0)

def load_review():
    """(file, compiler/set or '*', function) -> note, from semcheck_review.tsv (tab-separated, '#' comments)"""
    out = {}
    p = os.path.join(HERE, 'semcheck_review.tsv')
    if not os.path.exists(p): return out
    for l in open(p):
        if not l.strip() or l.startswith('#'): continue
        f = l.rstrip('\n').split('\t')
        for fn in f[2].split(','): out[(f[0], f[1], fn.strip())] = f[3]
    return out

def write_results(path, table_rows, totals, diffs, reasons, trials, limit):
    rev = subprocess.run(['git', '-C', HERE, 'log', '-1', '--format=%h'], capture_output=True, text=True).stdout.strip()
    L = ['# cc900 model: semantic check against the oracle', '',
         'Generated by `python3 -I -B model/semcheck.py --ledger --results results/semcheck.md` (from',
         '`scripts/analysis/cc900`; `model/semcheck.md` says what it checks).  Model revision: the working tree at '
         'commit %s; %d trials per function, %d-step limit.  "checked" = equal + DIFFERENT.' % (rev, trials, limit), '',
         '## Per oracle row', '',
         table(['run', 'compiler/set', 'corpus', 'checked', 'equal', 'DIFFERENT', 'not checked'], table_rows), '',
         '## Totals per option set', '',
         table(['compiler/set', 'checked', 'equal', 'DIFFERENT', 'not checked'], [[k] + v for k, v in totals.items()]),
         '', '## DIFFERENT functions', '',
         'The first differing output on the first trial that differs.  No code is quoted.', '']
    review = load_review()
    def rv(d):
        for k in ((d[0], d[1], d[2]), (d[0], '*', d[2])):
            if k in review: return review[k]
        return 'not reviewed'
    L += ['The review column is `model/semcheck_review.tsv`: what reading both listings showed.  "wrong code" = the',
          "model's code is wrong C; \"UB only\" = the inputs that differ make the C undefined (signed overflow);",
          '"oracle narrows" = the oracle does int arithmetic on a char in the byte and the model does not.', '']
    L.append(table(['file', 'compiler/set', 'function', 'first difference', 'review'], [d + [rv(d)] for d in diffs])
             if diffs else 'None.')
    L += ['', '## Not checked, by reason', '',
          table(['compiler/set', 'reason', 'functions'], [[k[0], k[1], v] for k, v in sorted(reasons.items())])
          if reasons else 'None.', '']
    open(path, 'w').write('\n'.join(L))

if __name__ == '__main__':
    main()
