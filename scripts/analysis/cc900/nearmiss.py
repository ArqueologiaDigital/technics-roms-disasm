#!/usr/bin/env python3
"""Near-miss index: how close did each C attempt V4.23 compiled come to the ROM, and why not closer?

QUESTION ANSWERED: for every function of every V4.23 run of our firmware C (the private oracle repository's
runs/<run>/out/v423/<option label>/<source>.asm), does the listing, taken through model/to_llvm.py into our llvm-mc
syntax (asm_vs_rom.py's chain: the listing's own operand widths, the build's local-label renaming and jr / jrl
relaxation), give the ROM's bytes at the function's address?  If not: how many bytes agree, where the first
difference is, and which kinds of difference an instruction-level diff of our translation against the ROM's
disassembly finds (CLASSES below; several per function).  Nothing Toshiba wrote is copied: the index holds names,
offsets, counts, class names and paths only.

usage (from the repository root or anywhere):
  python3 -B scripts/analysis/cc900/nearmiss.py [--runs-re REGEX | --runs RUN,RUN] [--oracle DIR]
          [--src-root DIR] [--model-root DIR] [--out DIR] [--near PCT] [--jobs N]
      index the runs (default: every run whose name has -p6-, -sub- or -hd-) and write OUT/index.tsv, OUT/README.md
      and the near-miss C copies OUT/c/<tree>/<function>__<sha8>.c.  --add-new: only the runs runs.tsv lacks,
      their rows added to the existing index (the hourly refresh).
  python3 -B scripts/analysis/cc900/nearmiss.py --recheck [--class CLASS] [--all] [--update] [--verbose]
          [--status STATUS[,STATUS]] [--no-derive-module] [same options]
      no VM: re-translate the listings of the indexed near misses (--all: every attempt but MATCH, ERR-name and
      ERR-dup; --status: the attempts of those statuses, any of them; --class: only those with that class) with the
      CURRENT translator and compare again.  The C is the
      run's corpus file when it still has the index's sha256, else the near-miss copies.  Each C's `cc900-module:`
      line is derived from the built image by module_calls.py's rule (derive_module).  Writes OUT/ready.tsv: per
      lane, the functions that now MATCH with their C copy (written if missing) and module line.  --update rewrites
      index.tsv and README.md.
  python3 -B scripts/analysis/cc900/nearmiss.py --readme [same options]
      README.md again from index.tsv and runs.tsv (nothing re-translated).
  python3 -B scripts/analysis/cc900/nearmiss.py --ready [same options]
      OUT/ready.tsv again from index.tsv: every MATCH not yet built from C in the src-root's tree, per lane, with a
      C copy and its own cc900-module line (also written by a full index run and by --recheck --update).
  python3 -B scripts/analysis/cc900/nearmiss.py --explain LISTING FUNCTION [same options]
      print one function's alignment, our translation beside the ROM, both as llvm-objdump reads them (LISTING as
      the index's `listing` column).  For the terminal only: never paste it into the repository.

--src-root   the checkout whose trees, symbols references, original_ROMs, rebuilt_ROMs/*.elf and
             scripts/build/cc900_firmware_c.py name the functions (default: this repository).  When its build has
             cc900-module support (module_names), each function is translated by the build's own finish() (runtime
             names, call relaxation, out-of-reach fallback, f_const placement) and linked at its ROM address; --model-root the checkout whose scripts/analysis/cc900/model
             (to_llvm.py, listing.py) translates (default: --src-root).  A ROM missing there (the git-ignored v6 / v5
             references) is read from the main checkout ~/compartilhado/technics-roms-disasm.
--near PCT   a non-matching attempt is a NEAR miss when at least PCT % of the ROM's bytes are in equal instructions,
             or its first differing byte lies past half the function (default 70).
Scratch: $TMPDIR/cc900-tab/lane_nmx (TMPDIR defaults to ~/compartilhado/tmp).

WHICH C WAS COMPILED.  A run keeps only the SHA-256 of its corpus.tar (inputs.sha256), not the C.  run_oracle.sh
tars the corpus directory with `tar -cf - -C DIR .`, so a scratch directory that still holds exactly that corpus
reproduces the hash: provenance `tar-sha256` (exact; the C's own SHA-256 is then the compiled file's).  Otherwise the
source is looked up by name (scratch copies, the lanes' corpus directories and their git history) and accepted when
it defines exactly the listing's functions, the copy nearest in time to the run winning: provenance `name+funcs`
(likely, not proven).  `none` when nothing fits.

NAMES.  A listing name the C's own `cc900-name:` lines and the tree do not resolve (the C was not found, or the copy
found lacks the line) is looked up in the `cc900-name:` lines and long names of the C the src-root's trees build
(main_c_maps; only names that map one way there).  This cannot make a false MATCH: the bytes are still compared
with the ROM.  Several C functions mapped to one label (variants in one probe file) are each linked and compared on
their own; the index's `listing_name` tells them apart.

ROM SIZE.  The ROM's function is disassembled (llvm-objdump) from its address and followed through its branches;
its size is the end of the furthest instruction reached (a tail jump out of it, a return or an indirect jump ends a
path).  A MATCH is asm_vs_rom.py's: our bytes equal the ROM's over our length.

CLASSES (computed from the instruction alignment, difflib over normalised instructions; branch targets inside the
function compared through the alignment, targets outside by address):
  call-form    the same target reached with another call / jump form: call vs calr, jp vs jr / jrl
  width        the same instruction and address with another absolute operand width (8 / 16 / 24 bits)
  register     the same operation on other registers (register allocation)
  operand      the same operation and registers with another immediate or absolute address (a constant, a
               declaration's address, a struct offset)
  extend       an extz / exts present on one side only
  order        the same instructions in another order (an instruction missing here and present there)
  loop-shape   a loop's branches differ: a backward branch or djnz on one side only, or one aimed elsewhere; in a
               function with a loop, a compare / conditional branch / ret cc on one side only (the loop test copied
               to the entry or not)
  size         the same operation on another width of the same register (cp l vs cp hl): register, not
               allocation, so a C type
  swap         the same two operands the other way round (cp r, (mem) vs cp (mem), r)
  address-form the same value as lda of an address vs ld of an immediate
  return-form  ret cc vs a branch to the common return; a tail jump vs call + ret (and the ret it adds)
  bool-form    scc on one side, branches loading 0 / 1 on the other
  bit-form     set / res of one bit vs or / and with a one-bit mask
  arith-type   mul vs muls, div vs divs, or the byte vs the word form of one
  staging      a store of an immediate / memory value direct vs through a register (and the extra load)
  idiom        ld r, 0 vs xor r, r; sla r, 1 vs add r, r
  encoding     the same instruction once displacement 0, :i3 / :opc and ldw / ld are normalised, other bytes
  length-only  equal up to the end of the shorter side; one side just goes on
  other        anything else (other instructions, control flow without a loop)
Per class the index gives the bytes involved (the larger side of each pair, or the unpaired instruction).
"""
import difflib
import glob
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
MAIN_REPO = os.path.expanduser('~/compartilhado/technics-roms-disasm')
LLVM_BIN = os.path.expanduser('~/compartilhado/llvm-project/build/bin')
SCRATCH = os.path.join(os.environ.get('TMPDIR', os.path.expanduser('~/compartilhado/tmp')), 'cc900-tab', 'lane_nmx')
ORACLE = os.path.expanduser('~/compartilhado/cc900-oracle')
CORPUS_ROOTS = [os.path.join(os.environ.get('TMPDIR', os.path.expanduser('~/compartilhado/tmp')), 'cc900-tab')]
LANE_WORKTREES = os.path.expanduser('~/compartilhado/disasm-lanes')
C_NAME_LIMIT = 31

TREES = {   # key: (tree, ROM, symbols reference, load address of the ROM's first byte)
    'v10': ('v10/maincpu', 'original_ROMs/kn5000_v10_program.rom', 'symbols/maincpu_v10_symbols_reference.txt', 0xe00000),
    'v9': ('v9/maincpu', 'original_ROMs/kn5000_v9_program.rom', 'symbols/maincpu_v9_symbols_reference.txt', 0xe00000),
    'v7': ('v7/maincpu', 'original_ROMs/kn5000_v7_program.rom', 'symbols/maincpu_v7_symbols_reference.txt', 0xe00000),
    'v6': ('v6/maincpu', 'original_ROMs/kn5000_v6_program.rom', 'symbols/maincpu_v6_symbols_reference.txt', 0xe00000),
    'v5': ('v5/maincpu', 'original_ROMs/kn5000_v5_program.rom', 'symbols/maincpu_v5_symbols_reference.txt', 0xe00000),
    # sub-CPU payload: ROM offset = address - 0xf000 + 0x100 (lane_sub's brief)
    'v142': ('v142/subcpu', 'original_ROMs/kn5000_subprogram_v142.rom', 'symbols/subcpu_symbols_reference.txt', 0xef00),
    'v141': ('v141/subcpu', 'original_ROMs/kn5000_subprogram_v141.rom', 'symbols/subcpu_v141_symbols_reference.txt', 0xef00),
    'v140': ('v140/subcpu', 'original_ROMs/kn5000_subprogram_v140.rom', 'symbols/subcpu_v140_symbols_reference.txt', 0xef00),
    'hdae5000': ('hdae5000', 'original_ROMs/hd-ae5000_v2_06i.ic4', 'symbols/hdae5000_symbols_reference.txt', 0x280000),
    # the older HD-AE5000 trees (ported C, sources `hdae5000_v.../*.c`); before 2026-11-19 these were indexed as
    # 'hdae5000' and compared with the v2.06i image.  Their ROMs are git-ignored: rom_path() reads MAIN_REPO's copies.
    'hdae5000_v2_01i': ('hdae5000_v2_01i', 'original_ROMs/hd-ae5000_v2_01i.ic4',
                        'symbols/hdae5000_v2_01i_symbols_reference.txt', 0x280000),
    'hdae5000_v1_15i': ('hdae5000_v1_15i', 'original_ROMs/hd-ae5000_v1_15i.ic4',
                        'symbols/hdae5000_v1_15i_symbols_reference.txt', 0x280000),
    'hdae5000_v1_10i': ('hdae5000_v1_10i', 'original_ROMs/hd-ae5000_v1_10i.ic4',
                        'symbols/hdae5000_v1_10i_symbols_reference.txt', 0x280000),
}

CLASSES = ('call-form', 'width', 'register', 'operand', 'extend', 'order', 'loop-shape', 'swap', 'address-form',
           'size', 'return-form', 'bool-form', 'bit-form', 'arith-type', 'staging', 'idiom', 'encoding', 'length-only', 'other')
CLASS_NEEDS = {
    'call-form': 'a translator rule: asm900 relaxes `cal` / `j` to calr / jr / jrl when the target is in reach '
                 '(to_llvm writes call / jp); lane_vmb\'s call relaxation should recover these without new C',
    'width': 'a declaration: give the object the qualifier of the ROM\'s width (__tiny 8-bit, __near 16-bit, plain '
             '24-bit), one declaration per name',
    'register': 'C idiom (temporaries, argument order, types) or an option set (-O level, -XS); rarely the translator',
    'operand': 'C: a wrong constant, struct offset or object; check the declaration\'s address and the member offsets',
    'extend': 'C types: an unsigned / signed char or int where the ROM promotes (or does not); a cast or the '
              'argument\'s declared type',
    'order': 'C statement order, or an option set (-O level changes scheduling)',
    'loop-shape': 'an option set (-O3 copies the loop test to the entry, -Xr without -O does not) or the loop\'s C form '
                  '(for / while / do-while, the counter\'s type for djnz)',
    'size': 'C types: the same operation on a part of the same register (l / hl / xhl): a char vs int vs long '
            'variable, argument, return value or constant',
    'swap': 'C: the comparison written the other way round (`a == b` / `b == a`, `<` / `>`), which picks '
            '`cp r, (mem)` or `cp (mem), r`; if the C cannot express it, check to_llvm\'s cp direction',
    'address-form': 'a declaration or C idiom: an address taken as `lda` of a symbol (an object) where the ROM loads '
                    'the same number as an immediate (`ld xrr, N`: an integer constant cast to a pointer), or back',
    'return-form': 'an option set or the C\'s return path: `ret cc` vs a branch to the common return, and a tail '
                   'jump vs call + ret (the -O level decides both; -Xr without -O keeps one exit)',
    'bool-form': 'C idiom or option set: a truth value as `scc` vs branches loading 0 / 1 (the -O level, or '
                 '`return x != 0` vs if / else)',
    'bit-form': 'C idiom or option set: one bit set / cleared as `set n` / `res n` vs `or` / `and` with a mask '
                '(`x |= 8` vs a bit-field, or the -O level)',
    'arith-type': 'C types: a multiply or divide signed vs unsigned (mul / muls, div / divs) or byte vs word sized: '
                  'the operands\' declared types (char / int, signed / unsigned)',
    'staging': 'C idiom or option set: a value stored straight to memory (`ld (mem), N`, memory to memory) vs '
               'through a register (`ld r, N` then `ld (mem), r`); the -O level and whether the value is used again',
    'idiom': 'option set or C: an equivalent one-instruction idiom (`ld r, 0` vs `xor r, r`, `sla r, 1` vs '
             '`add r, r`, often with a char / int size difference: then a C type too)',
    'encoding': 'a translator rule: the same instruction, another encoding (`(xsp)` vs `(xsp+0:8)`, a long vs '
                'compact immediate); asm900\'s choice should be taught to to_llvm',
    'length-only': 'the C ends early or goes on: a missing or extra tail (a shared return path, a fall-through into the '
                   'next routine), or the ROM size heuristic overshot',
    'other': 'read the function: different instructions or control flow',
}

