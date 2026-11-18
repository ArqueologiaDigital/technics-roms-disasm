#!/usr/bin/env python3
"""Which sub-CPU payload functions does Toshiba V4.23 turn into the ROM's bytes, from which C and option set?

QUESTION ANSWERED: an oracle run compiles C for functions of the sub-CPU payload (probe files
scripts/analysis/cc900/corpus/firmware/sub_<round><form>.c, and the staged C <tree>/cc900-staged/*.c) at several
option sets.  For each listing, every function is rewritten by model/to_llvm.py with the operand widths the listing
declares (`extern small|medium|large` = __tiny / __near / plain), assembled by llvm-mc and compared with the ROM at
the function's own label.  The comparison is scripts/analysis/cc900/asm_vs_rom.py's (lane_p6's version, with
`--cfile`), with the sub-CPU's address map: the payload ROM holds 0x400-0x4ff, then 0xf000 onwards
(Makefile, kn5000_subprogram_v142.llvm.rom).

    python3 -B notes/cc900-c-subcpu-2026-11-16/sub_v423.py corpus DIR FILE.c ... [--sets O3Xr,Xr,O3XSXr]
        copies the C files into DIR/sub/ and writes sources.txt / options.txt (every file at every set), then prints
        the oracle run command (one VM run for all of them)
    python3 -B notes/cc900-c-subcpu-2026-11-16/sub_v423.py check RUN_DIR [PATTERN] [--tree v142/subcpu] [--tsv OUT]
        one row per function: its size, the files@sets that MATCH, else the furthest first difference
    python3 -B notes/cc900-c-subcpu-2026-11-16/sub_v423.py record RUN_DIR [--tree v142/subcpu]
        for every <tree>/cc900-staged/*.c (all three trees unless --tree; the corpus put each under sub/<tree>/)
        that the run compiled at its own option set, writes its rows into
        notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv (tree, C file, sha256, options, run, function, bytes, result)
    python3 -B notes/cc900-c-subcpu-2026-11-16/sub_v423.py one LISTING.asm [--tree v142/subcpu] [--cfile C]
        the comparison for one listing

No Toshiba text is printed or written: names, sizes and verdicts only.  Run from the repository root.
"""
import glob, hashlib, os, re, shutil, subprocess, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
CC = os.path.join(REPO, 'scripts', 'analysis', 'cc900')
sys.path.insert(0, os.path.join(CC, 'model'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'build'))
import listing                                               # noqa: E402
import to_llvm                                               # noqa: E402
import check_bytes                                           # noqa: E402
import cc900_firmware_c as fw                                # noqa: E402

TREES = {'v142/subcpu': ('original_ROMs/kn5000_subprogram_v142.rom', 'symbols/subcpu_symbols_reference.txt'),
         'v141/subcpu': ('original_ROMs/kn5000_subprogram_v141.rom', 'symbols/subcpu_v141_symbols_reference.txt'),
         'v140/subcpu': ('original_ROMs/kn5000_subprogram_v140.rom', 'symbols/subcpu_v140_symbols_reference.txt')}
SETS = {'O3Xr': '-O3 -Xr', 'Xr': '-Xr', 'O3XSXr': '-O3 -XS -Xr', 'none': '', 'O3XS': '-O3 -XS',
        'O1Xr': '-O1 -Xr', 'O2Xr': '-O2 -Xr'}
LABEL_OF = {v: k for k, v in SETS.items()}
OPT_RE = re.compile(rb'cc900-options:([^*\n]*)')
LEDGER = os.path.join(REPO, 'notes', 'cc900-c-subcpu-2026-11-16', 'staged_v423.tsv')
ORACLE = os.path.expanduser('~/compartilhado/cc900-oracle')
FUNC_RE = re.compile(r'^[\w\s\*]+?\b(\w+)\s*\([^;{)]*\)\s*\{', re.M)


def rom_offset(addr):
    """the payload ROM's file offset of sub-CPU address ADDR"""
    if 0x400 <= addr < 0x500:
        return addr - 0x400
    assert addr >= 0xf000, hex(addr)
    return addr - 0xf000 + 0x100


KEEP_BYTES = None          # {function: our bytes} when a caller (first_diff.py) sets it to a dict
ERP_BYTE = {'ixl': 0xf0, 'ixh': 0xf1, 'qixl': 0xf2, 'qixh': 0xf3, 'iyl': 0xf4, 'iyh': 0xf5, 'qiyl': 0xf6,
            'qiyh': 0xf7, 'izl': 0xf8, 'izh': 0xf9, 'qizl': 0xfa, 'qizh': 0xfb}
