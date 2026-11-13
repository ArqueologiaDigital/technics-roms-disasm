"""Two on-disk caches for the tools that run the model (score.py, semcheck.py, pairs_model.py), so that one round
compiles every source once instead of once per tool:

- the front end's result for a C file (frontend.load: clang's AST built into a Unit), keyed by the file, its defines
  and include directories, the convention, the clang binary and frontend.py;
- the model's listings for a C file at one option set (codegen.compile_unit and what it leaves in codegen.FULL), keyed
  by the front-end key, the options and the code of every model module (so the working tree and a scratch copy with
  the same code share entries, and any edit to the model misses).

Both live under the directory the environment variable CC900_CACHE names; without it nothing is cached and the tools
behave as before.  The directory is scratch: delete it to start cold.  Entries are written to a temporary name and
renamed, so parallel rows may race for one entry without harm.

    unit = cache.load(path, defines, incs, adecl)
    unit, got = cache.compile(path, defines, incs, opt, adecl, personality)

A unit that comes with a cached listing has not been through compile_unit (which prepends the hidden __sret
parameter); semcheck's c_params accepts both."""
import os, sys, hashlib, pickle

HERE = os.path.dirname(os.path.abspath(__file__))
TOOLS = ('cache.py', 'score.py', 'semcheck.py', 'interp.py', 'pairs_model.py', 'test_interp.py', 'to_llvm.py')
_model = None; _sigs = {}; _last = []


def root(): return os.environ.get('CC900_CACHE') or None


def _sha(*parts):
    h = hashlib.sha256()
    for p in parts: h.update(hashlib.sha256(p if isinstance(p, bytes) else repr(p).encode()).digest())
    return h.hexdigest()


def model_hash():
    """the code of the model: every .py beside this file except the tools that only read its output"""
    global _model
    if _model is None:
        _model = _sha(*[open(os.path.join(HERE, n), 'rb').read() for n in sorted(os.listdir(HERE))
                        if n.endswith('.py') and n not in TOOLS])
    return _model


def _file_sig(p):
    if p not in _sigs:
        try: st = os.stat(p); _sigs[p] = (st.st_size, st.st_mtime_ns)
        except OSError: _sigs[p] = None
    return _sigs[p]


def _dir_sig(d):
    if d not in _sigs:
        try: _sigs[d] = sorted((n, _file_sig(os.path.join(d, n))) for n in os.listdir(d))
        except OSError: _sigs[d] = None
    return _sigs[d]


def src_key(path, defines, incs, adecl):
    import frontend
    return _sha(open(path, 'rb').read(), sorted(defines), [(i, _dir_sig(i)) for i in incs], bool(adecl),
                (frontend.CLANG, _file_sig(frontend.CLANG)), open(os.path.join(HERE, 'frontend.py'), 'rb').read(),
                os.path.dirname(os.path.abspath(path)) if b'\x1a' in open(path, 'rb').read() else '')


def _get(kind, key):
    p = os.path.join(root(), kind, key[:2], key)
    try:
        with open(p, 'rb') as fh: return pickle.load(fh)
    except Exception: return None


def _put(kind, key, value):
    d = os.path.join(root(), kind, key[:2])
    try:
        os.makedirs(d, exist_ok=True)
        tmp = os.path.join(d, '%s.%d.tmp' % (key, os.getpid()))
        with open(tmp, 'wb') as fh: pickle.dump(value, fh, pickle.HIGHEST_PROTOCOL)
        os.replace(tmp, os.path.join(d, key))
    except Exception: pass                                   # (a cache that cannot be written is only slower)


def load(path, defines=(), incs=(), adecl=False):
    import frontend
    if not root():                          # (score.py loads, then compiles: the second call takes the first's unit)
        memo = (path, tuple(defines), tuple(incs), bool(adecl))
        if _last and _last[0] == memo:
            unit = _last[1]; del _last[:]; return unit
        unit = frontend.load(path, defines, incs, adecl=adecl)
        _last[:] = [memo, unit]
        return unit
    sys.setrecursionlimit(max(sys.getrecursionlimit(), 200000))
    key = src_key(path, defines, incs, adecl)
    unit = _get('ast', key)
    if unit is None:
        unit = frontend.load(path, defines, incs, adecl=adecl)
        _put('ast', key, unit)
    return unit


def compile(path, defines=(), incs=(), opt='none', adecl=False, personality='v4.23'):
    """-> (unit, {function name: lines}); codegen.FULL is filled as compile_unit fills it"""
    import codegen, fpgen
    unit = load(path, defines, incs, adecl)
    fpgen.FCONST[0] = 50000                 # the S labels of a file do not depend on the files compiled before it
    if not root(): return unit, codegen.compile_unit(unit, opt=opt, adecl=adecl, personality=personality)
    key = _sha(src_key(path, defines, incs, adecl), model_hash(), opt, bool(adecl), personality)
    hit = _get('out', key)
    if hit is not None:
        got, full = hit
        codegen.FULL.update(full); return unit, got
    before = dict(codegen.FULL)
    got = codegen.compile_unit(unit, opt=opt, adecl=adecl, personality=personality)
    _put('out', key, (got, {n: v for n, v in codegen.FULL.items() if before.get(n) is not v}))
    return unit, got