INDEX_COLS = ('tree', 'function', 'status', 'classes', 'rom_size', 'gen_size', 'eq_bytes', 'eq_pct', 'first_diff',
              'class_bytes', 'run', 'opt', 'flags', 'source', 'c_sha256', 'c_provenance', 'c_copy', 'listing',
              'listing_name', 'why')
# listing_name: the function's name in the listing, without V4.23's `_` / `.` (several C functions, variants, may
# map to one label; empty in rows indexed before 2026-11-18, which kept only the first variant: ERR-dup)


# --------------------------------------------------------------------------------------------- tool chain imports
def setup_imports(src_root, model_root):
    """to_llvm / listing from model_root, cc900_firmware_c from src_root (it then sees the already imported model)"""
    sys.path.insert(0, os.path.join(model_root, 'scripts', 'analysis', 'cc900', 'model'))
    import listing    # noqa: F401
    import to_llvm    # noqa: F401
    sys.path.insert(1, os.path.join(src_root, 'scripts', 'build'))
    import cc900_firmware_c    # noqa: F401
    # cc900_firmware_c put its own MODEL first on sys.path; keep model_root's modules
    sys.path.insert(0, os.path.join(model_root, 'scripts', 'analysis', 'cc900', 'model'))


def mods():
    import listing, to_llvm, cc900_firmware_c as fw
    return listing, to_llvm, fw


# ----------------------------------------------------------------------------------------------- small helpers
def sha256_file(p):
    return hashlib.sha256(open(p, 'rb').read()).hexdigest()


def rom_path(src_root, rel):
    for root in (src_root, MAIN_REPO):
        p = os.path.join(root, rel)
        if os.path.exists(p):
            return p
    return None


def load_reference(path):
    return {p[0]: int(p[1], 16) for p in (l.split() for l in open(path)) if len(p) == 2 and not p[0].startswith('#')}


def scratch_dir():
    os.makedirs(SCRATCH, exist_ok=True)
    return tempfile.TemporaryDirectory(dir=SCRATCH)


def llvm(tool, *args, **kw):
    return subprocess.run([os.path.join(LLVM_BIN, tool)] + list(args), capture_output=True, text=True, **kw)


# ------------------------------------------------------------------------------------------- run provenance
def dir_signature(d):
    n = size = 0; mt = 0.0
    for dp, dn, fn in os.walk(d):
        for f in fn:
            try:
                st = os.lstat(os.path.join(dp, f))
            except OSError:
                continue
            n += 1; size += st.st_size; mt = max(mt, st.st_mtime)
            if n > 3000:
                return None
    return '%d:%d:%.3f' % (n, size, mt)


def corpus_hashes(roots):
    """{tar sha256: dir} for every directory (depth <= 3) under roots, as run_oracle.sh would tar it (cached)"""
    cache_p = os.path.join(SCRATCH, 'corpus_hashes.json')
    try:
        cache = json.load(open(cache_p))
    except (OSError, ValueError):
        cache = {}
    out = {}
    for root in roots:
        for dp, dn, fn in os.walk(root):
            depth = dp[len(root):].count(os.sep)
            if depth >= 3:
                dn[:] = []
            if os.path.abspath(dp).startswith(os.path.abspath(SCRATCH)):
                dn[:] = []; continue
            if dp == root or not fn and not dn:
                continue                                 # the roots themselves and directories without files
            sig = dir_signature(dp)
            if sig is None:                              # too big to be a corpus; its subdirectories may be
                continue
            if cache.get(dp, [None])[0] != sig:
                tar = subprocess.run(['tar', '-cf', '-', '-C', dp, '.'], capture_output=True)
                cache[dp] = [sig, hashlib.sha256(tar.stdout).hexdigest() if tar.returncode == 0 else '']
            out.setdefault(cache[dp][1], dp)
    os.makedirs(SCRATCH, exist_ok=True)
    json.dump(cache, open(cache_p, 'w'))
    return out


def git_candidates(basename):
    """[(commit time, 'git:<commit>:<path>')] of every committed version of a corpus file with this name"""
    r = subprocess.run(['git', '-C', MAIN_REPO, 'log', '--all', '--format=@%H %ct', '--name-only', '--',
                        ':(glob)scripts/analysis/cc900/corpus/**/' + basename], capture_output=True, text=True)
    out = []; cur = None
    for l in r.stdout.splitlines():
        if l.startswith('@'):
            h, t = l[1:].split(); cur = (int(t), h)
        elif l.strip() and cur:
            out.append((cur[0], 'git:%s:%s' % (cur[1], l.strip())))
    return out


def read_c(ref):
    if ref.startswith('git:'):
        _, h, p = ref.split(':', 2)
        return subprocess.run(['git', '-C', MAIN_REPO, 'show', '%s:%s' % (h, p)], capture_output=True).stdout
    return open(ref, 'rb').read()


def c_defs_text(text):
    """function names a C text defines (cc900_firmware_c.c_functions on a text)"""
    src = text.decode('latin-1')
    src = re.sub(r'/\*.*?\*/', ' ', src, flags=re.S)
    src = re.sub(r'//[^\n]*', '', src)
    kw = {'if', 'while', 'for', 'switch', 'return', 'sizeof', 'do', 'else'}
    # K&R definitions (parameters declared between `)` and `{`, lane_hd's lyrics) as the build's c_functions reads
    # them; before 2026-11-19 they were missed, so main's K&R functions were listed in ready.tsv as not built
    return [n for n in re.findall(r'^(?![ \t#])[\w \t*]*?\b([A-Za-z_]\w*)\s*\([^;{}]*\)(?:[^;{}()#=]*;)*\s*\{',
                                  src, re.M) if n not in kw]


def file_candidates(basename):
    out = []
    for root in CORPUS_ROOTS:
        for p in glob.glob(os.path.join(root, '*', basename)) + glob.glob(os.path.join(root, '*', '*', basename)) + \
                glob.glob(os.path.join(root, '*', '*', '*', basename)):
            if not os.path.abspath(p).startswith(os.path.abspath(SCRATCH)):
                out.append((os.path.getmtime(p), p))
    for p in glob.glob(os.path.join(LANE_WORKTREES, '*', 'scripts', 'analysis', 'cc900', 'corpus', '**', basename),
                       recursive=True):
        out.append((os.path.getmtime(p), p))
    return out


def find_source(src, listing_fns, run_time, corpus_dir, cache):
    """-> (C bytes or None, sha256, provenance, ref)"""
    if corpus_dir:
        p = os.path.join(corpus_dir, src)
        if os.path.exists(p):
            b = open(p, 'rb').read()
            return b, hashlib.sha256(b).hexdigest(), 'tar-sha256', p
    want = {n[:C_NAME_LIMIT] for n in listing_fns}
    best = None
    base = os.path.basename(src)
    if base not in cache:
        cache[base] = file_candidates(base) + git_candidates(base)
    for t, ref in cache[base]:
        b = read_c(ref)
        if {n[:C_NAME_LIMIT] for n in c_defs_text(b)} != want:
            continue
        d = abs(t - run_time)
        if best is None or d < best[0]:
            best = (d, b, ref)
    if best is None:
        return None, '', 'none', ''
    return best[1], hashlib.sha256(best[1]).hexdigest(), 'name+funcs', best[2]


def tree_of(src, ctext):
    b = os.path.basename(src)
    first = src.split('/')[0]
    if first in TREES:
        return first
    if first == 'sub' or b.startswith('sub_'):
        m = re.search(r'/(v14[012])/', '/' + src)
        return m.group(1) if m else 'v142'
    if first in ('hd', 'hdae') or b.startswith(('hd_', 'hdae')):
        return 'hdae5000'
    if ctext:
        m = re.search(rb'\bv(10|9|7|6|5)\b', ctext[:2000])
        if m:
            return 'v' + m.group(1).decode()
    return 'v10'