ERP_RE = re.compile(r'^\t(ld|cp|inc) (?:(1|0x1), )?(%s)(?:, (0x[0-9a-f]+|\d+))?$' % '|'.join(ERP_BYTE))


def erp_byte(line):
    """V4.23 allocates the index registers' byte parts (QIZH ...), which to_llvm passes through as plain register names
    that llvm-mc does not take; write the ROM's own extended-register forms (ldib_erp / cpib_erp / inc1b_erp)"""
    m = ERP_RE.match(line)
    if not m:
        return line
    op, one, r, imm = m.groups()
    small = imm is not None and int(imm, 0) < 8            # asm900's 3-bit immediate forms (c7 rr a8+n / d8+n)
    if op == 'ld' and imm is not None and one is None:
        return '\t%s 0x%x, %s' % ('ldib_erp' if small else 'lds_erpb', ERP_BYTE[r], imm)
    if op == 'cp' and imm is not None and one is None:
        return '\t%s 0x%x, %s' % ('cpib_erp' if small else 'cp_erpb', ERP_BYTE[r], imm)
    if op == 'inc' and one and imm is None:
        return '\tinc1b_erp 0x%x' % ERP_BYTE[r]
    return line


# the upper words of the 32-bit registers (QWA ...): V4.23's `and QWA,0xff` is the ROM's `and_erpw 0xE2,0xFF,0x00`
ERP_WORD = {'qwa': 0xe2, 'qbc': 0xe6, 'qde': 0xea, 'qhl': 0xee, 'qix': 0xf2, 'qiy': 0xf6, 'qiz': 0xfa}
ERP_WORD_RE = re.compile(r'^\t(and|cp) (%s), (0x[0-9a-f]+|\d+)$' % '|'.join(ERP_WORD))
ERP_MOVE_RE = re.compile(r'^\tld (a|w|c|b|e|d|l|h), (%s)$' % '|'.join(ERP_BYTE))


ERP_PUSH_RE = re.compile(r'^\t; untranslated:\s*(push|pop)\s+(%s)\s*$' % '|'.join(ERP_WORD), re.I)


ERP_UNTRANSLATED_RE = re.compile(r'^\t; untranslated \(a byte register llvm-mc cannot name\): (\w+)\s+(\S+?)\s*,\s*(\S+)\s*$')


def erp_word(line):
    """`and QWA,imm` -> and_erpw; `ld A,IZL` -> ld_erpb_rr (helper E, round 8: these were left untranslated);
    `push QIZ` / `pop QIZ` -> pushw_erp / popw_erp (helper A, round 8); and the byte-register lines to_llvm marks
    as untranslated (`inc 1,QIZH`, `ld QIZH,n`, `cp QIZH,n`, `ld A,QIZH`), through erp_byte's forms"""
    m = ERP_UNTRANSLATED_RE.match(line)
    if m:
        op, x, y = m.group(1).lower(), m.group(2).lower(), m.group(3).lower()
        if op == 'inc' and y in ERP_BYTE:
            line = '\tinc %s, %s' % (x, y)
        elif op in ('ld', 'cp') and x in ERP_BYTE:
            line = '\t%s %s, %s' % (op, x, y)
        elif op == 'ld' and y in ERP_BYTE:
            line = '\tld %s, %s' % (x, y)
        elif op in ('or', 'cp') and y in ERP_BYTE and x in ('a', 'w', 'c', 'b', 'e', 'd', 'l', 'h'):
            return '\t%s_erpb_rr %s, 0x%x' % (op, x, ERP_BYTE[y])     # `or A,QIZH` = c7 fb e1 (helper B, round 12)
        line = erp_byte(line)
    m = ERP_PUSH_RE.match(line)
    if m:
        return '\t%sw_erp 0x%x' % (m.group(1).lower(), ERP_WORD[m.group(2).lower()])
    m = ERP_WORD_RE.match(line)
    if m:
        op, v = m.group(1), int(m.group(3), 0)
        if op == 'cp' and v < 8:                       # asm900's 3-bit compare form
            return '\tcpiw_erp 0x%x, %d' % (ERP_WORD[m.group(2)], v)
        return '\t%s_erpw 0x%x, 0x%x, 0x%x' % (op, ERP_WORD[m.group(2)], v & 0xff, v >> 8)   # `cp QIZ,1000` (helper C)
    m = ERP_MOVE_RE.match(line)
    if m:
        return '\tld_erpb_rr %s, 0x%x' % (m.group(1), ERP_BYTE[m.group(2)])
    return line


