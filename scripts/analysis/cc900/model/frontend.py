"""cc900 reference model, front end: clang's AST (JSON) to a small tree with cc900's types.

The model (notes/cc900-compat-plan-2026-11-08/phase0.md, section 4) reads what thc1 reads: the syntax tree.  clang
parses the C (`clang -target tlcs900 -std=c89 -ast-dump=json -fsyntax-only`); this module keeps only what the
code generator needs and gives every type cc900's size and alignment (abi.md: 16-bit int, alignment capped at 2,
structs rounded up to an even size).  clang's own type widths are ignored: types are re-read from their spelling.
"""
import json, os, re, subprocess

CLANG = os.environ.get('CC900_MODEL_CLANG', os.path.expanduser('~/compartilhado/llvm-project/build/bin/clang'))

# ---------------------------------------------------------------- types

class Type:
    def __init__(s, kind, size, align, signed=False, base=None, count=None, rec=None, ret=None, params=None, spell=''):
        s.kind, s.size, s.align, s.signed = kind, size, align, signed     # kind: int float ptr array struct void func
        s.base, s.count, s.rec, s.ret, s.params, s.spell = base, count, rec, ret, params, spell
    def is_int(s): return s.kind == 'int'
    def is_ptr(s): return s.kind in ('ptr', 'array')
    def __repr__(s): return 'T(%s)' % s.spell

SCALARS = {
    'char': ('int', 1, True), 'signed char': ('int', 1, True), 'unsigned char': ('int', 1, False),
    'short': ('int', 2, True), 'unsigned short': ('int', 2, False), 'int': ('int', 2, True),
    'unsigned int': ('int', 2, False), 'long': ('int', 4, True), 'unsigned long': ('int', 4, False),
    'float': ('float', 4, True), 'double': ('float', 8, True), 'long double': ('float', 10, True),
    '_Bool': ('int', 1, False),
}
ALIASES = {'short int': 'short', 'unsigned short int': 'unsigned short', 'long int': 'long',
           'unsigned long int': 'unsigned long', 'signed int': 'int', 'unsigned': 'unsigned int', 'signed': 'int',
           'signed short': 'short', 'signed long': 'long'}

class Records:
    """struct/union layouts, filled from RecordDecl nodes"""
    def __init__(s): s.recs = {}
    def layout(s, name, fields, union=False):
        off = 0; size = 0; out = []
        for fname, ft in fields:
            a = min(ft.align, 2)
            if union: o = 0
            else:
                off = (off + a - 1) // a * a; o = off; off += ft.size
            out.append((fname, ft, o)); size = max(size, o + ft.size)
        size = (size + 1) // 2 * 2
        s.recs[name] = (out, max(size, 2))

def parse_type(spell, recs, typedefs):
    t = spell.strip()
    t = re.sub(r'\b(const|volatile|__restrict|restrict)\b', '', t).strip()
    cdecl = 'tlcs900_cdecl' in t                             # a __cdecl function called from an adecl file (c_lib)
    t = re.sub(r'__attribute__\(\(tlcs900_[ac]decl\)\)', '', t).strip()
    t = re.sub(r'\s+', ' ', t)
    m = re.match(r'^(.*)\((\*+)\)\s*\((.*)\)$', t)          # pointer to function
    if m:
        return Type('ptr', 4, 2, base=Type('func', 0, 1, spell=t), spell=spell)
    m = re.match(r'^(.*?)\s*\((.*)\)$', t)                   # function type
    if m and not t.endswith('*'):
        ft = Type('func', 0, 1, ret=parse_type(m.group(1), recs, typedefs), spell=spell); ft.cdecl = cdecl
        return ft
    m = re.match(r'^(.*)\[(\d*)\]$', t)
    if m:
        b = parse_type(m.group(1), recs, typedefs); n = int(m.group(2) or 0)
        return Type('array', b.size * n, b.align, base=b, count=n, spell=spell)
    if t.endswith('*'):
        return Type('ptr', 4, 2, base=parse_type(t[:-1], recs, typedefs), spell=spell)
    t = ALIASES.get(t, t)
    if t in SCALARS:
        k, sz, sg = SCALARS[t]; return Type(k, sz, min(sz, 2), signed=sg, spell=spell)
    if t == 'void': return Type('void', 0, 1, spell=spell)
    m = re.match(r'^(struct|union) (\w+)$', t)
    if m:
        fields, size = recs.recs.get(m.group(2), ([], 2))
        return Type('struct', size, 2, rec=fields, spell=spell)
    if t.startswith('enum '): return Type('int', 2, 2, signed=True, spell=spell)
    if t in typedefs: return parse_type(typedefs[t], recs, typedefs)
    raise ValueError('unknown type %r' % spell)