# --------------------------------------------------------------------------------------- disassembly & diff
INS_RE = re.compile(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*\t?(\S+)?(?:\t(.*))?$')
SYM_RE = re.compile(r'^[0-9a-f]+ <([^>]+)>:$')
R8 = r'(?:q?[wabcdehl]|q?i[xyz][lh]|ra\d|r[wabcdehl]\d)'
R16 = r'(?:q?(?:wa|bc|de|hl|ix|iy|iz|sp))'
R32 = r'(?:x(?:wa|bc|de|hl|ix|iy|iz|sp)\d?)'
REG_RE = re.compile(r'\b(%s|%s|%s)\b' % (R32, R16, R8))
ABS_RE = re.compile(r'^\((-?\d+):(8|16|24)\)$')


def objdump(obj):
    """{symbol: [(offset, length, mnemonic, [operands])]} from llvm-objdump -d"""
    return objdump_text(llvm('llvm-objdump', '-d', obj).stdout)


def objdump_text(text):
    out = {}; cur = None; base = 0
    for l in text.splitlines():
        m = SYM_RE.match(l)
        if m:
            cur = m.group(1); out[cur] = []; base = int(l.split()[0], 16); continue
        m = INS_RE.match(l)
        if m and cur is not None:
            off = int(m.group(1), 16) - base
            n = len(m.group(2).split())
            mn = m.group(3) or '<unknown>'
            ops = split_ops(m.group(4) or '')
            if out[cur] and out[cur][-1][0] + out[cur][-1][1] > off:     # a continuation line of long bytes
                continue
            out[cur].append((off, n, mn, ops))
    return out


def split_ops(s):
    ops, depth, cur = [], 0, ''
    for ch in s.strip():
        if ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
        if ch == ',' and depth == 0:
            ops.append(cur.strip()); cur = ''
        else:
            cur += ch
    if cur.strip():
        ops.append(cur.strip())
    return ops


def branch_target(ins):
    """(kind, absolute-or-relative target or None, conditional) for branches; None for other instructions.
    kind: call, jump, djnz.  Relative targets are function offsets ('rel'), absolute ones addresses ('abs')."""
    off, n, mn, ops = ins
    base = mn.split('_')[0]
    if base in ('jr', 'jrl', 'calr') or base.startswith('djnz'):
        try:
            v = int(ops[-1])
        except (ValueError, IndexError):
            return None
        if base in ('jrl', 'calr'):
            v = v - 0x10000 if v >= 0x8000 else v
        else:
            v = v - 0x100 if v >= 0x80 else v
        kind = 'call' if base == 'calr' else 'djnz' if base.startswith('djnz') else 'jump'
        cond = len(ops) > 1 and kind == 'jump'
        return kind, ('rel', off + n + v), cond
    if base in ('jp', 'call'):
        last = ops[-1] if ops else ''
        m = re.match(r'^\(?(-?\d+)(?::\d+)?\)?$', last)
        kind = 'call' if base == 'call' else 'jump'
        cond = len(ops) > 1 and not mn.endswith('_rr')
        if mn.endswith('_rr') or not m:
            return kind, None, cond                       # indirect
        return kind, ('abs', int(m.group(1))), cond
    return None


class Ins:
    __slots__ = ('off', 'n', 'mn', 'ops', 'kind', 'tgt', 'cond', 'internal', 'strict', 'fam', 'shape', 'nums',
                 'regs', 'widths', 'plain')

    def __init__(self, raw, addr, size):
        self.off, self.n, self.mn, self.ops = raw
        bt = branch_target(raw)
        self.kind = self.tgt = None; self.cond = False; self.internal = False
        if bt:
            self.kind, t, self.cond = bt
            if t is not None:                                     # both sides at the function's real address:
                a = t[1] + addr if t[0] == 'rel' else t[1]       # our call / jp operands are true addresses too
                self.internal = addr <= a < addr + size
                self.tgt = a - addr if self.internal else a
        base = self.mn.split('_')[0]
        if self.kind == 'call':
            self.fam = 'call'
        elif self.kind == 'jump':
            self.fam = 'jcc' if self.cond else 'jmp'
        elif self.kind == 'djnz':
            self.fam = 'djnz'
        else:
            self.fam = base
        cc = self.ops[0] if self.cond and self.ops else ''
        if self.kind:
            tg = ('L' if self.internal else 'A%x' % self.tgt) if self.tgt is not None else 'ind'
            reg = [o for o in self.ops if REG_RE.fullmatch(o)] if self.kind == 'djnz' else []
            self.strict = (self.mn, cc, tg, tuple(reg))
            self.plain = (self.fam, cc, tg, tuple(reg))
            self.shape = self.plain; self.nums = (); self.regs = tuple(reg); self.widths = ()
            return
        plain, widths, nums, regs, shape = [], [], [], [], []
        for o in self.ops:
            m = ABS_RE.match(o)
            if m:
                plain.append('(%s)' % m.group(1)); widths.append(m.group(2)); nums.append(m.group(1)); shape.append('(@)')
                continue
            plain.append(o)
            regs += REG_RE.findall(o)
            nums += re.findall(r'(?<![\w])-?\d+', REG_RE.sub('', o))
            shape.append(re.sub(r'(?<![\w])-?\d+', '#', REG_RE.sub('r', o)))
        self.strict = (self.mn, tuple(self.ops))
        self.plain = (self.mn, tuple(plain))
        self.widths, self.nums, self.regs, self.shape = tuple(widths), tuple(nums), tuple(regs), (self.mn, tuple(shape))


def instructions(raw, addr, size):
    return [Ins(r, addr, size) for r in raw if r[0] < size]


def rom_extent(raw, limit):
    """end offset of the furthest instruction reachable from offset 0 (branches followed inside the window)"""
    at = {r[0]: i for i, r in enumerate(raw)}
    seen, work, end = set(), [0], 0
    while work:
        o = work.pop()
        if o in seen or o not in at:
            continue
        seen.add(o)
        r = raw[at[o]]
        end = max(end, r[0] + r[1])
        mn = r[2]; base = mn.split('_')[0]
        if mn == '<unknown>':
            continue
        if base in ('ret', 'reti', 'retd') and not r[3] or base in ('reti', 'retd') or base == 'halt':
            continue
        bt = branch_target(r)
        nxt = r[0] + r[1]
        if bt:
            kind, t, cond = bt
            if kind == 'call':
                work.append(nxt); continue
            if t is not None and t[0] == 'rel' and 0 <= t[1] < limit:
                work.append(t[1])
            if kind == 'djnz' or cond:
                work.append(nxt)
            continue
        work.append(nxt)
    return end


def compare(ours, rom):
    """instruction diff -> (eq_bytes, {class: bytes})"""
    sm = difflib.SequenceMatcher(None, [i.strict for i in ours], [i.strict for i in rom], autojunk=False)
    ops = sm.get_opcodes()
    o2r = {}
    for tag, a0, a1, b0, b1 in ops:
        if tag == 'equal':
            for k in range(a1 - a0):
                o2r[a0 + k] = b0 + k
    oidx = {i.off: k for k, i in enumerate(ours)}
    ridx = {i.off: k for k, i in enumerate(rom)}
    cls = {}
    eq = 0

    def add(c, b):
        cls[c] = cls.get(c, 0) + b

    for a, b in o2r.items():                         # equal instructions: internal targets must correspond
        x, y = ours[a], rom[b]
        if x.internal and y.internal and x.tgt is not None:
            if o2r.get(oidx.get(x.tgt)) != ridx.get(y.tgt) or oidx.get(x.tgt) is None:
                add('loop-shape' if y.tgt <= y.off or x.tgt <= x.off else 'other', y.n); continue
        eq += y.n
    un_o, un_r = [], []                              # unpaired instructions (indices)
    last_equal = max([k for k, (t, *_r) in enumerate(ops) if t == 'equal'], default=-1)
    trailing = []
    for k, (tag, a0, a1, b0, b1) in enumerate(ops):
        if tag == 'equal':
            continue
        if k > last_equal and (a1 == a0 or b1 == b0):
            trailing.append((a0, a1, b0, b1)); continue
        xs, ys = list(range(a0, a1)), list(range(b0, b1))
        pairs = align_block([ours[i] for i in xs], [rom[j] for j in ys])
        po, pr = {c for c, d in pairs}, {d for c, d in pairs}
        for c, d in pairs:
            i, j = xs[c], ys[d]
            for cl in pair_classes(ours[i], rom[j], o2r, oidx, ridx):
                add(cl, max(ours[i].n, rom[j].n))
        un_o += [xs[c] for c in range(len(xs)) if c not in po]
        un_r += [ys[d] for d in range(len(ys)) if d not in pr]
    # unpaired: order (the same instruction on the other side), extend, loop-shape, other
    pool_r = {}
    for j in un_r:
        pool_r.setdefault(rom[j].plain, []).append(j)
    left_o = []
    for i in un_o:
        lst = pool_r.get(ours[i].plain)
        if lst:
            j = lst.pop(); add('order', max(ours[i].n, rom[j].n))
        else:
            left_o.append(i)
    left_r = [j for v in pool_r.values() for j in v]
    # the same operation at another place on other registers: order and register
    pool_s = {}
    for j in left_r:
        pool_s.setdefault(rom[j].shape, []).append(j)
    left_o2 = []
    for i in left_o:
        lst = pool_s.get(ours[i].shape) if not ours[i].kind else None
        if lst:
            j = lst.pop(0); b = max(ours[i].n, rom[j].n)
            add('order', b)
            if ours[i].regs != rom[j].regs:
                add('register', 0)
            if ours[i].nums != rom[j].nums:
                add('operand', 0)
        else:
            left_o2.append(i)
    left_o, left_r = left_o2, [j for v in pool_s.values() for j in v]
    # the same pairs at another place, by the classes that pair across shapes (lda / ld, mul / muls ...)
    left_o2 = []
    for i in left_o:
        j = next((j for j in left_r if not ours[i].kind and pair_classes(ours[i], rom[j], o2r, oidx, ridx)[0] in
                  ('address-form', 'arith-type', 'idiom', 'bit-form', 'encoding', 'swap')), None)
        if j is None:
            left_o2.append(i); continue
        left_r.remove(j)
        for c in pair_classes(ours[i], rom[j], o2r, oidx, ridx):
            add(c, max(ours[i].n, rom[j].n))
    left_o = left_o2
    scc = any(x.mn == 'scc' for x in ours) != any(y.mn == 'scc' for y in rom)
    staged, retform = 'staging' in cls, 'return-form' in cls
    looped = any(y.kind in ('jump', 'djnz') and y.internal and y.tgt is not None and y.tgt <= y.off for y in ours + rom)
    for side, idxs in ((ours, left_o), (rom, left_r)):
        for i in idxs:
            x = side[i]
            if x.mn in ('extz', 'exts'):
                add('extend', x.n)
            elif scc and (x.mn == 'scc' or x.mn == 'ret' or x.kind == 'jump' and x.internal and x.tgt > x.off
                          or x.mn == 'ld' and len(x.ops) == 2 and x.ops[1] in ('0:i3', '1:i3', '0', '1')):
                add('bool-form', x.n)
            elif x.mn == 'ret' and not x.ops or retform and x.kind == 'jump' and x.internal and x.tgt > x.off:
                add('return-form', x.n)
            elif staged and x.mn == 'ld' and len(x.ops) == 2 and REG_RE.fullmatch(x.ops[0]) \
                    and REG_RE.fullmatch(x.ops[1]) is None and not x.ops[1].startswith('('):
                add('staging', x.n)
            elif x.mn == 'ld' and len(x.ops) == 2 and all(REG_RE.fullmatch(o) for o in x.ops):
                add('register', x.n)                     # a register copy on one side only: register allocation
            elif x.kind in ('jump', 'djnz') and x.internal and (x.tgt <= x.off or x.kind == 'djnz'):
                add('loop-shape', x.n)
            elif looped and (x.kind == 'jump' and x.internal or x.mn == 'cp' or x.mn == 'ret' and x.ops):
                add('loop-shape', x.n)                   # a loop's test copied to its entry, or not
            else:
                add('other', x.n)
    for a0, a1, b0, b1 in trailing:
        add('length-only', sum(ours[i].n for i in range(a0, a1)) + sum(rom[j].n for j in range(b0, b1)))
    return eq, cls


def explain(ours, rom, mine, rb):
    """print the alignment (our translation's and the ROM's instructions, both as llvm-objdump reads them)"""
    def txt(i, b):
        return '+%-4d %-18s %s %s' % (i.off, b[i.off:i.off + i.n].hex(' '), i.mn, ', '.join(i.ops))
    sm = difflib.SequenceMatcher(None, [i.strict for i in ours], [i.strict for i in rom], autojunk=False)
    for tag, a0, a1, b0, b1 in sm.get_opcodes():
        for k in range(max(a1 - a0, b1 - b0)):
            x = txt(ours[a0 + k], mine) if a0 + k < a1 else ''
            y = txt(rom[b0 + k], rb) if b0 + k < b1 else ''
            print('%s %-52s | %s' % ('=' if tag == 'equal' else '!', x, y))


FLOW = {'call', 'jmp', 'jcc', 'ret', 'retd', 'djnz'}
BITS = {'set', 'res', 'or', 'and', 'chg'}
MULDIV = {'mul': 'mul', 'muls': 'mul', 'div': 'div', 'divs': 'div'}


def coarse(x):
    """the key that pairs instructions inside a differing block: control transfers with each other, bit
    operations with each other, otherwise the family"""
    return 'flow' if x.fam in FLOW else 'bits' if x.fam in BITS else MULDIV.get(x.fam, x.fam)


def similarity(x, y):
    """how alike two instructions of a differing block are (0: do not pair them)"""
    if coarse(x) != coarse(y):
        if {x.mn, y.mn} in ({'ld', 'xor'}, {'ld', 'lda'}) or doubling(x, y) or 'scc' in (x.mn, y.mn) and coarse(x) == 'ld' == coarse(y):
            return 1
        return 0
    sc = 1 + (x.mn == y.mn) + (x.shape == y.shape)
    mx = {o for o in x.ops if o.startswith('(')}
    my = {o for o in y.ops if o.startswith('(')}
    sc += 3 * len(mx & my)
    ix = {o.split(':')[0] for o in x.ops if re.fullmatch(r'-?\d+(:\w+)?', o)}
    iy = {o.split(':')[0] for o in y.ops if re.fullmatch(r'-?\d+(:\w+)?', o)}
    sc += len(ix & iy)
    if x.kind and y.kind and x.tgt == y.tgt and x.tgt is not None:
        sc += 3
    return sc


def align_block(xs, ys):
    """pairs (i, j) of a differing block, in order, maximising the summed similarity (Needleman-Wunsch, gaps free)"""
    n, m = len(xs), len(ys)
    if n * m > 40000:                                    # a huge block: pair by position within the family
        sub = difflib.SequenceMatcher(None, [coarse(x) for x in xs], [coarse(y) for y in ys], autojunk=False)
        return [(c0 + k, d0 + k) for t, c0, c1, d0, d1 in sub.get_opcodes() if t == 'equal' for k in range(c1 - c0)]
    S = [[0] * (m + 1) for _ in range(n + 1)]
    for i in range(n - 1, -1, -1):
        for j in range(m - 1, -1, -1):
            v = similarity(xs[i], ys[j])
            S[i][j] = max(S[i + 1][j], S[i][j + 1], S[i + 1][j + 1] + v if v else -1)
    out, i, j = [], 0, 0
    while i < n and j < m:
        v = similarity(xs[i], ys[j])
        if v and S[i][j] == S[i + 1][j + 1] + v:
            out.append((i, j)); i += 1; j += 1
        elif S[i][j] == S[i + 1][j]:
            i += 1
        else:
            j += 1
    return out


def doubling(x, y):
    """sla / sll r, 1 on one side, add r', r' on the other (a value doubled)"""
    for a, b in ((x, y), (y, x)):
        if a.mn in ('sla', 'sll') and len(a.ops) == 2 and a.ops[1] == '1' and b.mn == 'add' and len(b.ops) == 2 \
                and b.ops[0] == b.ops[1]:
            return True
    return False


REG8_FAMILY = {'a': 'wa', 'w': 'wa', 'c': 'bc', 'b': 'bc', 'e': 'de', 'd': 'de', 'l': 'hl', 'h': 'hl'}


def reg_family(r):
    """the 32-bit register a register is part of: l, hl, xhl -> hl; ixl, ix, xix -> ix"""
    r = r.lower()
    if r.startswith('x') and len(r) > 2:
        r = r[1:]
    r = re.sub(r'^(i[xyz])[lh]$', r'\1', r)
    return REG8_FAMILY.get(r, r)


def norm_enc(x):
    """an instruction with its encoding choices taken out: (xrr+0) / (xrr+0:8) = (xrr), :i3 / :opc / :8 dropped
    from immediates, ldw = ld"""
    ops = tuple(re.sub(r'\((x\w+)\+0(?::\d+)?\)', r'(\1)', re.sub(r'^(-?\d+):(i3|opc)$', r'\1', o)) for o in x.ops)
    mn = {'ldw': 'ld'}.get(x.mn, x.mn)
    return (mn, ops) if not x.kind else ('#', x.strict)


def pair_classes(x, y, o2r, oidx, ridx):
    if x.strict == y.strict:
        if x.internal and y.internal and x.tgt is not None:
            return ['loop-shape' if y.tgt <= y.off else 'other']     # aimed elsewhere
        return ['other'] if x.n != y.n else []
    if 'scc' in (x.mn, y.mn) and x.mn != y.mn:
        return ['bool-form']
    if x.kind == 'jump' and y.kind == 'call' or x.kind == 'call' and y.kind == 'jump':
        if x.tgt == y.tgt and x.tgt is not None:
            return ['return-form']                       # a tail jump vs call (+ ret)
    if {x.mn, y.mn} == {'ret', 'jr'} or {x.mn, y.mn} == {'ret', 'jrl'}:
        if (x.mn == 'ret' and x.ops) or (y.mn == 'ret' and y.ops):
            return ['return-form']                       # ret cc vs jr cc to the common return
    if norm_enc(x) == norm_enc(y):
        return ['encoding']
    if x.fam in MULDIV and y.fam in MULDIV and (x.mn != y.mn or x.n != y.n):
        return ['arith-type']                            # signed / unsigned, byte / word multiply or divide
    if {x.mn, y.mn} == {'ld', 'xor'}:
        l, xr = (x, y) if x.mn == 'ld' else (y, x)
        if len(xr.ops) == 2 and xr.ops[0] == xr.ops[1] and len(l.ops) == 2 and l.ops[1].split(':')[0] == '0':
            return ['idiom']
    if doubling(x, y):
        return ['idiom']
    if x.mn == y.mn == 'ld' and len(x.ops) == len(y.ops) == 2 and x.ops[0] == y.ops[0] and x.ops[0].startswith('(') \
            and (REG_RE.fullmatch(x.ops[1]) is None) != (REG_RE.fullmatch(y.ops[1]) is None):
        return ['staging']                               # ld (m), N vs ld (m), r
    if x.mn != y.mn and {x.mn, y.mn} & {'set', 'res'} and {x.mn, y.mn} & {'or', 'and'}:
        return ['bit-form']                              # set / res n vs or / and with a one-bit mask
    if {x.mn, y.mn} == {'lda', 'ld'} and x.nums and x.nums[-1:] == y.nums[-1:]:
        return ['address-form']
    if not x.kind and x.mn == y.mn and len(x.ops) == 2 and list(x.plain[1]) == list(reversed(y.plain[1])):
        return ['swap']
    if x.kind and y.kind and x.fam == y.fam:
        if x.mn != y.mn and x.plain == y.plain:
            if x.internal and x.tgt is not None:            # jr vs jrl to a local: a length knock-on, call it form
                return ['call-form']
            return ['call-form']
        if x.internal and y.internal:
            return ['loop-shape' if (y.tgt <= y.off or x.tgt <= x.off) else 'other']
        return ['operand'] if x.cond == y.cond else ['other']
    if x.kind or y.kind:
        if x.kind == 'djnz' or y.kind == 'djnz':
            return ['loop-shape']
        return ['other']
    if x.mn in ('extz', 'exts') or y.mn in ('extz', 'exts'):
        return ['extend']
    if x.plain == y.plain and x.widths != y.widths:
        return ['width']
    if x.mn == y.mn or x.shape == y.shape:
        out = []
        if x.shape == y.shape:
            if x.regs != y.regs:
                out.append('size' if len(x.regs) == len(y.regs) and all(
                    reg_family(a) == reg_family(b) for a, b in zip(x.regs, y.regs)) else 'register')
            if x.nums != y.nums:
                out.append('operand')
            if x.widths != y.widths:
                out.append('width')
            return out or ['other']
        if x.regs != y.regs and len(x.ops) == len(y.ops):
            return ['register']
    return ['other']


# ------------------------------------------------------------------------------------------- one listing
class Ctx:
    """per tree: names, ROM, symbols; per process caches"""
    trees = {}
    src_root = REPO

    @classmethod
    def tree(cls, key):
        if key not in cls.trees:
            listing, to_llvm, fw = mods()
            tdir, rom, sym, base = TREES[key]
            tree = os.path.join(cls.src_root, tdir)
            ref = load_reference(rom_path(cls.src_root, sym))
            values = fw.tree_values(tree)
            cnames = {}
            for c in glob.glob(os.path.join(tree, 'cc900', '*.c')):
                lm = fw.label_map(c)
                for n in c_defs_text(open(c, 'rb').read()):
                    cnames[n[:C_NAME_LIMIT]] = lm.get(n, n)
            short = {}
            for n in ref:
                short.setdefault(n[:C_NAME_LIMIT], []).append(n)
            rp = rom_path(cls.src_root, rom)
            cls.trees[key] = dict(ref=ref, values=values, cnames=cnames, short=short, base=base, rom_path=rp,
                                  rom=open(rp, 'rb').read() if rp else None)
        return cls.trees[key]


def make_names(t, alias):
    listing, to_llvm, fw = mods()

    class CutNames(fw.Names):          # as asm_vs_rom.py: a C short name, then a name cut to 31 characters
        def resolve(self, n):
            if n in alias:
                n = alias[n]
            r = super().resolve(n)
            if r[0] is None and len(n) == C_NAME_LIMIT:
                full = [k for k in list(self.values) + list(self.labels) if len(k) > C_NAME_LIMIT and k[:C_NAME_LIMIT] == n]
                if len(set(full)) == 1:
                    return super().resolve(full[0])
            return r
    return CutNames(t['values'], t['ref'])


def label_map_text(text):
    return {m.group(1).decode(): m.group(2).decode()
            for m in re.finditer(rb'cc900-name:\s*([A-Za-z_]\w*)\s*=\s*([A-Za-z_]\w*)', text)}


def assembler_errors(text):
    r = llvm('llvm-mc', '-triple=tlcs900', '-filetype=obj', '-o', os.devnull, input=text)
    return r.stderr


def assemble_obj(text, d, stem):
    s, o = os.path.join(d, stem + '.s'), os.path.join(d, stem + '.o')
    open(s, 'w').write(text)
    r = llvm('llvm-mc', '-triple=tlcs900', '-filetype=obj', s, '-o', o)
    return (o if r.returncode == 0 else None), r.stderr


def obj_bytes(o, d, stem):
    b = os.path.join(d, stem + '.bin')
    llvm('llvm-objcopy', '-O', 'binary', '-j', '.text', o, b)
    code = open(b, 'rb').read() if os.path.exists(b) else b''
    nm = llvm('llvm-nm', '--defined-only', o).stdout
    syms = {p[2]: int(p[0], 16) for p in (l.split() for l in nm.splitlines()) if len(p) == 3 and p[1] in 'Tt'}
    order = sorted(syms, key=syms.get)
    return {n: code[syms[n]:syms[order[i + 1]] if i + 1 < len(order) else len(code)] for i, n in enumerate(order)}


def analyse_listing(job):
    """job: dict(asm, tree, ctext, only) -> [row dicts] (one per function of the listing)"""
    listing, to_llvm, fw = mods()
    t = Ctx.tree(job['tree'])
    if BUILD_CHAIN and hasattr(fw, 'module_names'):
        return analyse_listing_build(job, t)
    text = open(job['asm'], encoding='latin-1').read()
    funcs = fw.listing_functions(text)
    ctext = job.get('ctext') or b''
    cdefs = c_defs_text(ctext) if ctext else []
    alias = label_map_text(ctext) if ctext else {}
    uncut = {n[:C_NAME_LIMIT]: n for n in cdefs}
    names = make_names(t, alias)
    to_llvm.SPELL = None
    widths = listing.attributes(text)
    widths.update({uncut[k]: v for k, v in list(widths.items()) if k in uncut})
    to_llvm.WIDTHS = widths
    ref = t['ref']
    rows, bodies = [], {}
    for name, lines in funcs.items():
        bare = name.lstrip('_.')
        if job.get('only') is not None and bare not in job['only']:
            continue
        c = bare if bare in cdefs else uncut.get(bare, bare)
        cand = [alias.get(c, c), t['cnames'].get(bare), bare, '_' + bare]
        full = next((x for x in cand if x and x in ref), None)
        if full is None and len(t['short'].get(bare, [])) == 1:
            full = t['short'][bare][0]
        row = dict(function=full or bare, listing_name=bare, status='ERR-other')
        rows.append(row)
        if full in bodies:                               # two listing functions for one tree label
            row['status'] = 'ERR-dup'; continue
        if full is None:
            row['status'] = 'ERR-name'; continue
        if t['rom'] is None:
            row['status'] = 'ERR-rom'; continue
        try:
            body = to_llvm.translate_function(name, lines, names)
        except KeyError as e:
            row['status'] = 'ERR-resolve'; row['why'] = str(e)[:80]; continue
        body = [l for l in body if l not in ('\t.globl %s' % bare, bare + ':')]
        if any('untranslated' in l for l in body):
            row['status'] = 'ERR-translate'; continue
        order = [l[:-1] for l in lines if l.endswith(':') and not l.startswith('\t') and l[:-1] != name]
        k = len(bodies)
        out = []
        for l in body:
            for lab in order:
                l = re.sub(r'(?<![\w.])%s(?![\w])' % re.escape(lab), '.Lnm%d_%s' % (k, lab.lstrip('.')), l)
            out.append(l)
        bodies[full] = (row, '\t.globl %s\n%s:\n%s' % (full, full, '\n'.join(out)))
    if not bodies:
        return rows
    with scratch_dir() as d:
        # assemble all together (relaxing jr -> jrl as asm900 does); a function that breaks it is assembled alone
        ok = {}
        text_all = '\t.text\n' + '\n'.join(b for _, b in bodies.values()) + '\n'
        text_all = to_llvm.relax(text_all, assembler_errors)
        o, err = assemble_obj(text_all, d, 'ours')
        if o is None:
            for full, (row, b) in bodies.items():
                tx = to_llvm.relax('\t.text\n' + b + '\n', assembler_errors)
                o1, _ = assemble_obj(tx, d, 'one')
                if o1 is None:
                    row['status'] = 'ERR-asm'; continue
                ok[full] = (obj_bytes(o1, d, 'one')[full], objdump(o1)[full])
        else:
            bb, dd = obj_bytes(o, d, 'ours'), objdump(o)
            for full in bodies:
                ok[full] = (bb[full], dd[full])
    return compare_rows(job, t, ok, {f: b[0] for f, b in bodies.items()}, rows)


def compare_rows(job, t, ok, rowof, rows):
    """ok: {label: (our bytes, our llvm-objdump instructions)}; fills rowof[label] with the comparison"""
    ref, rom = t['ref'], t['rom']
    with scratch_dir() as d:
        # the ROM side: one window per function, disassembled in one object
        wins = {}
        src = ['\t.text']
        for full, (mine, _) in ok.items():
            at = ref[full] - t['base']
            w = min(max(2 * len(mine), len(mine) + 64), 8192, len(rom) - at)
            wins[full] = (at, w)
            src.append('\t.globl %s\n%s:\n\t.incbin "%s", %d, %d' % (full, full, t['rom_path'], at, w))
        o2, err2 = assemble_obj('\n'.join(src) + '\n', d, 'rom')
        romdis = objdump(o2) if o2 else {}
    for full, (mine, ourdis) in ok.items():
        row = rowof[full]
        at, w = wins[full]
        r = rom[at:at + len(mine)]
        row['gen_size'] = len(mine)
        if mine == r:
            row.update(status='MATCH', classes='MATCH', rom_size=len(mine), eq_bytes=len(mine), eq_pct=100.0,
                       first_diff='', class_bytes='')
            continue
        first = next(i for i in range(len(mine)) if i >= len(r) or mine[i] != r[i])
        raw = romdis.get(full, [])
        size = rom_extent(raw, w) or len(mine)
        addr = ref[full]
        ours_i = instructions(ourdis, addr, len(mine))
        rom_i = instructions(raw, addr, size)
        eq, cls = compare(ours_i, rom_i)
        if job.get('explain') in (full, row['listing_name']):
            explain(ours_i, rom_i, mine, rom[at:at + size])
        row.update(status='DIFF', rom_size=size, eq_bytes=eq, eq_pct=round(100.0 * eq / size, 1) if size else 0.0,
                   first_diff=first,
                   classes=','.join(c for c in CLASSES if c in cls) or 'other',
                   class_bytes=';'.join('%s:%d' % (c, cls[c]) for c in CLASSES if c in cls))
    return rows


BUILD_CHAIN = True      # main(): translate as the src-root's build does when it can (cc900_firmware_c.finish)
TREE_LABELS = {}


ELF_OF = {'v10': 'kn5000_v10_program', 'v9': 'kn5000_v9_program', 'v7': 'kn5000_v7_program',
          'v6': 'kn5000_v6_program', 'v5': 'kn5000_v5_program', 'v142': 'kn5000_subprogram_v142',
          'v141': 'kn5000_subprogram_v141', 'v140': 'kn5000_subprogram_v140', 'hdae5000': 'hd-ae5000_v2_06i',
          'hdae5000_v2_01i': 'hd-ae5000_v2_01i', 'hdae5000_v1_15i': 'hd-ae5000_v1_15i',
          'hdae5000_v1_10i': 'hd-ae5000_v1_10i'}
MODIMG = {}


def module_calls_mod():
    """the src-root's scripts/analysis/cc900/module_calls.py, imported (its rel_target and c_callees)"""
    import importlib.util
    p = os.path.join(Ctx.src_root, 'scripts', 'analysis', 'cc900', 'module_calls.py')
    spec = importlib.util.spec_from_file_location('module_calls_nm', p)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def derive_module(tree_key, cpath, only=None):
    """module_calls.py's rule (src-root's copy: rel_target, c_callees, its extent rule) for any tree: the callees the
    C calls that the built image reaches by calr / jr / jrl from outside the function.  The image is disassembled
    once per tree and process (module_calls.py itself redoes it per file, ~7 s).  only: just that function's.
    -> sorted names, or None when the tree has no built ELF"""
    listing, to_llvm, fw = mods()
    mc = module_calls_mod()
    t = Ctx.tree(tree_key)
    if tree_key not in MODIMG:
        elf = rom_path(Ctx.src_root, os.path.join('rebuilt_ROMs', ELF_OF[tree_key] + '.llvm.elf'))
        if elf is None:
            MODIMG[tree_key] = None
        else:
            insns, base = [], set()
            outp = llvm('llvm-objdump', '-d', elf).stdout
            for line in outp.splitlines():
                m = mc.LINE.match(line)
                if m:
                    insns.append((int(m.group(1), 16), len(m.group(2).split()), m.group(3), m.group(4)))
            for addr, nb, mnem, ops in insns:
                if mnem == 'calr':
                    base.add(mc.rel_target(addr, nb, mnem, ops))
                elif mnem == 'call' and ops.strip().isdigit():
                    base.add(int(ops.strip()))
            by_addr = {}
            for n, a in t['ref'].items():
                by_addr.setdefault(a, n)
            MODIMG[tree_key] = (insns, base, by_addr)
    if MODIMG[tree_key] is None:
        return None
    insns, base, by_addr = MODIMG[tree_key]
    import bisect
    ref = t['ref']
    lm = fw.label_map(cpath)
    callees = mc.c_callees(cpath, lm)
    fns = [lm.get(c, c) for c in fw.c_functions(cpath)]
    starts = sorted(base | {ref[f] for f in fns if f in ref})
    local = set()
    for fn in fns:
        if fn not in ref or only is not None and fn != only:
            continue
        lo = ref[fn]
        hi = starts[bisect.bisect_right(starts, lo)] if bisect.bisect_right(starts, lo) < len(starts) else lo + 0x10000
        i = bisect.bisect_left(insns, (lo,))
        while i < len(insns) and insns[i][0] < hi:
            addr, nb, mnem, ops = insns[i]
            i += 1
            if mnem in ('calr', 'jr', 'jrl'):
                tg = mc.rel_target(addr, nb, mnem, ops)
                if tg is not None and not lo <= tg < hi and by_addr.get(tg) in callees:
                    local.add(by_addr[tg])
    return sorted(local)


def module_line(job, cpath):
    """the C's `cc900-module:` names: derived from the image (job['derive_module']), else the C's own comments"""
    listing, to_llvm, fw = mods()
    if job.get('derive_module'):
        m = derive_module(job['tree'], cpath)
        if m is not None:
            job['module'] = ' '.join(m)
            return set(m)
    return fw.module_names(cpath)


MAIN_MAPS = []


def main_c_maps():
    """({short C name: label}, {31-character cut: long name}) from the `cc900-name:` lines and the long names of
    every C file the src-root's trees build (<tree>/cc900/*.c, cc900-staged/*.c), each kept only where it is
    unambiguous across them.  The fallback for an attempt whose own C is missing, or is a version without the line
    (provenance none / name+funcs): the lanes give a label one short name and reuse it from file to file, so the
    name the listing calls is most likely the one main's C maps.  Likely, not proven: such a row's C copy may still
    lack the line, and the build (which reads only the file's own lines) would then refuse it."""
    if not MAIN_MAPS:
        listing, to_llvm, fw = mods()
        smap, scut = {}, {}
        for tdir, _r, _s, _b in TREES.values():
            for c in glob.glob(os.path.join(Ctx.src_root, tdir, 'cc900', '*.c')) + \
                    glob.glob(os.path.join(Ctx.src_root, tdir, 'cc900-staged', '*.c')):
                b = open(c, 'rb').read()
                for k, v in label_map_text(b).items():
                    smap.setdefault(k, set()).add(v)
                src = re.sub(r'/\*.*?\*/', ' ', b.decode('latin-1'), flags=re.S)
                for n in set(re.findall(r'\b[A-Za-z_]\w{%d,}' % C_NAME_LIMIT, src)):
                    scut.setdefault(n[:C_NAME_LIMIT], set()).add(n)
        MAIN_MAPS.append({k: next(iter(v)) for k, v in smap.items() if len(v) == 1})
        MAIN_MAPS.append({k: next(iter(v)) for k, v in scut.items() if len(v) == 1})
    return MAIN_MAPS[0], MAIN_MAPS[1]


def main_fallback_names(fw):
    """fw.Names that, when V4.23's name resolves to nothing (or to an ambiguous 31-character cut), tries main's C
    files' map for it (main_c_maps)"""
    class MainFallbackNames(fw.Names):
        def resolve(self, n, depth=0):
            try:
                a = super().resolve(n, depth)
            except KeyError:
                a = None
                if depth:
                    raise
            if (a is None or a[0] is None) and depth == 0:
                mmap, mcut = main_c_maps()
                bare = n.lstrip('_.')
                for alt in (mmap.get(bare), mcut.get(bare) if len(bare) == C_NAME_LIMIT else None):
                    if alt and alt != bare:
                        b = super().resolve(alt, 1)
                        if b[0] is not None:
                            return b
            if a is None:                        # the ambiguous cut, unresolved: the resolver's own error
                return super().resolve(n, depth)
            return a
    return MainFallbackNames


def analyse_listing_build(job, t):
    """the build's own chain (src-root's scripts/build/cc900_firmware_c.py): names spelled as the tree spells them,
    runtime names, cc900-module call relaxation, the out-of-reach fallback, f_const placement; each function then
    assembled with the tree's values and linked at its ROM address"""
    listing, to_llvm, fw = mods()
    tdir = os.path.join(Ctx.src_root, TREES[job['tree']][0])
    if tdir not in TREE_LABELS:                  # as the build's main(): the tree with its includes (the kernel)
        TREE_LABELS[tdir] = (fw.merged_values(tdir) if hasattr(fw, 'merged_values') else t['values'],
                             fw.merged_labels(tdir) if hasattr(fw, 'merged_labels') else fw.tree_labels(tdir))
    text = open(job['asm'], encoding='latin-1').read()
    funcs = fw.listing_functions(text)
    ctext = job.get('ctext') or b''
    ref = t['ref']
    rows, bodies, extra = [], {}, []
    with scratch_dir() as d:
        cpath = os.path.join(d, 'c.c')
        open(cpath, 'wb').write(ctext)
        cdefs = fw.c_functions(cpath) if ctext else []
        labels = fw.label_map(cpath)
        uncut = {n[:C_NAME_LIMIT]: n for n in cdefs}
        fw.ADDRS.clear(); fw.ADDRS.update(ref)
        fw.RUNTIME.clear(); fw.RUNTIME.update(fw.runtime_names(tdir))
        fw.DATA_OUT.clear()
        values, tlabels = TREE_LABELS[tdir]
        names = main_fallback_names(fw)(values, tlabels, cut=True)
        names.addrs = fw.ADDRS                   # the symbols reference, the resolver's last resort
        names.cmap = labels                      # cc900-name: for every reference, callees too
        if hasattr(fw, 'ROM_LABEL'):
            to_llvm.PLACEHOLDER = fw.ROM_LABEL
        to_llvm.SPELL = names
        widths = listing.attributes(text)
        widths.update({uncut[k]: v for k, v in list(widths.items()) if k in uncut})
        to_llvm.WIDTHS = widths
        to_llvm.MODULE = module_line(job, cpath)
        mmap, mcut = main_c_maps()
        for name, lines in funcs.items():
            bare = name.lstrip('_.')
            c = bare if bare in cdefs else uncut.get(bare, bare)
            cand = [labels.get(c, c), t['cnames'].get(bare), bare, '_' + bare]
            full = next((x for x in cand if x and x in ref), None)
            if full is None and len(t['short'].get(bare, [])) == 1:
                full = t['short'][bare][0]
            if full is None:                     # the C's own map is missing (C not found): main's C files' maps
                full = next((x for x in (mmap.get(bare), mcut.get(bare)) if x and x in ref), None)
            row = dict(function=full or bare, listing_name=bare, status='ERR-other')
            rows.append(row)
            if full is None:
                row['status'] = 'ERR-name'; continue
            try:
                body = fw.finish(cpath, name, full, lines, names)
            except SystemExit as e:
                msg = str(e)
                row['status'] = 'ERR-translate' if 'cannot translate' in msg else \
                    'ERR-data' if 'cc900-data' in msg else 'ERR-resolve'
                row['why'] = untranslated_shapes(msg) if 'cannot translate' in msg else \
                    msg.split(': ', 2)[-1][:100].replace('\t', ' ').replace('\n', ' ')
                continue
            if full in bodies:                   # a variant for a label already taken (two C functions, one
                extra.append((full, row, body))  # cc900-name label): linked and compared on its own below
            else:
                bodies[full] = (row, body)
        vals = {k: v for k, v in values.items() if v is not None}
        ok, why = {}, {}
        if bodies:
            ok = link_at_addresses(bodies, ref, vals, d, why)
        alone = []
        for full, row, body in extra:
            w = {}
            alone.append((row, link_at_addresses({full: (row, body)}, ref, vals, d, w), w))
    for full, (row, b) in bodies.items():
        if full not in ok:
            row['status'] = 'ERR-asm'
            row['why'] = why.get(full, '')
    for row, ok1, w in alone:
        if row['function'] not in ok1:
            row['status'] = 'ERR-asm'
            row['why'] = w.get(row['function'], '')
        else:
            compare_rows(job, t, ok1, {row['function']: row}, [])
    return compare_rows(job, t, ok, {f: b[0] for f, b in bodies.items()}, rows)


def untranslated_shapes(msg):
    """the build's `to_llvm cannot translate` stop -> its reason and each refused line's SHAPE only: the mnemonic
    and register names kept, any other name written `sym`, any number `N` (`cp A,QE`, `ld XIX,sym + N`).  The
    refused lines are V4.23's listing lines, which never enter this repository."""
    head = 'to_llvm cannot translate' + (' data' if 'the data of' in msg else '')
    by = {}
    for m in re.finditer(r'untranslated(?: \(([^)]*)\))?:?[ \t]*([^\n;]*)', msg):
        toks = m.group(2).split(None, 1)
        ops = toks[1] if len(toks) > 1 else ''
        ops = re.sub(r'(?<![\w.])-?(0x[0-9a-fA-F]+|\d+)(?!\w)', '#', ops)
        ops = re.sub(r'[_.]?[A-Za-z_]\w*', lambda t: t.group(0) if to_llvm_reg(t.group(0)) else 'sym', ops).replace('#', 'N')
        s = ' '.join(x for x in (toks[0] if toks else '', ops.strip()) if x)
        shapes = by.setdefault(m.group(1) or '', [])
        if s not in shapes:
            shapes.append(s)
    return (head + ': ' + '; '.join((r + ': ' if r else '') + ', '.join(s) for r, s in by.items()))[:100]


def to_llvm_reg(n):
    """a register name of the listing (A, QE, XIX, QIZH, ...) or a condition code: kept in a shape"""
    return bool(re.fullmatch(r'(Q?[WABCDEHL]|Q?(WA|BC|DE|HL|IX|IY|IZ|SP)|X(WA|BC|DE|HL|IX|IY|IZ|SP)|Q?I[XYZ][LH]|'
                             r'eq|ne|lt|le|gt|ge|ult|uge|ugt|ule|z|nz|c|nc|t|f|m|p|ov|nov)', n))


SYM_TOKEN = re.compile(r'(?<![\w.])([A-Za-z_][A-Za-z0-9_]*)(?![\w])')


BRANCH_MN = re.compile(r'^\t(jr|jrl|calr|call|jp|djnz\w*)\s+(?:\w+\s*,\s*)?([A-Za-z_]\w*)\s*$')


def tool_error(err, src_lines):
    """a short reason from llvm-mc's / ld.lld's stderr: each distinct error message once, with the mnemonic of the
    line llvm-mc refused (the message only, never the line: it is a translation of V4.23's listing)"""
    out = []
    for m in re.finditer(r'^(?:[^\n:]*\.s:(\d+):\d+: )?(?:ld\.lld: )?error: ([^\n]*)', err, re.M):
        msg = m.group(2).strip()
        if m.group(1) and 0 < int(m.group(1)) <= len(src_lines):
            mn = src_lines[int(m.group(1)) - 1].split()
            msg += ' (%s)' % mn[0] if mn else ''
        msg = re.sub(r'\s+', ' ', msg)
        if msg not in out:
            out.append(msg)
    return ('; '.join(out) or 'no error text')[:100]


def link_at_addresses(bodies, ref, values, d, why=None):
    """{label: (row, llvm-mc lines)} -> {label: (bytes, instructions)}.  As in the tree, the functions and the
    labels they branch to sit in ONE section at their ROM offsets (`.org`), so llvm-mc measures and widens the
    jr / calr itself; the section is linked (ld.lld) at its ROM address; other names are `.set` to the tree's
    values.  A function that does not assemble or link with the others is tried alone, else left out; why
    ({label: reason}) gets tool_error()'s reason for each function left out."""
    fail = {}

    def build(items, stem):
        used, targets = set(), set()
        for f, (row, lines) in items:
            for l in lines:
                parts = l.strip().split(None, 1)
                if len(parts) == 2 and not parts[0].startswith('.'):
                    used.update(SYM_TOKEN.findall(parts[1]))
                m = BRANCH_MN.match(l)
                if m and m.group(2) in ref:
                    targets.add(m.group(2))
        defined = {f for f, _ in items}
        targets -= defined
        lo = min(ref[f] for f, _ in items)
        body = dict(items)
        src = []
        for n in sorted(used - defined - targets):
            if REG_RE.fullmatch(n.lower()) or n in ('t', 'f', 'z', 'nz', 'c', 'nc'):
                continue
            v = ref.get(n, values.get(n))
            if v is not None:
                src.append('\t.set %s, 0x%x' % (n, v))
        src += ['\t.section .text.nm,"ax",@progbits', 'nm__base:']
        for x in sorted(targets):                # branch targets: section-relative, so llvm-mc measures the reach
            src.append('\t.set %s, nm__base + %d' % (x, ref[x] - lo))
        for f, _ in items:
            src += ['\t.org 0x%x, 0xff' % (ref[f] - lo), '\t.globl %s' % f, '%s:' % f] + list(body[f][1]) + \
                   ['\t.globl %s__nmend' % f, '%s__nmend:' % f]
        o, err = assemble_obj('\n'.join(src) + '\n', d, stem)
        if o is None:
            if os.environ.get('NEARMISS_DEBUG'):
                sys.stderr.write(err[:2000])
            fail['why'] = 'llvm-mc: ' + tool_error(err, '\n'.join(src).split('\n'))
            return None
        ld = os.path.join(d, stem + '.ld'); elf = os.path.join(d, stem + '.elf')
        open(ld, 'w').write('SECTIONS { .text.nm 0x%x : { *(.text.nm) } }\n' % lo)
        r = llvm('ld.lld', '-e', '0', '-T', ld, o, '-o', elf)
        if r.returncode:
            if os.environ.get('NEARMISS_DEBUG'):
                sys.stderr.write(r.stderr[:2000])
            fail['why'] = 'ld.lld: ' + tool_error(r.stderr, [])
            return None
        nm = llvm('llvm-nm', '--defined-only', elf).stdout
        sym = {p[2]: int(p[0], 16) for p in (l.split() for l in nm.splitlines()) if len(p) == 3}
        binp = os.path.join(d, stem + '.bin')
        llvm('llvm-objcopy', '--dump-section', '.text.nm=' + binp, elf, os.path.join(d, stem + '.junk'))
        code = open(binp, 'rb').read() if os.path.exists(binp) else b''
        r = llvm('llvm-objdump', '-d', '--disassemble-symbols=' + ','.join(f for f, _ in items), elf)
        tmp = os.path.join(d, stem + '.dis')
        dis = objdump_text(r.stdout)
        res = {}
        for f, _ in items:
            if f in sym and f + '__nmend' in sym and f in dis:
                a0, a1 = sym[f] - lo, sym[f + '__nmend'] - lo
                res[f] = (code[a0:a1], [x for x in dis[f] if x[0] < a1 - a0])
        return res

    items = sorted(bodies.items(), key=lambda kv: ref[kv[0]])
    res = build(items, 'all')
    if res is None:
        res = {}
        for it in items:
            fail.clear()
            r = build([it], 'one')
            if r:
                res.update(r)
            elif why is not None:
                why[it[0]] = fail.get('why', 'no output')
    return res


def run_job(job):
    # SystemExit too: the build's checks outside finish() (check_markers via label_map / module_names, c_functions)
    # stop with sys.exit.  SystemExit is no Exception, so it used to end a pool worker: multiprocessing.Pool replaces
    # a worker that exits but loses its task, and imap_unordered then waited for that result for ever (the hung
    # --jobs 2 recheck of 2026-11-17: two C files with a wrapped `cc900-name:` marker, two dead workers).  With
    # --jobs 1 the same exit stopped the whole run.
    try:
        return job, analyse_listing(job), None
    except (Exception, SystemExit) as e:         # one bad listing must not stop the index
        return job, [], '%s: %s' % (type(e).__name__, str(e).replace('\n', ' ')[:300])


# ---------------------------------------------------------------------------------------------- C extraction
def c_items(text):
    """top-level items of a C text: [(start, end, kind)] kind = 'func', 'decl' or 'pp'; comments are skipped"""
    items, i, n = [], 0, len(text)
    start = None; depth = 0; paren = 0; head_close = False
    while i < n:
        ch = text[i]
        if text.startswith('/*', i):
            j = text.find('*/', i + 2); i = n if j < 0 else j + 2; continue
        if text.startswith('//', i):
            j = text.find('\n', i); i = n if j < 0 else j; continue
        if ch in '"\'':
            j = i + 1
            while j < n and text[j] != ch:
                j += 2 if text[j] == '\\' else 1
            i = j + 1; continue
        if start is None:
            if ch.isspace():
                i += 1; continue
            if ch == '#':
                j = text.find('\n', i); j = n if j < 0 else j
                items.append((i, j, 'pp')); i = j; continue
            start = i; depth = paren = 0; head_close = False
        if ch == '(':
            paren += 1
        elif ch == ')':
            paren -= 1
        elif ch == '{':
            if depth == 0 and paren == 0:
                head = re.sub(r'/\*.*?\*/', ' ', text[start:i], flags=re.S).rstrip()
                head_close = head.endswith(')')
            depth += 1
        elif ch == '}':
            depth -= 1
            if depth == 0 and head_close:
                items.append((start, i + 1, 'func')); start = None
        elif ch == ';' and depth == 0 and paren == 0:
            items.append((start, i + 1, 'decl')); start = None
        i += 1
    return items


IDENT = re.compile(r'[A-Za-z_]\w*')
C_WORDS = set('auto break case char const continue default do double else enum extern float for goto if int long '
              'register return short signed sizeof static struct switch typedef union unsigned void volatile while '
              '__near __tiny __far __adecl __cdecl __interrupt'.split())


def strip_c(s):
    s = re.sub(r'/\*.*?\*/', ' ', s, flags=re.S)
    s = re.sub(r'//[^\n]*', ' ', s)
    return re.sub(r'"(\\.|[^"\\])*"', '""', s)


def declared(item, kind):
    s = strip_c(item)
    if kind == 'func':
        m = re.search(r'([A-Za-z_]\w*)\s*\(', s.split('{', 1)[0])
        return {m.group(1)} if m else set()
    if kind == 'pp':
        m = re.match(r'#\s*define\s+([A-Za-z_]\w*)', s)
        return {m.group(1)} if m else set()
    names = set()
    for tag in re.findall(r'\b(?:struct|union|enum)\s+([A-Za-z_]\w*)\s*\{', s):
        names.add(tag)
    for body in re.findall(r'\benum\b[^{]*\{([^}]*)\}', s):
        names |= set(re.findall(r'([A-Za-z_]\w*)\s*(?:=|,|$)', body))
    flat = s
    while '{' in flat:                           # struct / union / enum bodies
        flat2 = re.sub(r'\{[^{}]*\}', ' ', flat)
        if flat2 == flat:
            break
        flat = flat2
    flat = flat.rstrip().rstrip(';')
    parts, depth, cur = [], 0, ''
    for ch in flat:                              # declarators, split at top-level commas
        depth += ch in '(['; depth -= ch in ')]'
        if ch == ',' and depth == 0:
            parts.append(cur); cur = ''
        else:
            cur += ch
    parts.append(cur)
    for p in parts:
        p = p.split('=', 1)[0]
        m = re.search(r'\(\s*\*\s*(?:(?:__near|__far|__tiny|const|volatile)\s+)*([A-Za-z_]\w*)', p)
        if m:
            names.add(m.group(1)); continue
        m = re.search(r'([A-Za-z_]\w*)\s*\(', p)
        if m and m.group(1) not in C_WORDS:
            names.add(m.group(1)); continue
        ids = [x for x in IDENT.findall(re.sub(r'\[[^\]]*\]', '', p)) if x not in C_WORDS]
        if ids:
            names.add(ids[-1])
    return names - C_WORDS


def extract_function(text, cname):
    """the C function `cname` and the top-level declarations it needs (transitively), in file order, or None when
    that is not reliable (a call of another function the file defines, preprocessor conditionals, no such function)"""
    if re.search(r'^\s*#\s*(if|ifdef|ifndef|elif|else|endif)\b', text, re.M):
        return None
    items = c_items(text)
    info = [(s, e, k, declared(text[s:e], k), set(IDENT.findall(strip_c(text[s:e])))) for s, e, k in items]
    target = [x for x in info if x[2] == 'func' and cname in x[3]]
    if len(target) != 1:
        return None
    defined_funcs = {n for x in info if x[2] == 'func' for n in x[3]}
    need = {target[0][0]}
    uses = set(target[0][4]) - {cname}
    if uses & (defined_funcs - {cname}):
        return None
    changed = True
    while changed:
        changed = False
        for s, e, k, decl, ids in info:
            if s in need or k == 'func':
                continue
            if k == 'pp' and not decl or decl & uses:
                need.add(s); uses |= ids - decl; changed = True
    return ''.join(text[s:e] + '\n' for s, e, k, d, i in info if s in need)


def clang_ok(text):
    with scratch_dir() as d:
        p = os.path.join(d, 'x.c')
        open(p, 'w', encoding='latin-1').write(text)
        r = subprocess.run(['clang', '-fsyntax-only', '-w', '-std=gnu89', '-D__near=', '-D__tiny=', '-D__far=',
                            '-D__adecl=', '-x', 'c', p], capture_output=True, text=True)
        return r.returncode == 0


def write_c_copy(out_dir, tree, function, cname, ctext, sha, src, provenance, flags):
    rel = os.path.join('c', tree, '%s__%s.c' % (function, sha[:8]))
    p = os.path.join(out_dir, rel)
    if os.path.exists(p):
        return rel
    text = ctext.decode('latin-1')
    body = extract_function(text, cname)
    how = 'the whole file'
    if body is not None and clang_ok(text) and clang_ok(body):
        how = 'the function and the declarations it uses'
    else:
        body = text
    opts = re.search(r'cc900-options:([^*\n]*)', text)
    names = sorted(label_map_text(ctext).items())
    hdr = ['/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): %s of %s' % (how, src),
           '   sha256 %s (%s); compiled at %s' % (sha, provenance, flags or '(no flags)')]
    if opts and how != 'the whole file':
        hdr.append('   cc900-options:%s' % opts.group(1).rstrip())
    for k, v in names:
        if how == 'the whole file' or re.search(r'\b%s\b' % re.escape(k), body):
            if how != 'the whole file':
                hdr.append('   cc900-name: %s=%s' % (k, v))
    hdr[-1] += ' */'
    os.makedirs(os.path.dirname(p), exist_ok=True)
    open(p, 'w', encoding='latin-1').write('\n'.join(hdr) + '\n' + body)
    return rel


# ---------------------------------------------------------------------------------------------- index driver
def run_list(a, oracle):
    runs = sorted(os.listdir(os.path.join(oracle, 'runs')))
    if '--runs' in a:
        want = a[a.index('--runs') + 1].split(',')
        return [r for r in runs if r in want]
    rx = re.compile(a[a.index('--runs-re') + 1] if '--runs-re' in a else r'-(p6|sub|hd)-')
    return [r for r in runs if rx.search(r)]


def run_key(r):
    m = re.match(r'^(\d{4}-\d\d-\d\d)-(\d+)-', r)
    return (m.group(1), int(m.group(2))) if m else (r, 0)


def build_jobs(runs, oracle, src_root):
    hashes = corpus_hashes(CORPUS_ROOTS)
    jobs, prov = [], {}
    cand_cache = {}
    listing, to_llvm, fw = mods()
    for run in runs:
        rd = os.path.join(oracle, 'runs', run)
        sha = ''
        for l in open(os.path.join(rd, 'inputs.sha256')):
            if l.split()[-1] == 'corpus.tar':
                sha = l.split()[0]
        corpus = hashes.get(sha)
        prov[run] = (corpus or '', sha)
        run_time = os.path.getmtime(os.path.join(rd, 'job.log'))
        opts = [l.rstrip('\n').split('|', 1) for l in open(os.path.join(rd, 'options.txt')) if '|' in l]
        srcs = [l.strip() for l in open(os.path.join(rd, 'sources.txt')) if l.strip()]
        for comp in sorted(os.listdir(os.path.join(rd, 'out'))):
            for lab, flags in opts:
                for src in srcs:
                    asm = os.path.join(rd, 'out', comp, lab, src[:-2] + '.asm')
                    if not os.path.exists(asm) or os.path.getsize(asm) == 0:
                        continue
                    fns = [k.lstrip('_.') for k in fw.listing_functions(open(asm, encoding='latin-1').read())]
                    key = (run, src)
                    if key not in cand_cache:
                        cand_cache[key] = find_source(src, fns, run_time, corpus, cand_cache)
                    ctext, csha, cprov, cref = cand_cache[key]
                    jobs.append(dict(asm=asm, run=run, opt=lab, flags=flags, source=src, ctext=ctext, c_sha256=csha,
                                     c_provenance=cprov, c_ref=cref, tree=tree_of(src, ctext), derive_module=True,
                                     listing=os.path.relpath(asm, oracle)))
    return jobs, prov


def execute(jobs, n):
    rows, errs = [], []
    if n > 1:
        # concurrent.futures, not multiprocessing.Pool: a worker that dies (killed, out of memory) makes the map
        # raise BrokenProcessPool, where Pool silently replaced the worker, lost its task and waited for ever.  Fork,
        # so the workers inherit setup_imports() and Ctx.src_root; the parent has no thread yet when they start.
        import multiprocessing as mp
        from concurrent.futures import ProcessPoolExecutor
        with ProcessPoolExecutor(n, mp_context=mp.get_context('fork')) as pool:
            res = list(pool.map(run_job, jobs, chunksize=4))
    else:
        res = [run_job(j) for j in jobs]
    for job, rs, err in res:
        if err:
            errs.append('%s: %s' % (job['listing'], err))
        for r in rs:
            r2 = {k: job.get(k, '') for k in ('tree', 'run', 'opt', 'flags', 'source', 'c_sha256', 'c_provenance', 'listing')}
            r2.update(r)
            r2['_job'] = job
            rows.append(r2)
    return rows, errs


def near(r, pct):
    if r.get('status') != 'DIFF':
        return False
    fd = r.get('first_diff')
    return float(r.get('eq_pct') or 0) >= pct or (fd not in ('', None) and int(fd) * 2 >= int(r.get('rom_size') or 0))


def finalise(rows, pct):
    for r in rows:
        r.setdefault('status', 'ERR-other')
        if r.get('status') == 'DIFF' and near(r, pct):
            r['status'] = 'NEAR'
        for k in ('classes', 'class_bytes', 'rom_size', 'gen_size', 'eq_bytes', 'eq_pct', 'first_diff', 'c_copy'):
            r.setdefault(k, '')
        if r['status'].startswith('ERR') and not r['classes']:
            r['classes'] = r['status']


def write_index(out, rows):
    rows.sort(key=lambda r: (r['tree'], r['function'], run_key(r['run']), r['opt'], r['source']))
    with open(os.path.join(out, 'index.tsv'), 'w') as f:
        f.write('\t'.join(INDEX_COLS) + '\n')
        for r in rows:
            f.write('\t'.join(str(r.get(c, '')) for c in INDEX_COLS) + '\n')


def read_index(out):
    p = os.path.join(out, 'index.tsv')
    lines = open(p).read().splitlines()
    cols = lines[0].split('\t')
    return [dict(zip(cols, l.split('\t'))) for l in lines[1:]]


def best_per_function(rows):
    rank = {'MATCH': 3, 'NEAR': 2, 'DIFF': 1}
    best = {}
    for r in rows:
        k = (r['tree'], r['function'])
        key = (rank.get(r['status'], 0), float(r['eq_pct'] or 0), run_key(r['run']))
        if k not in best or key > best[k][0]:
            best[k] = (key, r)
    return {k: v[1] for k, v in best.items()}


def root_label(root):
    """a checkout as `~/path` at `<branch>@<commit>`"""
    r = subprocess.run(['git', '-C', root, 'log', '-1', '--format=%h'], capture_output=True, text=True).stdout.strip()
    b = subprocess.run(['git', '-C', root, 'rev-parse', '--abbrev-ref', 'HEAD'], capture_output=True, text=True).stdout.strip()
    return '%s (%s@%s)' % (root.replace(os.path.expanduser('~'), '~'), b or '?', r or '?')


def table(head, rows):
    w = [max(len(str(x)) for x in col) for col in zip(head, *rows)] if rows else [len(h) for h in head]
    out = ['| ' + ' | '.join(str(h).ljust(w[i]) for i, h in enumerate(head)) + ' |',
           '|' + '|'.join('-' * (x + 2) for x in w) + '|']
    for r in rows:
        out.append('| ' + ' | '.join(str(c).ljust(w[i]) for i, c in enumerate(r)) + ' |')
    return '\n'.join(out)


def write_readme(out, rows, prov, pct, src_root, model_root, errs):
    best = best_per_function(rows)
    st = {}
    for r in best.values():
        st[r['status']] = st.get(r['status'], 0) + 1
    att = {}
    for r in rows:
        att[r['status']] = att.get(r['status'], 0) + 1
    misses = [r for r in best.values() if r['status'] in ('NEAR', 'DIFF')]
    L = []
    L.append('# cc900 C near-miss index (generated by `scripts/analysis/cc900/nearmiss.py`)\n')
    L.append('QUESTION ANSWERED: for every function of our firmware C that Toshiba cc900 V4.23 compiled in the oracle '
             'runs below, how close does V4.23\'s code (translated by `model/to_llvm.py`, assembled by llvm-mc) come '
             'to the ROM, and which kinds of difference keep it from matching?  `index.tsv` has one row per attempt '
             '(run, option set, C file, function); the tables below take each function\'s best attempt.  No Toshiba '
             'text is in this directory: names, counts, offsets, class names and paths only.  The listings stay in '
             'the private repository `~/compartilhado/cc900-oracle` (`listing` column, relative to it).\n')
    L.append('Regenerate: `python3 -B scripts/analysis/cc900/nearmiss.py --src-root SRC --model-root MODEL` '
             '(this index: `--src-root %s --model-root %s`, near threshold %s %%).  Re-check after a translator change, '
             'without the VM: `python3 -B scripts/analysis/cc900/nearmiss.py --recheck [--class CLASS] [--all]`.  '
             'The classes and the ROM-size rule are defined in the script\'s docstring.\n'
             % (root_label(src_root), root_label(model_root), pct))
    L.append('## Totals\n')
    L.append(table(['what', 'MATCH', 'NEAR', 'DIFF', 'errors'],
                   [['attempts (index rows)', att.get('MATCH', 0), att.get('NEAR', 0), att.get('DIFF', 0),
                     sum(v for k, v in att.items() if k.startswith('ERR'))],
                    ['functions (best attempt)', st.get('MATCH', 0), st.get('NEAR', 0), st.get('DIFF', 0),
                     sum(v for k, v in st.items() if k.startswith('ERR'))]]) + '\n')
    errk = sorted({r['status'] for r in rows if r['status'].startswith('ERR')})
    if errk:
        L.append('Errors: ' + ', '.join('%s %d' % (k, sum(1 for r in rows if r['status'] == k)) for k in errk) +
                 ' attempts (ERR-name: the listing\'s function is not a label of the tree; ERR-resolve: a name '
                 'without a value or declared width; ERR-translate: a line to_llvm does not know; ERR-asm: llvm-mc '
                 'refuses the translation or ld.lld cannot link it; ERR-dup: a second listing function (a C variant) for '
                 'a tree label, not compared, in rows indexed before 2026-11-18 (since then each variant is linked and '
                 'compared on its own; `listing_name` tells them apart); ERR-data: an f_const object (switch table, FP constant) without a '
                 '`cc900-data:` line; the `why` column has the reason).\n')
    L.append('## By class (each non-matching function\'s best attempt)\n')
    L.append('`sole`: functions whose only class it is, so fixing the class alone would make them MATCH; `sole ROM B`: '
             'their ROM bytes (what a fix recovers outright).  `diff B`: bytes this class covers in all functions.  '
             'Examples: the largest sole-class functions, else the largest.\n')
    trs = []
    for c in CLASSES:
        has = [r for r in misses if c in r['classes'].split(',')]
        sole = [r for r in has if r['classes'] == c]
        db = sum(int(dict(x.split(':') for x in r['class_bytes'].split(';') if x).get(c, 0)) for r in has)
        ex = sorted(sole, key=lambda r: -int(r['rom_size'] or 0))[:4] or sorted(has, key=lambda r: -int(r['rom_size'] or 0))[:4]
        trs.append([c, len(has), len(sole), sum(int(r['rom_size'] or 0) for r in sole), db,
                    ', '.join('%s %s (%s B, %s%%)' % (r['tree'], r['function'], r['rom_size'], r['eq_pct']) for r in ex)])
    trs.sort(key=lambda x: (-x[3], -x[4]))
    L.append(table(['class', 'functions', 'sole', 'sole ROM B', 'diff B', 'examples'], trs) + '\n')
    L.append('## What each class needs\n')
    L.append(table(['class', 'needs'], [[c, CLASS_NEEDS[c]] for c in CLASSES]) + '\n')
    L.append('## Class combinations (best attempts)\n')
    combos = {}
    for r in misses:
        combos.setdefault(r['classes'], []).append(r)
    L.append(table(['classes', 'functions', 'ROM B'],
                   [[k, len(v), sum(int(r['rom_size'] or 0) for r in v)]
                    for k, v in sorted(combos.items(), key=lambda kv: -len(kv[1]))][:30]) + '\n')
    L.append('## Near misses (best attempt, NEAR)\n')
    nm = sorted([r for r in misses if r['status'] == 'NEAR'], key=lambda r: (r['tree'], r['function']))
    L.append(table(['tree', 'function', 'ROM B', 'ours B', 'equal %', 'first diff', 'classes', 'run / option', 'C copy'],
                   [[r['tree'], r['function'], r['rom_size'], r['gen_size'], r['eq_pct'], r['first_diff'],
                     r['classes'], '%s %s' % (r['run'], r['opt']), r['c_copy']] for r in nm]) + '\n')
    L.append('## Runs and where their C came from\n')
    L.append('`tar-sha256`: a scratch directory still holds exactly the corpus whose tar hash the run recorded; '
             '`name+funcs`: the C was found by name and defines exactly the listing\'s functions (likely, not proven).\n')
    pr = []
    for run in sorted(prov, key=run_key):
        provs = sorted({r['c_provenance'] for r in rows if r['run'] == run})
        pr.append([run, prov[run][1][:16], ', '.join(provs) or '-',
                   sum(1 for r in rows if r['run'] == run), sum(1 for r in rows if r['run'] == run and r['status'] == 'MATCH')])
    L.append(table(['run', 'corpus.tar sha256', 'C provenance', 'attempts', 'MATCH'], pr) + '\n')
    if errs:
        L.append('## Listings the tool could not read\n')
        L.append('\n'.join('- ' + e for e in errs) + '\n')
    open(os.path.join(out, 'README.md'), 'w').write('\n'.join(L))


def copy_c(out, rows, pct):
    for r in rows:
        if r['status'] != 'NEAR' or not r.get('_job', {}).get('ctext'):
            continue
        job = r['_job']
        cname = r['listing_name'] if 'listing_name' in r else r['function']
        cdefs = c_defs_text(job['ctext'])
        cname = cname if cname in cdefs else next((n for n in cdefs if n[:C_NAME_LIMIT] == cname[:C_NAME_LIMIT]), cname)
        r['c_copy'] = write_c_copy(out, r['tree'], r['function'], cname, job['ctext'], job['c_sha256'],
                                   job['source'] + ' (' + job['run'] + ')', job['c_provenance'], job['flags'])


def opt(a, n, d):
    return a[a.index(n) + 1] if n in a else d


def read_runs(out):
    prov = {}
    for l in open(os.path.join(out, 'runs.tsv')).read().splitlines()[1:]:
        p = l.split('\t')
        prov[p[0]] = (p[2], p[1])
    return prov


def main():
    a = sys.argv[1:]
    if '-h' in a or '--help' in a:
        sys.exit(__doc__)
    global ORACLE
    ORACLE = os.path.abspath(opt(a, '--oracle', ORACLE))
    src_root = os.path.abspath(opt(a, '--src-root', REPO))
    model_root = os.path.abspath(opt(a, '--model-root', src_root))
    out = os.path.abspath(opt(a, '--out', os.path.join(REPO, 'notes', 'cc900-c-nearmiss')))
    pct = float(opt(a, '--near', '70'))
    jobs_n = int(opt(a, '--jobs', '2'))
    setup_imports(src_root, model_root)
    Ctx.src_root = src_root
    os.makedirs(out, exist_ok=True)
    if '--explain' in a:                  # --explain LISTING FUNCTION [--tree T]: the alignment of one function
        lst, fn = a[a.index('--explain') + 1], a[a.index('--explain') + 2]
        old = [r for r in read_index(out) if r['listing'] == lst] if os.path.exists(os.path.join(out, 'index.tsv')) else []
        tree = opt(a, '--tree', old[0]['tree'] if old else 'v10')
        ctext = b''.join(open(os.path.join(out, r['c_copy']), 'rb').read() for r in old if r['c_copy'])
        for r in analyse_listing(dict(asm=os.path.join(ORACLE, lst), tree=tree, ctext=ctext, explain=fn,
                                      derive_module=True)):
            if fn in (r['function'], r['listing_name']):
                print({k: r.get(k) for k in ('status', 'rom_size', 'gen_size', 'eq_bytes', 'first_diff', 'class_bytes')})
        return 0
    if '--readme' in a:                   # README.md again from index.tsv and runs.tsv, nothing re-translated
        rows = read_index(out)
        write_readme(out, rows, read_runs(out), pct, src_root, model_root, [])
        return 0
    if '--ready' in a:                    # ready.tsv again from index.tsv, nothing re-translated
        rows = read_index(out)
        write_ready(out, rows, read_runs(out))
        write_index(out, rows)            # the C copies written for it
        return 0
    if '--recheck' in a:
        return recheck(a, out, pct, jobs_n, src_root, model_root)
    t0 = time.time()
    runs = run_list(a, ORACLE)
    keep, keep_prov = [], {}
    if '--add-new' in a and os.path.exists(os.path.join(out, 'runs.tsv')):   # only the runs the index lacks
        keep_prov = {k: (os.path.join(CORPUS_ROOTS[0], v[0]) if v[0] else '', v[1]) for k, v in read_runs(out).items()}
        runs = [r for r in runs if r not in keep_prov]
        keep = read_index(out)
    jobs, prov = build_jobs(runs, ORACLE, src_root)
    print('%d runs, %d listings' % (len(runs), len(jobs)), file=sys.stderr)
    rows, errs = execute(jobs, jobs_n)
    finalise(rows, pct)
    copy_c(out, rows, pct)
    rows = keep + rows
    prov.update(keep_prov)
    write_index(out, rows)
    with open(os.path.join(out, 'runs.tsv'), 'w') as f:
        f.write('run\tcorpus_tar_sha256\tcorpus_dir\n')
        for run in sorted(prov, key=run_key):
            f.write('%s\t%s\t%s\n' % (run, prov[run][1], os.path.relpath(prov[run][0], CORPUS_ROOTS[0])
                                       if prov[run][0] else ''))
    write_readme(out, rows, prov, pct, src_root, model_root, errs)
    write_ready(out, read_index(out), read_runs(out))
    print('%d attempts, %.0f s; %s' % (len(rows), time.time() - t0, os.path.join(out, 'index.tsv')), file=sys.stderr)
    return 0


LANES = {'v10': 'lane_p6', 'v9': 'lane_p6', 'v7': 'lane_p6', 'v6': 'lane_p6', 'v5': 'lane_p6',
         'v142': 'lane_sub', 'v141': 'lane_sub', 'v140': 'lane_sub', 'hdae5000': 'lane_hd',
         'hdae5000_v2_01i': 'lane_hd', 'hdae5000_v1_15i': 'lane_hd', 'hdae5000_v1_10i': 'lane_hd'}


def source_c(out, rows, runs):
    """the C a listing was compiled from: the run's corpus file when it still hashes to the index's sha256 (exact),
    else the near-miss copies of its rows (concatenated), else nothing"""
    r0 = rows[0]
    cdir = runs.get(r0['run'], ('', ''))[0]
    if cdir:
        p = os.path.join(CORPUS_ROOTS[0], cdir, r0['source'])
        if os.path.exists(p):
            b = open(p, 'rb').read()
            if hashlib.sha256(b).hexdigest() == r0['c_sha256']:
                return b, 'corpus'
    copies = sorted({x['c_copy'] for x in rows if x['c_copy'] and os.path.exists(os.path.join(out, x['c_copy']))})
    if copies:
        return b''.join(open(os.path.join(out, c), 'rb').read() for c in copies), 'copies'
    return b'', 'none'


def recheck(a, out, pct, jobs_n, src_root, model_root):
    old = read_index(out)
    runs = read_runs(out)
    cls = opt(a, '--class', None)
    if '--all' in a:
        sel = [r for r in old if r['status'] not in ('MATCH', 'ERR-name', 'ERR-dup')]
    else:
        sel = [r for r in old if r['status'] == 'NEAR']
    sel = [r for r in sel if cls is None or cls in r['classes'].split(',')]
    if '--status' in a:                   # only rows of these statuses (comma-separated, e.g. ERR-resolve; any status)
        sel = [r for r in old if r['status'] in opt(a, '--status', '').split(',')
               and (cls is None or cls in r['classes'].split(','))]
    by = {}
    for r in sel:
        by.setdefault(r['listing'], []).append(r)
    jobs = []
    for lst, rs in by.items():
        ctext, how = source_c(out, rs, runs)
        jobs.append(dict(asm=os.path.join(ORACLE, lst), tree=rs[0]['tree'], ctext=ctext, c_how=how, listing=lst,
                         derive_module='--no-derive-module' not in a))
    res, errs = execute(jobs, jobs_n)
    for r in res:
        if r['status'] == 'DIFF' and near(r, pct):
            r['status'] = 'NEAR'
    pair = pair_rows(old, res)
    ready, changed = [], []
    for r in sel:
        n = pair.get(id(r))
        if n is None:
            continue
        if n['status'] == 'MATCH':
            ready.append((r, n))
        if (n['status'], str(n.get('eq_pct', ''))) != (r['status'], r['eq_pct']) or n.get('classes', '') != r['classes']:
            changed.append((r, n))
    print('re-checked %d attempts (%d listings) with %s' % (len(sel), len(jobs), root_label(model_root)))
    for e in errs:
        print('not read (rows kept as they were): %s' % e)
    if '--verbose' in a:
        for r, n in changed:
            print('%-8s %-40s %-9s %5s%% %-28s -> %-9s %5s%% %s' % (
                r['tree'], r['function'][:40], r['status'], r['eq_pct'], r['classes'][:28], n['status'],
                n.get('eq_pct', ''), n.get('classes', '')))
    trans = {}
    for r, n in changed:
        trans[(r['status'], n['status'])] = trans.get((r['status'], n['status']), 0) + 1
    print('%d changed (%s), %d attempts now MATCH' % (
        len(changed), ', '.join('%s->%s %d' % (k[0], k[1], v) for k, v in sorted(trans.items())), len(ready)))
    if ready:
        print('now MATCH: %s' % ' '.join(sorted({'%s:%s' % (r['tree'], r['function']) for r, n in ready})))
    if '--update' in a:
        # only the selected rows: the other functions of a re-read listing were translated from whatever C
        # source_c() found for the selected ones (the near-miss copies of those rows only, when the corpus is
        # gone), so their new results are not comparable with their indexed ones (the 2026-11-18 recheck,
        # d84256090, overwrote them and turned 99 MATCH rows into NEAR this way)
        for r in sel:
            n = pair.get(id(r))
            if n is not None:
                for k in ('function', 'listing_name', 'status', 'classes', 'rom_size', 'gen_size', 'eq_bytes', 'eq_pct',
                          'first_diff', 'class_bytes', 'why'):
                    r[k] = n.get(k, '')
                finalise([r], pct)
        write_index(out, old)
        write_readme(out, old, runs, pct, src_root, model_root, errs)
        write_ready(out, old, runs)
    return 0


def pair_rows(old, res):
    """{id(old row): its re-checked row}.  By the listing's function name (listing_name; an ERR-name row's function
    is that name) when the old row has one, else by order: the n-th old row of a (listing, function) is the n-th
    re-checked one (the index keeps a listing's rows in listing order, and rows indexed before listing_name existed
    kept the first variant of a label first, the others as ERR-dup)."""
    by_name, by_fn = {}, {}
    for n in res:
        by_name[(n['listing'], n.get('listing_name', ''))] = n
        by_fn.setdefault((n['listing'], n['function']), []).append(n)
    out, seen = {}, {}
    for r in old:
        k = (r['listing'], r['function'])
        i = seen.get(k, 0)
        seen[k] = i + 1
        ln = r.get('listing_name') or (r['function'] if r['status'] == 'ERR-name' else '')
        if ln:
            n = by_name.get((r['listing'], ln))
        else:
            lst = by_fn.get(k, [])
            n = lst[i] if i < len(lst) else None
        if n is not None:
            out[id(r)] = n
    return out


def lane_staged():
    """{(tree key, label): where} of the functions that have C somewhere other than the src-root's <tree>/cc900/:
    the src-root's own <tree>/cc900-staged/ (`src-root:staged`), the lanes' worktrees (<tree>/cc900/ and cc900-staged/,
    committed or not; the worktree's directory name), and the committed trees of the local branches main has not
    merged (`branch:<name>`).  By their C definitions and cc900-name maps; several places are joined with `+`."""
    out = {}

    def add(key, b, where):
        lm = label_map_text(b)
        for n in c_defs_text(b):
            ws = out.setdefault((key, lm.get(n, n)), [])
            if where not in ws:
                ws.append(where)

    src = os.path.realpath(Ctx.src_root)
    for key, (tdir, _r, _s, _b) in TREES.items():
        for c in glob.glob(os.path.join(src, tdir, 'cc900-staged', '*.c')):
            add(key, open(c, 'rb').read(), 'src-root:staged')
    for wt in sorted(glob.glob(os.path.join(LANE_WORKTREES, '*', ''))):
        if os.path.realpath(wt) == src:          # the src-root itself: its cc900/ is what write_ready leaves out
            continue
        for key, (tdir, _r, _s, _b) in TREES.items():
            for c in glob.glob(os.path.join(wt, tdir, 'cc900', '*.c')) + glob.glob(os.path.join(wt, tdir, 'cc900-staged', '*.c')):
                add(key, open(c, 'rb').read(), os.path.basename(os.path.dirname(wt)))
    git = ['git', '-C', MAIN_REPO]
    refs = subprocess.run(git + ['for-each-ref', '--no-merged=main', '--format=%(refname:short)', 'refs/heads'],
                          capture_output=True, text=True).stdout.split()
    for ref in refs:
        for key, (tdir, _r, _s, _b) in TREES.items():
            files = subprocess.run(git + ['ls-tree', '-r', '--name-only', ref, '--', tdir + '/cc900', tdir + '/cc900-staged'],
                                   capture_output=True, text=True).stdout.split()
            for p in files:
                if p.endswith('.c'):
                    add(key, subprocess.run(git + ['show', '%s:%s' % (ref, p)], capture_output=True).stdout, 'branch:' + ref)
    return {k: '+'.join(v) for k, v in out.items()}


def write_ready(out, rows, runs):
    """OUT/ready.tsv: every (tree, function) that MATCHes in the index and is not built from C in the src-root's tree,
    per lane, with its newest matching attempt, a C copy (written when missing) and that function's cc900-module
    line (derive_module).  `c_elsewhere` says where else C for it exists (lane_staged: the src-root's cc900-staged/,
    a lane worktree, a local branch main has not merged), `none` when nowhere: the C copy here is then the only one.
    A function the src-root's symbols reference no longer names (the label was renamed after the run, e.g.
    DSP_StateTable_Reset -> DSP_StateTable_Save) is left out and printed: staging it under the old name cannot
    build, and the attempts of later runs carry the new name."""
    best = {}
    for r in rows:
        if r['status'] != 'MATCH':
            continue
        k = (r['tree'], r['function'])
        if k not in best or run_key(r['run']) > run_key(best[k]['run']):
            best[k] = r
    lanes = lane_staged()
    cand_cache = {}
    lines, staged, gone = [], 0, []
    for (tree, fn), r in sorted(best.items(), key=lambda kv: (LANES.get(kv[0][0], '?'), kv[0])):
        if fn in set(Ctx.tree(tree)['cnames'].values()):
            staged += 1
            continue
        if fn not in Ctx.tree(tree)['ref']:
            gone.append(tree + ':' + fn)
            continue
        if not r['c_copy'] or not os.path.exists(os.path.join(out, r['c_copy'])):
            ctext, how = source_c(out, [r], runs)
            if not ctext and r['c_provenance'] == 'name+funcs':
                fns = [k.lstrip('_.') for k in mods()[2].listing_functions(
                    open(os.path.join(ORACLE, r['listing']), encoding='latin-1').read())]
                b, sha, prov, ref = find_source(r['source'], fns, os.path.getmtime(os.path.join(
                    ORACLE, 'runs', r['run'], 'job.log')), None, cand_cache)
                ctext = b if sha == r['c_sha256'] else b''
            if ctext:
                cdefs = c_defs_text(ctext)
                lm = label_map_text(ctext)
                cname = next((c for c in cdefs if lm.get(c, c) == fn), None) or \
                    next((c for c in cdefs if c[:C_NAME_LIMIT] == fn[:C_NAME_LIMIT]), fn)
                r['c_copy'] = write_c_copy(out, tree, fn, cname, ctext, r['c_sha256'],
                                           r['source'] + ' (' + r['run'] + ')', r['c_provenance'], r['flags'])
        mod = ''
        if r['c_copy']:
            m = derive_module(tree, os.path.join(out, r['c_copy']), only=fn)
            mod = ' '.join(m) if m else ''
        lines.append([LANES.get(tree, '?'), tree, fn, r['gen_size'], r['flags'], r['run'], r['opt'], r['c_copy'], mod,
                      lanes.get((tree, fn), 'none')])
    with open(os.path.join(out, 'ready.tsv'), 'w') as f:
        f.write('lane\ttree\tfunction\tbytes\tflags\trun\topt\tc_copy\tcc900_module\tc_elsewhere\n')
        for l in lines:
            f.write('\t'.join(str(x) for x in l) + '\n')
    per = {}
    for l in lines:
        k = (l[0], 'C nowhere else' if l[9] == 'none' else 'C elsewhere')
        per.setdefault(k, [0, 0]); per[k][0] += 1; per[k][1] += int(l[3] or 0)
    print('ready.tsv: %d functions already built from C in the tree left out; %s' % (
        staged, ', '.join('%s %s %d functions %d B' % (k[0], k[1], v[0], v[1]) for k, v in sorted(per.items()))))
    print('ready.tsv: %d functions no longer a label of their tree left out (renamed since the run)%s' % (
        len(gone), (': ' + ' '.join(gone)) if gone else ''))


if __name__ == '__main__':
    sys.exit(main())