def file_flags(path):
    m = OPT_RE.search(open(path, 'rb').read())
    return ' '.join(m.group(1).decode().split()) if m else '-O3 -Xr'


def compare(lst, tree='v142/subcpu', cfiles=()):
    """[(function, bytes, verdict)] for one V4.23 listing"""
    romf, symf = TREES[tree]
    rom = open(os.path.join(REPO, romf), 'rb').read()
    ref = check_bytes.load_reference(os.path.join(REPO, symf))
    # Toshiba runtime routines V4.23 calls, by the payload's label for them (subcpu_fp_math.s headers)
    # (the division entries by their code, helper E, round 5: D = 1 keeps XHL, the quotient; D = 0 XDE, the remainder;
    # confirmed by DSP_PanScale_Simple in run 2026-11-16-65-sub-r5, renamed by scripts/renaming/rename_subcpu_long_div.sed)
    alias, cnames = {'C9H_mulls': 'Math_Multiply32', 'C9H_mullu': 'Math_Multiply32',
                     'C9H_divls': 'Long_SignedDiv', 'C9H_remls': 'Long_SignedRem',
                     'C9H_remlu': 'Int_UnsignedRemainder'}, {}
    # CANDIDATE floating-point pairs (round 19): V4.23's names (sub_fp_19a/b.asm) by meaning, not yet confirmed by a
    # match; a match confirms a pair, and only confirmed pairs go into scripts/build/cc900_runtime_names.tsv.
    for v, t in (('_fadd_f', 'FP_fadd'), ('_fsub_f', 'FP_fsub'), ('_fmul_f', 'FP_fmul'), ('_fdiv_f', 'FP_fdiv'),
                 ('_fcmp_f', 'FP_fcmp'), ('_fadd_d', 'FP_dadd'), ('_fsub_d', 'FP_dsub'), ('_fmul_d', 'FP_dmul'),
                 ('_fdiv_d', 'FP_ddiv'), ('_fcmp_d', 'FP_dcmp'), ('_fld_df', 'FP_ftod'), ('_fld_fd', 'FP_dtof'),
                 ('_fld_lf', 'FP_ftoi'), ('_pow', 'FP_pow'), ('_sin', 'FP_sin'), ('_cos', 'FP_cos'),
                 ('_tan', 'FP_tan'), ('_fabs', 'FP_fabs'), ('_exp', 'FP_exp'), ('_log', 'FP_log'),
                 ('_frexp', 'FP_frexp'), ('_ldexp', 'FP_ldexp'), ('_modf', 'FP_modf'),
                 # helper AC's candidates from the routines' bodies (subcpu_fp_math.s headers), round 20
                 ('_fld_fl', 'FP_SP_CallWithBuf8'), ('_fld_ful', 'FP_SP_CallWithBuf8b'),
                 ('_fld_dl', 'FP_ScalarToDP'), ('_fld_dul', 'FP_DP_CallWithBuf12'), ('_fld_ld', 'FP_DP_DecodeToInt'),
                 ('_fneg_f', 'FP_SP_CopyOrNegate4'), ('_fneg_d', 'FP_DP_CopyOrNegate8'),
                 ('_fcmp_zf', 'FP_SP_CmpZero32'), ('_fcmp_zd', 'FP_DP_CmpZero64'),
                 ('_fld_ff', 'FP_SP_Raw4Copy'), ('_fld_dd', 'FP_DP_Raw8Copy')):
        if os.environ.get('SUB_V423_NO_FP') is None:
            for k in (v, '.' + v, v.lstrip('_')):
                alias.setdefault(k, t)
    for c in list(cfiles) + glob.glob(os.path.join(REPO, tree, 'cc900', '*.c')):
        lm = fw.label_map(c)
        alias.update(lm)
        for n in FUNC_RE.findall(open(c, encoding='latin-1').read()):
            cnames[n[:31]] = lm.get(n, n)

    class CutNames(fw.Names):
        def resolve(self, n):
            if n in alias:
                n = alias[n]
            r = super().resolve(n)
            b = n.lstrip('._')                   # a callee keeps the listing's '.' / '_' prefix (helper A, round 3)
            if r[0] is None and b != n:
                r = super().resolve(alias.get(b, b))
            if r[0] is None and len(b) == 31:
                full = [k for k in list(self.values) + list(self.labels) if len(k) > 31 and k[:31] == b]
                if len(set(full)) == 1:
                    return super().resolve(full[0])
            return r
    names = CutNames(fw.tree_values(os.path.join(REPO, tree)), ref)
    to_llvm.SPELL = None
    module = set()                       # cc900-module: callees asm900 saw in the caller's module (calr / jr / jrl)
    places = {}                          # cc900-data: {function: {n: tree label}}
    for c in cfiles:
        module |= fw.module_names(c)
        places.update(fw.data_map(c))
    to_llvm.MODULE = (module | {c for c, l in alias.items() if l in module}) if module else None   # labels and C names
    text = open(lst, encoding='latin-1').read()
    to_llvm.WIDTHS = listing.attributes(text)
    short = {}
    for n in ref:
        short.setdefault(n[:31], []).append(n)
    out = []
    for name, lines in listing.split(text).items():
        bare = name.lstrip('_.')
        full = cnames.get(bare) if cnames.get(bare) in ref else bare if bare in ref else \
            '_' + bare if '_' + bare in ref else \
            (short.get(bare, [None])[0] if len(short.get(bare, [])) == 1 else None)
        if full is None:
            out.append((bare, 0, 'not in the symbols reference')); continue
        # f_const data (a switch's jump table ...): the C file's `cc900-data: FUNCTION N = LABEL` places the N-th
        # object at the tree's LABEL, as the build does; the code is checked with that address (the table's own bytes
        # are checked by make gate, as in c_build_coverage.translate)
        consts, _ = to_llvm.split_consts(lines)
        pl = places.get(bare, places.get(full, {}))
        to_llvm.DATA = {c: '0x%x' % ref[pl[k]] for k, c in enumerate(consts, 1) if k in pl and pl[k] in ref}
        to_llvm.DATA_REQUIRED = bool(consts)
        try:
            body = [l for l in to_llvm.translate_function(name, lines, names)
                    if l not in ('\t.globl %s' % bare, bare + ':')]
        except KeyError as e:
            out.append((full, 0, 'cannot resolve %s' % e)); continue
        body = [l.replace('$+', '.+').replace('$-', '.-') for l in body]   # inline asm's `jr $+2` (llvm-mc spells `.`)
        body = [erp_word(erp_byte(l)) for l in body]

        def module_jump(l):          # a conditional jump to a module-local function keeps the listing's '.' name
            m = re.match(r'^\t(jrl?) (\w+), \.([A-Za-z_]\w*)$', l)      # (helper A, round 9: Voice_Reprioritise)
            if m:
                tgt = alias.get(m.group(3), m.group(3))
                if tgt in ref:
                    return '\t%s %s, __cc900_at_%x' % (m.group(1), m.group(2), ref[tgt])
            return l
        body = [module_jump(l) for l in body]
        # a shift by 16: to_llvm writes the raw count field 0, llvm-mc wants 16 (the CPU encodes 16 as 0)
        body = [re.sub(r'^(\t(?:sla|sll|sra|srl|rlc|rrc|rl|rr) \w+), 0$', r'\1, 16', l) for l in body]
        # the address of one of the function's own labels as data (a switch's `lda xix, <case base>` before
        # `jp t, xix+wa`): the unit is assembled at 0, so spell it as the function's ROM address plus the distance
        own = {m.group(1) for l in body for m in [re.match(r'^([.\w$]+):', l)] if m}

        def own_address(l):
            m = re.match(r'^(\tlda \w+, )\(([.\w$]+):24\)$', l)
            if m and m.group(2) in own:
                return '%s(0x%x + %s - %s:24)' % (m.group(1), ref[full], m.group(2), full)
            return l
        body = [own_address(l) for l in body]
        if any('untranslated' in l for l in body):
            if os.environ.get('SUB_V423_SHAPES'):          # the offending lines' shapes (numbers masked), no text
                for l in body:
                    if 'untranslated' in l:
                        print('  untranslated shape:', re.sub(r'\b\d+\b', 'N', re.sub(r'0x[0-9a-fA-F]+', 'H',
                                                                                        l.strip())))
            out.append((full, 0, 'to_llvm cannot translate a line')); continue
        plain = '\n'.join(body)
        targets = sorted({int(m.group(1), 16) for m in re.finditer(r'__cc900_at_([0-9a-f]+)', plain)})
        at = ref[full]
        if targets and any(abs(t - at) > 0x10000 for t in targets):
            out.append((full, 0, 'a module-local target is out of calr / jrl reach')); continue

        def source(text_):
            if not targets:
                return '\t.text\n\t.globl %s\n%s:\n%s\n' % (full, full, text_)
            # module-local calls: lay the function and its targets out at their addresses in one unit
            base = min(targets + [at])
            self_ = '__cc900_at_%x:\n' % at if at in targets else ''
            items = sorted([(t, '__cc900_at_%x:' % t) for t in targets if t != at] +
                           [(at, '%s\t.globl %s\n%s:\n%s\n\t.globl __cc900_end\n__cc900_end:' % (self_, full, full, text_))])
            return '\t.text\n' + '\n'.join('\t.org 0x%x\n%s' % (a - base, txt) for a, txt in items) + '\n'
        mine = None
        # asm900's j is jr when the target is in reach: assemble the layout with every jr first (to_llvm.relax would
        # widen a jr to a not-yet-placed module label into jrl, helper A, round 8), then the relaxed text
        for text_ in ([plain] if targets else []) + [to_llvm.relax(plain, fw.assembler_errors)]:
            try:
                mine = check_bytes.assemble(source(text_))[full]     # up to the next global label or the end
                break
            except Exception:
                continue
        if mine is None:
            out.append((full, 0, 'llvm-mc cannot assemble the translation')); continue
        if KEEP_BYTES is not None:              # first_diff.py: the assembled bytes, for a side-by-side view
            KEEP_BYTES[full] = mine
        at = rom_offset(ref[full])
        r = rom[at:at + len(mine)]
        if mine == r:
            out.append((full, len(mine), 'MATCH'))
        else:
            first = next(i for i in range(len(mine)) if i >= len(r) or mine[i] != r[i])
            out.append((full, len(mine), 'DIFF at +%d' % first))
    return out