# ---------------------------------------------------------------- tree

class N:
    def __init__(s, k, **kw): s.k = k; s.__dict__.update(kw)
    def __repr__(s):
        return '%s(%s)' % (s.k, ', '.join('%s=%r' % kv for kv in s.__dict__.items() if kv[0] not in ('k', 'node')))

class Decl:
    def __init__(s, name, ty, storage, kind):   # kind: param local global func
        s.name, s.ty, s.storage, s.kind = name, ty, storage, kind
        s.addr_taken = False; s.uses = 0
    def __repr__(s): return 'Decl(%s %s)' % (s.kind, s.name)

class Function:
    def __init__(s, name, ret, params, body, decls):
        s.name, s.ret, s.params, s.body, s.decls = name, ret, params, body, decls

class Unit:
    def __init__(s): s.functions = []; s.globals = []; s.decls = {}

PSEUDO_REGS = ('XWA', 'XBC', 'XDE', 'XHL', 'XIX', 'XIY', 'XIZ', 'WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ', 'A', 'L')

CLEAN_DIRS = {}

def clean_include_dir(d):
    """an include directory whose headers end in a DOS end-of-file byte (V4.23's errno.h) is mirrored, once per
    process, under $TMPDIR with each file cut at that byte; others are used as they are"""
    d = os.path.abspath(d)
    if d in CLEAN_DIRS: return CLEAN_DIRS[d]
    names = [n for n in os.listdir(d) if os.path.isfile(os.path.join(d, n))] if os.path.isdir(d) else []
    if not any(b'\x1a' in open(os.path.join(d, n), 'rb').read() for n in names):
        CLEAN_DIRS[d] = d; return d
    import tempfile, atexit, shutil
    m = tempfile.mkdtemp(prefix='cc900-inc-')
    atexit.register(shutil.rmtree, m, True)
    for n in os.listdir(d):
        q = os.path.join(d, n)
        if os.path.isfile(q):
            data = open(q, 'rb').read()
            open(os.path.join(m, n), 'wb').write(data[:data.index(b'\x1a')] if b'\x1a' in data else data)
    CLEAN_DIRS[d] = m; return m