def corpus(d, files, sets):
    d = os.path.abspath(d)
    os.makedirs(os.path.join(d, 'sub'), exist_ok=True)
    srcs = []
    for f in files:
        rel = os.path.relpath(os.path.abspath(f), REPO).split(os.sep)
        sub = 'sub/%s/' % rel[0] if len(rel) == 4 and rel[2] == 'cc900-staged' else 'sub/'   # staged: per tree
        os.makedirs(os.path.join(d, sub), exist_ok=True)
        shutil.copyfile(f, os.path.join(d, sub, os.path.basename(f)))
        for h in re.findall(r'#include\s+"([^"]+)"', open(f, encoding='latin-1').read()):
            shutil.copyfile(os.path.join(os.path.dirname(f), h), os.path.join(d, sub, h))
        srcs.append(sub + os.path.basename(f))
    open(os.path.join(d, 'sources.txt'), 'w').write(''.join(s + '\n' for s in srcs))
    open(os.path.join(d, 'options.txt'), 'w').write(''.join('%s|%s\n' % (s, SETS[s]) for s in sets))
    print('%d C files in %s, option sets %s' % (len(srcs), d, ' '.join(sets)))
    print('run (from scripts/analysis/cc900; it takes a free slot of the VM pool, no flock): '
          'bash oracle/run_oracle.sh <name> %s %s/sources.txt %s/options.txt v423' % (d, d, d))


def find_c(stem):
    for p in [os.path.join(CC, 'corpus', 'firmware', stem + '.c')] + \
            glob.glob(os.path.join(REPO, 'v14?', 'subcpu', 'cc900-staged', stem + '.c')):
        if os.path.exists(p):
            return p
    return None


def check(run, pat, tree, tsv):
    import fnmatch
    res = {}
    base = os.path.join(run, 'out', 'v423')
    for label in sorted(os.listdir(base)):
        d = os.path.join(base, label, 'sub')
        if not os.path.isdir(d):
            continue
        for f in sorted(os.listdir(d)):
            stem = f[:-4]
            if not f.endswith('.asm') or not fnmatch.fnmatch(stem, pat):
                if f.endswith('.cc.log') and fnmatch.fnmatch(f[:-7], pat) and \
                        not os.path.exists(os.path.join(d, f[:-7] + '.asm')):
                    print('%s %s: V4.23 refused the file (see its .cc.log)' % (label, f[:-7]))
                continue
            src = find_c(stem)
            for fn, n, v in compare(os.path.join(d, f), tree, [src] if src else []):
                res.setdefault(fn, {})[(stem, label)] = (n, v)
    rows = []
    for fn in sorted(res):
        v = res[fn]
        ok = sorted('%s@%s' % k for k, x in v.items() if x[1] == 'MATCH')
        size = max(x[0] for x in v.values() if x[1] == 'MATCH') if ok else max(x[0] for x in v.values())
        diffs = [(int(x[1].split('+')[1]), '%s@%s' % k) for k, x in v.items() if x[1].startswith('DIFF')]
        other = sorted(set(x[1] for x in v.values() if not x[1].startswith(('MATCH', 'DIFF'))))
        best = '+%d %s' % max(diffs) if diffs else '; '.join(other)
        rows.append((fn, size, ' '.join(ok) or '-', '' if ok else best))
    w = max([len(r[0]) for r in rows] + [8])
    for r in rows:
        print('%-*s %4d B  %-5s %s' % (w, r[0], r[1], 'MATCH' if r[2] != '-' else 'diff', r[2] if r[2] != '-' else r[3]))
    n = [r for r in rows if r[2] != '-']
    print('%d of %d functions match; %d B' % (len(n), len(rows), sum(r[1] for r in n)))
    if tsv:
        with open(tsv, 'w') as fh:
            fh.write('function\tbytes\tmatches\tbest_diff\n')
            for r in rows:
                fh.write('%s\t%d\t%s\t%s\n' % r)