def load(path, defines=(), includes=(), adecl=False):
    """adecl=True parses as cc900 -Xr does: clang's -mcc900-adecl, so that only an explicit __cdecl function type
    carries tlcs900_cdecl (without it every function type is spelt with it)"""
    cmd = [CLANG, '-target', 'tlcs900', '-mabi=cc900', '-std=c89', '-fsyntax-only', '-Xclang', '-ast-dump=json',
           '-Wno-everything', '-D__cdecl=__attribute__((tlcs900_cdecl))', '-D__adecl=__attribute__((tlcs900_adecl))']
    if adecl: cmd.append('-mcc900-adecl')
    # cc900's inline assembly and pseudo-registers (LIB/SRC): __ASM("...") is kept as an asm statement, and the
    # registers __XHL, __HL ... become variables whose names the code generator recognises
    defines = [d if d not in ('__ASM(x)=',) else '__ASM(x)=__cc900_asm(x)' for d in defines]
    import tempfile
    fdh, hdr = tempfile.mkstemp(suffix='.h')
    os.write(fdh, ('extern void __cc900_asm(const char *);\n' + ''.join('extern %s __%s;\n' % (
        'unsigned long' if r.startswith('X') else 'unsigned int' if len(r) == 2 else 'unsigned char', r)
        for r in PSEUDO_REGS)).encode()); os.close(fdh)
    cmd += ['-include', hdr]
    src = path
    data = open(path, 'rb').read()
    if b'\x1a' in data:                                   # a DOS end-of-file byte (_STRLEN.C, _MEMCPY.C ...): cut there
        import tempfile
        fd, src = tempfile.mkstemp(suffix='.c'); os.write(fd, data[:data.index(b'\x1a')]); os.close(fd)
        includes = list(includes) + [os.path.dirname(os.path.abspath(path))]
    includes = [clean_include_dir(i) for i in includes]
    cmd += ['-D' + d for d in defines] + ['-I' + i for i in includes] + ['-x', 'c', src]
    try:
        r = subprocess.run(cmd, capture_output=True, text=True)
        if r.returncode and 'conflicting types' in r.stderr:   # _MEMCPY.C: memcpy(void *, void *, ...) against
            r = subprocess.run(cmd[:-3] + ['-Dconst='] + cmd[-3:], capture_output=True, text=True)   # string.h's const
        if r.returncode: raise subprocess.CalledProcessError(r.returncode, cmd, r.stdout, r.stderr)
        ast = json.loads(r.stdout)
    finally:
        if src != path: os.unlink(src)
        os.unlink(hdr)
    return Builder(path).unit(ast)