def sha256(p):
    return hashlib.sha256(open(p, 'rb').read()).hexdigest()


def record(run, trees):
    """the staged C of TREES that RUN compiled (listing sub/<tree>/<stem>.asm at the file's option set)"""
    runname = os.path.basename(os.path.normpath(run))
    out = []
    for tree in trees:
        t = tree.split('/')[0]
        for c in sorted(glob.glob(os.path.join(REPO, tree, 'cc900-staged', '*.c'))):
            stem = os.path.basename(c)[:-2]
            label = LABEL_OF[file_flags(c)]
            lst = os.path.join(run, 'out', 'v423', label, 'sub', t, stem + '.asm')
            if not os.path.exists(lst):
                print('%s %s: the run has no listing at %s' % (t, stem, label)); continue
            for fn, n, v in compare(lst, tree, [c]):
                out.append([t, os.path.relpath(c, REPO), sha256(c), label, runname, fn, str(n), v])
                print('%-5s %-36s %-4s %-36s %4d  %s' % (t, os.path.basename(c), label, fn, n, v))
    keep = []
    if os.path.exists(LEDGER):
        done = {r[1] for r in out}
        keep = [l.rstrip('\n').split('\t') for l in open(LEDGER) if not l.startswith(('#', 'tree\t'))]
        keep = [k for k in keep if k[1] not in done]
    rows = sorted(keep + out, key=lambda r: (r[1], r[5]))
    with open(LEDGER, 'w') as fh:
        fh.write('# Staged sub-CPU firmware C (<tree>/cc900-staged/) checked against the ROM with Toshiba V4.23, by\n'
                 '# notes/cc900-c-subcpu-2026-11-16/sub_v423.py record.  The listings stay in the private oracle repo.\n'
                 '# Caveat: the sha256 is of the C file as it is now; the run must have compiled that same text.\n'
                 'tree\tc_file\tsha256\toptions\trun\tfunction\tbytes\tresult\n')
        for r in rows:
            fh.write('\t'.join(r) + '\n')
    print('%d rows in %s' % (len(rows), os.path.relpath(LEDGER, REPO)))


def opt(a, n, d):
    return a[a.index(n) + 1] if n in a else d


def main():
    a = sys.argv[1:]
    if not a:
        sys.exit(__doc__)
    tree = opt(a, '--tree', 'v142/subcpu')
    if a[0] == 'corpus':
        files = [x for x in a[2:] if x.endswith('.c')]
        return corpus(a[1], files, opt(a, '--sets', 'O3Xr,Xr,O3XSXr').split(','))
    if a[0] == 'check':
        pat = a[2] if len(a) > 2 and not a[2].startswith('--') else '*'
        return check(a[1], pat, tree, opt(a, '--tsv', None))
    if a[0] == 'record':
        return record(a[1], [tree] if '--tree' in a else sorted(TREES))
    if a[0] == 'one':
        cf = [a[i + 1] for i, x in enumerate(a) if x == '--cfile']
        for fn, n, v in compare(a[1], tree, cf):
            print('%-36s %4d B  %s' % (fn, n, v))
        return 0
    sys.exit(__doc__)


if __name__ == '__main__':
    sys.exit(main())