class Builder:
    def __init__(s, path):
        s.path = os.path.abspath(path); s.recs = Records(); s.typedefs = {}; s.decls = {}

    def ty(s, node):
        q = node.get('type', {})
        t = q.get('desugaredQualType', q.get('qualType', 'int'))
        if re.search(r'(struct|union) \([^)]*(unnamed|anonymous)[^)]*\)', t) and getattr(s, 'last_anon', None):
            t = re.sub(r'(struct|union) \([^)]*(unnamed|anonymous)[^)]*\)', s.last_anon, t)   # _ldexp: a local
        return parse_type(t, s.recs, s.typedefs)                                           # union { ... } d;

    def record(s, n):
        fields = [(f['name'], s.ty(f)) for f in n.get('inner', []) if f.get('kind') == 'FieldDecl']
        name = n.get('name', 'anon%s' % n['id'])
        s.recs.layout(name, fields, n.get('tagUsed') == 'union')
        if 'name' not in n: s.last_anon = '%s %s' % ('union' if n.get('tagUsed') == 'union' else 'struct', name)

    def unit(s, ast):
        u = Unit()
        for n in ast.get('inner', []):
            k = n.get('kind')
            if k == 'TypedefDecl' and 'name' in n:
                q = n['type'].get('desugaredQualType', n['type']['qualType'])
                if (q == n['name'] or 'unnamed' in q or 'anonymous' in q) and getattr(s, 'last_anon', None):
                    q = s.last_anon                          # typedef union { ... } DBLBIT; (FLOAT.H)
                s.typedefs[n['name']] = q
            elif k == 'RecordDecl' and n.get('completeDefinition'):
                fields = [(f['name'], s.ty(f)) for f in n.get('inner', []) if f.get('kind') == 'FieldDecl']
                name = n.get('name', 'anon%s' % n['id'])
                s.recs.layout(name, fields, n.get('tagUsed') == 'union')
                if 'name' not in n: s.last_anon = '%s %s' % ('union' if n.get('tagUsed') == 'union' else 'struct', name)
            elif k == 'VarDecl':
                d = Decl(n['name'], s.ty(n), n.get('storageClass', ''), 'global')
                d.init = n.get('inner'); s.decls[n['id']] = d; u.decls[n['name']] = d
                q = n['type']['qualType']                        # const object: f_const (globals.c c_val, c_str)
                d.const = (q.startswith('const ') and '*' not in q) or q.rstrip().endswith('const')
                d.init_expr = None
                if d.init:
                    try: d.init_expr = s.expr(d.init[0])
                    except Exception: d.init_expr = None
                if n.get('storageClass') != 'extern': u.globals.append(d)
            elif k == 'FunctionDecl':
                d = Decl(n['name'], s.ty(n), n.get('storageClass', ''), 'func'); s.decls[n['id']] = d
                d.implicit = bool(n.get('isImplicit'))           # no prototype in scope (implicit or builtin)
                u.decls[n['name']] = d
                body = [c for c in n.get('inner', []) if c.get('kind') == 'CompoundStmt']
                if body:
                    s.fdecls = []
                    params = []
                    for c in n.get('inner', []):
                        if c.get('kind') == 'ParmVarDecl':
                            pd = Decl(c.get('name', ''), s.ty(c), '', 'param'); s.decls[c['id']] = pd
                            params.append(pd); s.fdecls.append(pd)
                    tree = s.stmt(body[0])
                    fn = Function(n['name'], d.ty.ret, params, tree, s.fdecls)
                    fn.adecl_attr = 'tlcs900_adecl' in n.get('type', {}).get('qualType', '')   # __SBRK.C: __adecl sbrk
                    u.functions.append(fn)
        return u

    def stmt(s, n):
        k = n['kind']; I = n.get('inner', [])
        if k == 'CompoundStmt': return N('block', body=[s.stmt(c) for c in I])
        if k == 'DeclStmt':
            out = []
            for v in I:
                if v.get('kind') == 'RecordDecl' and v.get('completeDefinition'): s.record(v); continue
                if v.get('kind') != 'VarDecl': continue
                d = Decl(v['name'], s.ty(v), v.get('storageClass', ''), 'local' if v.get('storageClass') != 'static' else 'static')
                s.decls[v['id']] = d; s.fdecls.append(d)
                out.append(N('decl', var=d, init=s.expr(v['inner'][0]) if v.get('inner') else None))
            return N('block', body=out)
        if k == 'IfStmt':
            return N('if', cond=s.expr(I[0]), then=s.stmt(I[1]), els=s.stmt(I[2]) if len(I) > 2 else None)
        if k == 'WhileStmt': return N('while', cond=s.expr(I[0]), body=s.stmt(I[1]))
        if k == 'DoStmt': return N('do', body=s.stmt(I[0]), cond=s.expr(I[1]))
        if k == 'ForStmt':
            # clang's ForStmt children: init, condVar (empty {}), cond, inc, body
            parts = [c if c else None for c in I]
            init, cond, inc, body = parts[0], parts[2], parts[3], parts[4]
            return N('for', init=s.stmt(init) if init and init.get('kind') else None,
                     cond=s.expr(cond) if cond and cond.get('kind') else None,
                     inc=s.expr(inc) if inc and inc.get('kind') else None, body=s.stmt(body))
        if k == 'ReturnStmt': return N('return', value=s.expr(I[0]) if I else None)
        if k == 'BreakStmt': return N('break')
        if k == 'ContinueStmt': return N('continue')
        if k == 'NullStmt': return N('block', body=[])
        if k == 'SwitchStmt': return N('switch', value=s.expr(I[0]), body=s.stmt(I[1]))
        if k == 'CaseStmt': return N('case', value=s.expr(I[0]), body=s.stmt(I[1]) if len(I) > 1 else None)
        if k == 'DefaultStmt': return N('default', body=s.stmt(I[0]) if I else None)
        if k == 'LabelStmt': return N('label', name=n['name'], decl=n.get('declId'), body=s.stmt(I[0]))
        if k == 'GotoStmt': return N('goto', target=n.get('targetLabelDeclId'))
        return N('expr', e=s.expr(n))

    def expr(s, n):
        k = n['kind']; I = n.get('inner', []); t = s.ty(n) if 'type' in n else None
        if k in ('ParenExpr',): return s.expr(I[0])
        if k == 'IntegerLiteral': return N('const', value=int(n['value']), ty=t)
        if k == 'CharacterLiteral': return N('const', value=int(n['value']), ty=t)
        if k == 'FloatingLiteral': return N('fconst', value=float(n['value']), ty=t)
        if k == 'StringLiteral': return N('string', value=n['value'], ty=t)
        if k == 'DeclRefExpr':
            d = s.decls.get(n['referencedDecl']['id'])
            if d is None:
                d = Decl(n['referencedDecl'].get('name', '?'), t, '', 'func'); s.decls[n['referencedDecl']['id']] = d
                d.implicit = True                                # declared nowhere in the file: implicit
            d.uses += 1
            return N('var', decl=d, ty=t)
        if k == 'ImplicitCastExpr' or k == 'CStyleCastExpr':
            ck = n.get('castKind')
            e = s.expr(I[0])
            if ck == 'LValueToRValue': return N('load', e=e, ty=t)
            if ck in ('NoOp', 'FunctionToPointerDecay', 'ArrayToPointerDecay', 'BitCast', 'ToVoid'):
                return N('decay' if ck == 'ArrayToPointerDecay' else 'noop', e=e, ty=t)
            return N('cast', kind=ck, e=e, ty=t)
        if k == 'BinaryOperator':
            l, r = s.expr(I[0]), s.expr(I[1])
            if n['opcode'] == '-' and l.ty is not None and r.ty is not None and l.ty.kind in ('ptr', 'array') \
                    and r.ty.kind in ('ptr', 'array'):
                t = parse_type('long', s.recs, s.typedefs)   # cc900's ptrdiff_t is long (abi.md)
            return N('bin', op=n['opcode'], l=l, r=r, ty=t)
        if k == 'CompoundAssignOperator':
            return N('opassign', op=n['opcode'][:-1], l=s.expr(I[0]), r=s.expr(I[1]), ty=t,
                     cty=parse_type(n['computeResultType']['qualType'], s.recs, s.typedefs))
        if k == 'UnaryOperator':
            op = n['opcode']; e = s.expr(I[0])
            if op in ('++', '--'): return N('incdec', op=op, post=n.get('isPostfix', False), e=e, ty=t)
            if op == '&':
                if e.k == 'var': e.decl.addr_taken = True
                return N('addr', e=e, ty=t)
            if op == '*': return N('deref', e=e, ty=t)
            return N('un', op=op, e=e, ty=t)
        if k == 'ArraySubscriptExpr': return N('index', base=s.expr(I[0]), idx=s.expr(I[1]), ty=t)
        if k == 'MemberExpr':
            return N('member', base=s.expr(I[0]), name=n['name'], arrow=n.get('isArrow', False), ty=t)
        if k == 'CallExpr': return N('call', fn=s.expr(I[0]), args=[s.expr(c) for c in I[1:]], ty=t)
        if k == 'ConditionalOperator': return N('cond', c=s.expr(I[0]), a=s.expr(I[1]), b=s.expr(I[2]), ty=t)
        if k == 'UnaryExprOrTypeTraitExpr':
            if n.get('name') == 'sizeof':                # cc900 sizes: sizeof(type) or sizeof expr
                if 'argType' in n:
                    at = n['argType']; size = parse_type(at.get('desugaredQualType', at['qualType']), s.recs, s.typedefs).size
                else:
                    size = s.ty(I[0]).size
                return N('const', value=size, ty=t)
            return N('const', value=None, sizeof=n.get('argType', {}).get('qualType'), ty=t)
        if k == 'ConstantExpr': return s.expr(I[0])
        if k == 'InitListExpr':                          # _CTYPE.C; a partly initialised array lists its elements
            items = I if I else n.get('array_filler', [])[1:]   # after the filler under array_filler
            return N('initlist', items=[s.expr(c) for c in items], ty=t)
        if k == 'ImplicitValueInitExpr': return N('const', value=0, ty=t)
        raise ValueError('unsupported expression %s' % k)
