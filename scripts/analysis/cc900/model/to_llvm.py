#!/usr/bin/env python3
"""Translate the model's Toshiba-syntax listing into our LLVM TLCS-900 syntax, choosing asm900's encodings.

usage: python3 -I -B to_llvm.py FILE.c SYMBOLS.txt [--opt O3XS] [--adecl] [--personality kn5000] [--only NAME,...]
                                [-D...] [-I...]
Compiles FILE.c with the reference model and prints one llvm-mc source on stdout; each function becomes a global
label (its name without the `_` / `.` prefix).  As a module, translate_function(name, lines, syms) does the same for
one function and returns its lines; relax() turns out-of-reach jr into jrl.

The encodings asm900 picks, read from the firmware (v10 String_Compare, Strcat, the phase 6 functions):
- `ld r8,n` is the 2-byte compact form (`ld l, 0x0:opc`); `ld r16/r32,n` and `cp r,n` with n in 0..7 the 3-bit
  form (`ld hl, 0:i3`, `cp bc, 0:i3`); a larger `ld r16,n` the 3-byte compact form (`ldw hl, 0xffff`, _strlen);
- `j cc,L` / `j L` are `jr` when the target is in reach and `jrl` otherwise; `cal _f` is `call` with a 24-bit
  address; a 16-bit push / pop of WA..IZ is the 1-byte form;
- an absolute operand is `(ADDR:8)` below 0x100, `(ADDR:16)` below 0x10000, `(ADDR:24)` above -- except a symbol
  the compiler declared `extern large` (every extern of the 1997 library, which is built `__LARGE__`), which is always
  24-bit: the table data's `.sbrk` reads `_SBRK_size` at 0x999c as `e2 9c 99 00 23`.  Set LARGE_DATA for such code.
SYMBOLS.txt rows are `NAME 0xADDR`; a C name is looked up with and without its `_` / `.` prefix.  An instruction the
translator does not know is written as `; untranslated: ...`, so that the assembler stops on it.
"""
import os, re, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

CC = {'eq': 'z', 'ne': 'nz', 'lt': 'lt', 'le': 'le', 'gt': 'gt', 'ge': 'ge', 'ult': 'c', 'uge': 'nc', 'ugt': 'ugt',
      'ule': 'ule', 'm': 'mi', 'p': 'pl', 'z': 'z', 'nz': 'nz', 'c': 'c', 'nc': 'nc', 'ov': 'ov', 'nov': 'nov', 't': 't'}
R8 = {'A', 'W', 'B', 'C', 'D', 'E', 'H', 'L'}
REGS = re.compile(r'^(Q?[WABCDEHL]|Q?(WA|BC|DE|HL|IX|IY|IZ|SP)|X(WA|BC|DE|HL|IX|IY|IZ|SP)|Q?I[XYZ][LH])$')
NUM = re.compile(r'^-?(0x[0-9a-fA-F]+|\d+)$')
REG32 = re.compile(r'^X(WA|BC|DE|HL|IX|IY|IZ|SP)$')
QIDX = re.compile(r'^\((X(?:WA|BC|DE|HL|IX|IY|IZ|SP))\+(Q(?:WA|BC|DE|HL|IX|IY|IZ|SP))\)$')
XBASE = {'XWA': 0xe0, 'XBC': 0xe4, 'XDE': 0xe8, 'XHL': 0xec, 'XIX': 0xf0, 'XIY': 0xf4, 'XIZ': 0xf8, 'XSP': 0xfc}

def load_symbols(path):
    out = {}
    for l in open(path):
        p = l.split()
        if len(p) == 2 and not l.startswith('#'):
            try: out[p[0]] = int(p[1], 16)
            except ValueError: pass
    return out

def lookup(sym, syms):
    for n in (sym, sym.lstrip('_.')):
        if n in syms: return syms[n]
    raise KeyError('no address for %s' % sym)

LARGE_DATA = False                                       # named absolute operands are `extern large`: 24-bit
# SPELL (phase 6 build, scripts/build/cc900_firmware_c.py): {C name without `_` / `.`: its spelling in the source
# tree}.  When set, a named operand is written by that spelling (`(LSW_FILTER:24)`, `call FuncName`), so the tree's
# own definitions supply the value; the address from SYMBOLS still picks the 8/16/24-bit width.  A name SPELL lacks
# is written as its address, as before.
SPELL = None

def spell_of(sym):
    """SPELL's name for `sym`: the build's resolver (Names) takes V4.23's name as it is and drops the prefix itself,
    trying `_name` too (`._findfirst` is the tree's _findfirst); a plain mapping is asked without the prefix"""
    if SPELL is None: return None
    return SPELL.get(sym) if hasattr(SPELL, 'resolve') else SPELL.get(sym.lstrip('_.'))
# WIDTHS (phase 6 firmware C): {symbol without `_` / `.`: 8, 16 or 24}, the width cc900 gives the symbol's absolute
# operand from its declaration -- `__tiny` (listing `small`), `__near` (`medium`) or plain (`large`) -- not from its
# address (probe m16, run 2026-11-16-29-p6-m16).  When set, a named operand or `lda` of a symbol takes that width, and
# a symbol it lacks stops the translation (no guess from the address).  scripts/build/cc900_firmware_c.py sets it from
# V4.23's listing (listing.attributes) or, for the model, from the C's declarations.  None: the address rule above.
WIDTHS = None

def sym_width(sym):
    n = sym.lstrip('_.')
    if n not in WIDTHS: raise KeyError('no declared width (small / medium / large) for %s' % sym)
    return WIDTHS[n]

# MODULE (phase 6): the names asm900 saw in the same section of the same assembly -- in the firmware build, the ones
# the C file's `cc900-module:` comment says shared the caller's original module (never merely the C file's other
# functions: our files group by hand source, not by module) -- or None.  asm900 assembles the
# optimising CAL / J to such a target as calr / jr, jrl when jr does not reach; to anything else (an extern) as call /
# jp, 24-bit for a large target and 16-bit (call16 / jp16) for a __near or __tiny one (probe calrel, run
# 2026-11-16-42-p6-calrel; ASM900 -O turns the optimisation off).  We write jr and let llvm-mc widen it.
MODULE = None

def module_local(sym):
    if MODULE is None or sym.startswith('L') and sym[1:].isdigit(): return False
    b = sym.lstrip('_.')
    return b in MODULE or (len(b) == 31 and any(m[:31] == b for m in MODULE if len(m) > 31))

def code_width(sym):
    """a call / jump target's width: the declared one (WIDTHS) when known, else 24 (large)"""
    return (WIDTHS or {}).get(sym.lstrip('_.'), 24)

def branch_target(sym, syms):
    """a relative branch's operand: the tree's name, or, without SPELL (an address-only check), a placeholder
    `__cc900_at_<hex address>` that the checker defines beside the function (c_build_coverage.compare)"""
    s = spell_of(sym)
    return s if s else '__cc900_at_%x' % lookup(sym, syms)

# byte registers of XIX / XIY / XIZ, which llvm-mc reaches only through their extended-register code (the ERP forms)
ERP_BYTE = {'IXL': 0xf0, 'IXH': 0xf1, 'QIXL': 0xf2, 'QIXH': 0xf3, 'IYL': 0xf4, 'IYH': 0xf5, 'QIYL': 0xf6, 'QIYH': 0xf7,
            'IZL': 0xf8, 'IZH': 0xf9, 'QIZL': 0xfa, 'QIZH': 0xfb,
            # the upper bytes of XWA .. XHL (bytes 2 / 3 of the 32-bit register: QA = E2, QW = E3, ...)
            'QA': 0xe2, 'QW': 0xe3, 'QC': 0xe6, 'QB': 0xe7, 'QE': 0xea, 'QD': 0xeb, 'QL': 0xee, 'QH': 0xef}
# the upper words of the 32-bit registers, by extended code (and / or / add with an immediate: the *_erpw forms)
Q_WORD = {'QWA': 0xe2, 'QBC': 0xe6, 'QDE': 0xea, 'QHL': 0xee, 'QIX': 0xf2, 'QIY': 0xf6, 'QIZ': 0xfa, 'QSP': 0xfe}
ERP_IMM_OP = {'add': 'add_erpb', 'sub': 'sub_erpb', 'and': 'and_erpb', 'or': 'or_erpb', 'xor': 'xor_erpb'}
ERP_BIT_OP = {'bit': 'bit_erpb', 'set': 'set_erpb', 'res': 'res_erpb', 'sll': 'sll_erpb', 'srl': 'srl_erpb'}

QIDX_ALU = {'add': 0x38, 'adc': 0x39, 'sub': 0x3a, 'sbc': 0x3b, 'and': 0x3c, 'xor': 0x3d, 'or': 0x3e, 'cp': 0x3f}
QIDX_PSEUDO = {(False, 'ld'): 'stib_ind', (False, 'cp'): 'cpib_sri', (False, 'sub'): 'sub_srib_im',
               (False, 'and'): 'and_srib_im', (False, 'or'): 'or_srib_im',
               (True, 'ld'): 'stiw_ind', (True, 'cp'): 'cpiw_sri', (True, 'and'): 'and_sriw_im', (True, 'or'): 'or_sriw_im'}

def qidx_imm(base, word, xb, qw, n):
    """`OP (Xrr+Qrr),#` (a byte or word in memory indexed by an upper word, ld / cp / the ALU ops with an immediate):
    llvm-mc has no operand syntax for the (Xrr+Qrr) mode, so the instruction is its raw-byte pseudo where the backend
    has one, else its bytes.  Encoding (TLCS900InstrInfo.td, "(base+idx16) on every ... memory operation"): source
    prefix c3 (byte) / d3 (word), 07, base, index, then 0x38 add .. 0x3f cp and the immediate; ld is the destination
    prefix f3, 07, base, index, 0x00 (byte) / 0x02 (word) and the immediate.  lane_p6: Sprintf_FormatGGeneral's
    `orb (XDE+QIZ),0x30` = c3 07 e8 fa 3e 30."""
    imm = [n & 0xff, (n >> 8) & 0xff] if word else [n & 0xff]
    p = QIDX_PSEUDO.get((word, base))
    if p:
        return '\t%s 0x07, 0x%x, 0x%x, %s' % (p, xb, qw, ', '.join('0x%x' % b for b in imm))
    b = [0xd3 if word else 0xc3, 0x07, xb, qw, QIDX_ALU[base]] + imm
    return '\t.byte %s\t; %s%s (x+q), 0x%x' % (', '.join('0x%02x' % x for x in b), base, 'w' if word else '', n)

def erp_byte(op, raw):
    """an instruction on a byte register llvm-mc names only by its extended code (IXL .. QIZH, QA .. QH) -> its ERP
    form, or an `untranslated` line: never the generic path, where llvm-mc would read `qa` as a symbol"""
    b = op[:-1] if op.endswith('b') and op[:-1] in ('ld', 'cp', 'add', 'sub', 'and', 'or', 'xor') else op
    if b == 'ld' and len(raw) == 2 and raw[0] in ERP_BYTE and raw[1] in R8:
        return '\tst_erpb_rr %s, 0x%x' % (raw[1].lower(), ERP_BYTE[raw[0]])   # ld IXL,C = c7 f0 9b
    if b == 'ld' and len(raw) == 2 and raw[0] in R8 and raw[1] in ERP_BYTE:
        return '\tld_erpb_rr %s, 0x%x' % (raw[0].lower(), ERP_BYTE[raw[1]])   # ld C,IXL = c7 f0 8b
    if b in ('ld', 'cp') and len(raw) == 2 and raw[0] in ERP_BYTE and NUM.match(raw[1]):
        n = num(raw[1]) & 0xff                         # 0..7: the 3-byte short form (ld QIZH,1 = c7 fb a9), as the ROM has
        if n <= 7: return '\t%s 0x%x, %d' % ('lds_erpb' if b == 'ld' else 'cps_erpb', ERP_BYTE[raw[0]], n)
        return '\t%s 0x%x, 0x%x' % ('ldi_erpb' if b == 'ld' else 'cp_erpb', ERP_BYTE[raw[0]], n)
    if b in ERP_IMM_OP and len(raw) == 2 and raw[0] in ERP_BYTE and NUM.match(raw[1]):
        return '\t%s 0x%x, 0x%x' % (ERP_IMM_OP[b], ERP_BYTE[raw[0]], num(raw[1]) & 0xff)
    if b in ('cp', 'or') and len(raw) == 2 and raw[0] in ERP_BYTE and raw[1] in R8:
        return '\t%s_erpb_rr %s, 0x%x' % (b, raw[1].lower(), ERP_BYTE[raw[0]])
    if b in ('cp', 'add', 'sub', 'and', 'or') and len(raw) == 2 and raw[0] in R8 and raw[1] in ERP_BYTE:
        # the byte register as the SECOND operand, `OP r,QC` (V4.23: cp L,QC in Voice_Build_SoundingVoiceList):
        # c7 <bank> <op base + r>, llvm-mc's cpb_erp / addb_erp / ... r, bank (the ROM's Voice_Poly_NoteOn:
        # cpb_erp A, 0xFA = c7 fa f1, cp A,QIZL).  No xorb_erp exists, so xor stays untranslated.
        return '\t%sb_erp %s, 0x%x' % (b, raw[0].lower(), ERP_BYTE[raw[1]])
    if op in ('inc', 'dec') and len(raw) == 2 and NUM.match(raw[0]) and raw[1] in ERP_BYTE and 0 <= num(raw[0]) <= 8:
        return '\t%sb_erp 0x%x, %d' % (op, ERP_BYTE[raw[1]], num(raw[0]) or 8)   # inc 0x1,QIZH = c7 fb 61 (lane_sub);
        #                                                                   a count field of 0 means 8 (2026-11-19)
    if op in ERP_BIT_OP and len(raw) == 2 and NUM.match(raw[0]) and raw[1] in ERP_BYTE:
        return '\t%s 0x%x, %d' % (ERP_BIT_OP[op], ERP_BYTE[raw[1]], num(raw[0]))
    return '\t; untranslated (a byte register llvm-mc cannot name): ' + op + ' ' + ','.join(raw)

# PLACEHOLDER (the build): the value a label of the tree resolves to before the assembler places it
# (cc900_firmware_c.ROM_LABEL).  A number computed from it would be a wrong byte, so every such use stops instead.
PLACEHOLDER = None

def no_placeholder(sym, a):
    if PLACEHOLDER is not None and a == PLACEHOLDER:
        raise KeyError('%s: its address would come from the label placeholder; it must be written by name' % sym)
    return a

def spelled(sym, a, off=0):
    """the operand text for symbol `sym` (+ off) at address a: the tree's name when SPELL has it, else the number"""
    s = spell_of(sym)
    if s is None: return '0x%x' % (no_placeholder(sym, a) + off)
    return '%s+%d' % (s, off) if off else s

def absaddr(a, named=False, sym=None, off=0):
    if named and sym and WIDTHS is not None:
        return '(%s:%d)' % (spelled(sym, a, off), sym_width(sym))
    w = 24 if named and LARGE_DATA else 8 if a + off < 0x100 else 16 if a + off < 0x10000 else 24
    return '(%s:%d)' % (spelled(sym, a, off) if sym else '0x%x' % (a + off), w)

def num(s):
    s = s.strip(); neg = s.startswith('-'); s = s.lstrip('-')
    v = int(s, 16) if s.lower().startswith('0x') else int(s)
    return -v if neg else v

def operand(o, syms, locals_):
    """one Toshiba operand in our syntax, or None"""
    o = o.strip()
    if REGS.match(o): return o.lower()
    m = re.match(r'^\(([_.][A-Za-z0-9_]+)(?:\s*\+\s*(0x[0-9a-fA-F]+|\d+))?\)$', o)
    if m: return absaddr(lookup(m.group(1), syms), named=True, sym=m.group(1),
                         off=num(m.group(2)) if m.group(2) else 0)
    m = re.match(r'^\((0x[0-9a-fA-F]+|\d+)\)$', o)               # a numeric absolute address: a member of a struct at
    if m: return absaddr(num(m.group(1)))                        # a constant address, V4.23 ldw (0xd0a8),0x0
    m = re.match(r'^\((X\w+)\+:(\d)\)$', o)                     # post-increment
    if m: return '(%s+:%s)' % (m.group(1).lower(), m.group(2))
    m = re.match(r'^\(-(X\w+):(\d)\)$', o)                       # pre-decrement
    if m: return '(-%s:%s)' % (m.group(1).lower(), m.group(2))
    m = re.match(r'^\((X\w+)\+(0x[0-9a-fA-F]+|\d+)\)$', o)       # (xsp+4)
    if m and num(m.group(2)) == 0: return '(%s+0:8)' % m.group(1).lower()   # (XSP+0x0): asm900 keeps the d8 0
    if m: return '(%s+%d)' % (m.group(1).lower(), num(m.group(2)))           # (MIDI_SendControlChange; `(xsp)` is 1 B shorter)
    m = re.match(r'^\((X\w+)-(0x[0-9a-fA-F]+|\d+)\)$', o)
    if m: return '(%s-%d)' % (m.group(1).lower(), num(m.group(2)))
    m = re.match(r'^\((X\w+)\+(\w+)\)$', o)                     # (xix+hl)
    if m: return '(%s+%s)' % (m.group(1).lower(), m.group(2).lower())
    m = re.match(r'^\((X\w+)\)$', o)
    if m: return '(%s)' % m.group(1).lower()
    if NUM.match(o): return o.lower()
    if o in locals_: return o
    m = re.match(r'^\((X\w+)\+\)$', o)                         # inline assembly: (XIX+), (-XIX)
    if m: return '(%s+)' % m.group(1).lower()
    m = re.match(r'^\(-(X\w+)\)$', o)
    if m: return '(-%s)' % m.group(1).lower()
    if re.match(r'^[_.][A-Za-z0-9_]+$', o): return spelled(o, lookup(o, syms))
    if o in CONSTS:                                     # an f_const object's address as an immediate (add XWA,S50000)
        if o in DATA: return DATA[o]
        if DATA_REQUIRED:
            raise KeyError('V4.23 constant data %s (a jump table / constant) has no place in the tree: name it with a '
                           '`cc900-data: FUNCTION N = LABEL` comment' % o)
    return None

def size_suffix(op):
    """cpb / ldb ... -> cp / ld (the operand decides the size in our syntax); the word forms keep their w"""
    if op in ('ldw', 'cpw', 'addw', 'subw', 'andw', 'orw', 'xorw', 'incw', 'decw'): return op[:-1], 'w'
    if op.endswith('b') and op[:-1] in ('ld', 'cp', 'add', 'sub', 'and', 'or', 'xor', 'inc', 'dec'): return op[:-1], 'b'
    return op, ''

FIMS_RE = re.compile(r'\bfims\(([-+]?[0-9.]+(?:[eE][-+]?\d+)?)\)')


def fims(t):
    """asm900's `fims(3.0)`: a single-precision float constant used as a 32-bit immediate (V4.23 writes it for a float
    constant moved into a register, `ld XWA,fims(3.0)`; the ROM has `ld xwa,0x40400000`) -> its IEEE-754 bits in hex.
    lane_sub's checker did this before the translator did (sub_v423.py, 2026-11-18); fims_check.py checks it.
    Written without leading zeros, so that fims(0) is `0x0` and takes the short `ld xwa, 0:i3` as any other
    `ld XWA,0x0` does (the ROM's DSP_BiquadCoeff_Compute zero tap, helper AU, 2026-11-21)."""
    import struct
    return FIMS_RE.sub(lambda m: '0x%x' % struct.unpack('<I', struct.pack('<f', float(m.group(1))))[0], t)


def translate_line(t, syms, locals_):
    if 'fims(' in t: t = fims(t)
    if t.endswith(':') and not t.startswith('\t'): return t
    parts = t.strip().split(None, 1); op = parts[0]
    raw = [a.strip() for a in re.split(r',(?![^()]*\))', parts[1])] if len(parts) > 1 else []
    # V4.23 (inline assembly) writes the current location as `$` (jr $+2); llvm-mc writes it `.`.  Only a `$` standing
    # alone in an operand expression: never inside a quoted string, a symbol name or a `$`-prefixed number.
    raw = [a if "'" in a or '"' in a else re.sub(r'(?<![\w$.])\$(?![\w$])', '.', a) for a in raw]
    if op == 'align': return '\t.balign %s' % raw[0]
    if op == 'dfb' and len(raw) == 2: return '\t.fill %s, 1, %s' % (raw[0], raw[1])   # _CTYPE.C: dfb 128,0
    if op == 'dsb' and len(raw) == 1: return '\t.zero %s' % raw[0]
    if op in ('db', 'dw', 'dl'):
        out = []
        for a in raw:
            if a.startswith('"'): out.append('\t.ascii %s' % a); continue
            if '-' in a and not a.startswith('-') and all(x.strip() in locals_ for x in a.split('-')): v = a
            else: v = operand(a, syms, locals_) or a
            out.append('\t%s %s' % ({'db': '.byte', 'dw': '.short', 'dl': '.long'}[op], v))
        return '\n'.join(out)
    if op in ('mul', 'muls', 'div', 'divs') and len(raw) == 2 and raw[0].startswith('X') and NUM.match(raw[1]):
        return '\t%s %s, %d' % (op, raw[0][1:].lower(), num(raw[1]))   # muls XIY,0xa -> muls iy, 10 (dd 09 0a 00):
                                                                        # with an immediate llvm-mc names the 16-bit source
    if op in ('mul', 'muls', 'div', 'divs') and len(raw) == 2 and raw[0] in ('WA', 'BC', 'DE', 'HL') and NUM.match(raw[1]):
        return '\t%s %s, %d' % (op, {'WA': 'a', 'BC': 'c', 'DE': 'e', 'HL': 'l'}[raw[0]], num(raw[1]))
        # muls HL,0x3 is the byte form (L x 3 -> HL; chnarrow.c cn_mul_k): llvm-mc names the 8-bit source (cf 09 03);
        # div DE,0x64 too (DE / 100 -> E, remainder D: the ROM's FormatMedleyNumber, cd 0a 64; div de, 100 was the
        # 32 / 16 form da 0a 64 00)
    # a byte in memory indexed by an upper word, (XWA+QIZ): llvm-mc assembles the register forms (ld a, (xwa+qiz)) but
    # not inc / dec / cp / ld with an immediate, which the hand sources write as the raw forms (b0 0x07 = the
    # 16-bit-index mode, the base's code, the index's code): sprintf_core.s, Sprintf_FormatEScientific (lane_p6)
    qi = [QIDX.match(a) for a in raw]
    if any(qi):
        if op in ('inc', 'dec', 'incb', 'decb', 'incw', 'decw') and len(raw) == 2 and qi[1] and NUM.match(raw[0]):
            return '\t%s_sri%s %d, 0x07, 0x%x, 0x%x' % (op[:3], 'w' if op.endswith('w') else 'b', num(raw[0]),
                                                       XBASE[qi[1].group(1)], Q_WORD[qi[1].group(2)])
        m = re.match(r'^(ld|cp|add|adc|sub|sbc|and|xor|or)([bw]?)$', op)
        if m and len(raw) == 2 and qi[0] and NUM.match(raw[1]):
            return qidx_imm(m.group(1), m.group(2) == 'w', XBASE[qi[0].group(1)], Q_WORD[qi[0].group(2)], num(raw[1]))
    if any(a in ERP_BYTE for a in raw): return erp_byte(op, raw)     # IXL .. QIZH, QA .. QH: before any other rule
    if op == 'ret': return '\tret' if not raw else '\tret %s' % CC[raw[0]]
    if op == 'retd': return '\tretd %d' % num(raw[0])
    if op in ('j', 'cal', 'call', 'jp') and raw and REG32.match(raw[-1]):
        # through a register: a tail call `j XHL` is jp (xhl) = b3 d8 (lane_hd: HDAE5000_HardTest_Print), call XHL is
        # call (xhl) = b3 e8; with a condition, jp / call cc, (xhl)
        cc = '%s, ' % CC[raw[0].lower()] if len(raw) == 2 else ''
        return '\t%s %s(%s)' % ('jp' if op in ('j', 'jp') else 'call', cc, raw[-1].lower())
    if op == 'cal' and len(raw) == 2:                    # CAL cc,F: no relative form, call cc,(F) -- 24-bit, or 16
        t = spelled(raw[1], lookup(raw[1], syms))        # for a __near / __tiny F (hdae5000_ui_display.s: call nz,
        return '\tcall %s, (%s:%d)' % (CC[raw[0]], t, 16 if code_width(raw[1]) < 24 else 24)   # (..._Status:24))
    if op == 'cal':
        if module_local(raw[0]): return '\tcalr %s' % branch_target(raw[0], syms)
        if code_width(raw[0]) < 24: return '\tcall16 %s' % spelled(raw[0], lookup(raw[0], syms))
        return '\tcall %s' % spelled(raw[0], lookup(raw[0], syms))
    if op == 'j':
        if len(raw) == 1:
            if raw[0] in locals_: return '\tjr %s' % raw[0]
            m = re.match(r'^(X\w+)\+(\w+)$', raw[0])
            if m: return '\tjp t, (%s+%s)' % (m.group(1).lower(), m.group(2).lower())
            if module_local(raw[0]): return '\tjr %s' % branch_target(raw[0], syms)   # llvm-mc widens it to jrl
            if code_width(raw[0]) < 24: return '\tjp16 %s' % spelled(raw[0], lookup(raw[0], syms))
            return '\tjp %s' % spelled(raw[0], lookup(raw[0], syms))
        # J cc,F: a local label, or a module-local F as the unconditional J (jr, llvm-mc widens it to jrl; out of
        # 16-bit reach far_fallback makes it jp cc); an extern F as jp cc,(F), 24-bit or (F:16) for a __near / __tiny
        # one (lane_p6: SndParamBank_CheckFlash's `j nz,SndParamBank_WriteFlashDefaults`, the ROM's jr nz)
        if raw[1] in locals_: return '\tjr %s, %s' % (CC[raw[0]], raw[1])
        if module_local(raw[1]): return '\tjr %s, %s' % (CC[raw[0]], branch_target(raw[1], syms))
        t = spelled(raw[1], lookup(raw[1], syms))
        return '\tjp %s, (%s:%d)' % (CC[raw[0]], t, 16 if code_width(raw[1]) < 24 else 24)
    if op == 'djnz': return '\tdjnz %s, %s' % (raw[0].lower(), raw[1])
    # `& 0xfff`: V4.23's listing cuts a long line at its column limit, so a 32-character name's `& 0xffff` loses its
    # last digit (lane_p6: pushw _FDemo_DisplayResourceData_Str_S & 0xfff, after the `>> 16` push of the same name)
    m = re.match(r'^([_.]\w+|S\d+) (>> 16|& 0xffff?)$', ' '.join(raw)) if op == 'pushw' else None
    if m:                                                # an address pushed as two words (abi returns.c use_d,
        s = spell_of(m.group(1)) if not m.group(1).startswith('S') else None
        if s:                                            # a label: the assembler supplies the halves (UPDATE 20)
            return '\tpushw %s@%s' % (s, 'hi16' if m.group(2) == '>> 16' else 'lo16')
        a = syms[m.group(1)] if m.group(1) in syms else lookup(m.group(1), syms)   # _sprintf: pushw __strOut >> 16)
        no_placeholder(m.group(1), a)
        return '\tpushw 0x%x' % ((a >> 16) & 0xffff if m.group(2) == '>> 16' else a & 0xffff)
    if op == 'call' and len(raw) == 1 and re.match(r'^X(WA|BC|DE|HL|IX|IY|IZ)$', raw[0]):
        return '\tcall (%s)' % raw[0].lower()                    # an indirect call: call XWA (abi fptr.c fp_call)
    if op in ('jr', 'jrl'):                                # inline assembly writes jr / jrl itself (_MEMSET.C)
        t = raw[-1]                                        # a module-local function keeps V4.23's `.` name
        if t not in locals_ and module_local(t):           # (lane_sub: jr cc,.Voice_Reprioritise): the tree's name
            t = branch_target(t, syms)
        return '\t%s %s' % (op, t) if len(raw) == 1 else '\t%s %s, %s' % (op, CC[raw[0].lower()], t)
    if op in ('sll', 'srl', 'sla', 'sra', 'rlc', 'rrc', 'rl', 'rr') and len(raw) == 2 and NUM.match(raw[0]):
        return '\t%s %s, %d' % (op, raw[1].lower(), num(raw[0]) or 16)   # Toshiba: count first (srl 2,BC); V4.23
        # writes a shift by 16 as the raw count field 0, which llvm-mc refuses (lane_sub: DSP_UnpackParam3B)
    if op in ('sla', 'sll', 'sra', 'srl') and len(raw) == 2 and raw[0] == 'A' and REGS.match(raw[1]):
        return '\t%sa %s' % ({'sla': 'sla', 'sll': 'sll', 'sra': 'sra', 'srl': 'srl'}[op], raw[1].lower())
        # a count in A: llvm-mc's slaa / slla / sraa / srla r (d8+r fc..ff; firmware FileIO_*: slla bc = d9 fe)
    if op in ('cpir', 'cpirw', 'cpdr', 'cpdrw', 'cpi', 'cpiw', 'cpd', 'cpdw') and len(raw) == 2:
        m = re.match(r'^\((X(WA|BC|DE|HL|IX|IY|IZ|SP))[+-]\)$', raw[1])
        if m:                                              # llvm-mc knows only the operand-less form: the bytes
            r = ['XWA', 'XBC', 'XDE', 'XHL', 'XIX', 'XIY', 'XIZ', 'XSP'].index(m.group(1))
            sub = {'cpi': 0x14, 'cpir': 0x15, 'cpd': 0x16, 'cpdr': 0x17}[op.rstrip('w')]
            return '\t.byte 0x%02x, 0x%02x\t; %s' % ((0x90 if op.endswith('w') else 0x80) + r, sub, t.strip())
    bop = {'ldib': 'ldi', 'ldirb': 'ldir', 'lddb': 'ldd', 'lddrb': 'lddr'}.get(op, op)
    if bop in ('ldir', 'ldirw', 'ldi', 'ldiw', 'lddr', 'lddrw', 'ldd', 'lddw'):
        # block transfers as their bytes: 0x80 (byte) / 0x90 (word) + 3 for (XDE+),(XHL+) or 5 for (XIX+),(XIY+), then
        # 0x10 ldi, 0x11 ldir, 0x12 ldd, 0x13 lddr (_memcpy: ldib (XIX+),(XIY+) = 85 10; llvm-mc's bare ldi is 80 10)
        r = 5 if raw[:1] in (['(XIX+)'], ['(XIX-)']) else 3 if raw[:1] in (['(XDE+)'], ['(XDE-)']) else 5 if not raw else None
        if r is not None:
            sub = {'ldi': 0x10, 'ldir': 0x11, 'ldd': 0x12, 'lddr': 0x13}[bop.rstrip('w') if bop not in ('ldd',) else 'ldd']
            word = bop.endswith('w') and bop not in ('ldd',)
            return '\t.byte 0x%02x, 0x%02x\t; %s' % ((0x90 if word else 0x80) + r, sub, t.strip())
    if op == 'scc': return '\tscc %s, %s' % (CC[raw[0]], raw[1].lower())
    if op in ('push', 'pop') and raw[0] in ('WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ'):
        return '\t%sw %s' % (op, raw[0].lower())                      # the 1-byte 16-bit forms
    if op == 'lda':
        dst = raw[0].lower(); src = raw[1]
        m = re.match(r'^(X\w+)\+:(\d)$', src)
        if m: return '\tlda %s, (%s+:%s)' % (dst, m.group(1).lower(), m.group(2))
        m = re.match(r'^(X\w+)([+-])(0x[0-9a-fA-F]+|\d+)$', src)
        if m: return '\tlda %s, (%s%s%d)' % (dst, m.group(1).lower(), m.group(2), num(m.group(3)))
        m = re.match(r'^(X\w+)\+(\w+)$', src)
        if m: return '\tlda %s, (%s+%s)' % (dst, m.group(1).lower(), m.group(2).lower())
        # lda of a symbol takes the 24-bit address whatever its value (sub CPU _exp: lda XBC,_g_mathtbl at 0xf420 is
        # f2 20 f4 00 31, not the 16-bit form)
        m = re.match(r'^([_.]\w+) \+ (0x[0-9a-fA-F]+|\d+)$', src)
        if m: return '\tlda %s, (%s:%d)' % (dst, spelled(m.group(1), lookup(m.group(1), syms), num(m.group(2))),
                                            24 if WIDTHS is None else sym_width(m.group(1)))   # _cos: _g_dbltbl + 0x10
        if src.startswith(('_', '.')): return '\tlda %s, (%s:%d)' % (dst, spelled(src, lookup(src, syms)),
                                                                     24 if WIDTHS is None else sym_width(src))
        if src in CONSTS and src in DATA: return '\tlda %s, (%s:24)' % (dst, DATA[src])   # f_const data in the tree
        if src in CONSTS and DATA_REQUIRED:
            raise KeyError('V4.23 constant data %s (a jump table / constant) has no place in the tree: name it with a '
                           '`cc900-data: FUNCTION N = LABEL` comment' % src)
        if src in syms: return '\tlda %s, (0x%x:24)' % (dst, syms[src])      # an FP constant placed by the linker
        if re.match(r'^X(WA|BC|DE|HL|IX|IY|IZ|SP)$', src): return '\tlda %s, (%s)' % (dst, src.lower())   # lda XWA,XSP
        if src in locals_: return '\tlda %s, (%s:24)' % (dst, src)
        if NUM.match(src): return '\tlda %s, %s' % (dst, absaddr(num(src)))
        return '\t; untranslated: ' + t.strip()
    base, sz = size_suffix(op)
    args = [operand(a, syms, locals_) for a in raw]
    if any(a is None for a in args): return '\t; untranslated: ' + t.strip()
    if base in ('inc', 'dec') and len(args) == 2:
        return '\t%s%s %d, %s' % (base, 'w' if sz == 'w' else '', num(args[0]) or 8, args[1])  # count field 0 = 8
    if base == 'ld' and len(args) == 2 and raw[0] in R8 and NUM.match(raw[1]):
        return '\tld %s, 0x%x:opc' % (args[0], num(raw[1]) & 0xff)            # String_Compare: ld l, 0x0:opc
    if base in ('ld', 'cp') and len(args) == 2 and REGS.match(raw[0]) and re.match(r'^(0x[0-7]|[0-7])$', raw[1]) \
            and (raw[0] not in R8 or base == 'cp') and not (base == 'cp' and raw[0].startswith('X')):
        # ld hl, 0:i3 / cp bc, 0:i3; a 32-bit cp takes the long immediate (firmware _ltoa: cp XDE,0x0 is
        # ea cf 00 00 00 00, not ea d8)
        if raw[0].startswith('Q'): return '\t%s %s, %d' % (base, args[0], num(raw[1]))   # cp QBC,0 -> d7 e6 d8
        return '\t%s %s, %d:i3' % (base, args[0], num(raw[1]))
    if base in ('and', 'or', 'add') and len(args) == 2 and raw[0] in Q_WORD and NUM.match(raw[1]):
        n = num(raw[1]) & 0xffff                         # and QWA,n = d7 e2 cc lo hi (lane_sub's sub_v423.py)
        return '\t%s_erpw 0x%x, 0x%x, 0x%x' % (base, Q_WORD[raw[0]], n & 0xff, n >> 8)
    if base in ('ld', 'cp') and len(args) == 2 and re.match(r'^Q(WA|BC|DE|HL|IX|IY|IZ|SP)$', raw[0]) \
            and NUM.match(raw[1]):                     # a word of the upper halves beyond 0..7: the long immediate,
        return '\t%sw %s, 0x%x' % (base, args[0], num(raw[1]) & 0xffff)   # cp QIZ,0x8 = d7 fa cf 08 00 (FDC_*)
    if base == 'ld' and len(args) == 2 and raw[0] in ('WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ', 'SP') and NUM.match(raw[1]):
        return '\tldw %s, 0x%x' % (args[0], num(raw[1]) & 0xffff)            # _strlen: ld HL,0xffff -> 33 ff ff
    if sz == 'w' and base in ('ld', 'cp', 'add', 'sub', 'and', 'or', 'xor'):
        return '\t%sw %s' % (base, ', '.join(args))
    return '\t%s %s' % (base, ', '.join(args)) if args else '\t' + base

CONSTS = {}
# DATA (phase 6 build): {V4.23 f_const label (S50003): the tree's label for that object}.  V4.23 puts a function's
# constant data -- a switch's jump table (`dw L35-L50002`), an FP constant (`fdatad`), an initialised local array --
# in the f_const section, which the linker places apart from the code: the tree has it at its own label.  A code
# reference to such a label (`lda XIX,S50003`) becomes that tree label; one without an entry stops the translation.
DATA = {}
DATA_REQUIRED = False      # the firmware build: an f_const reference without a DATA entry is an error

def split_consts(lines):
    """a function's f_const blocks: {label: [its lines: align, dw / db / dl, fdata / fdatad]} in listing order, and
    the lines without them"""
    consts = {}; out = []; inconst = False; lab = None
    for l in lines:
        if l.startswith('f_const'): inconst = True; continue
        if l.startswith('f_code'): inconst = False; continue
        if inconst:
            if l.endswith(':') and not l.startswith('\t'): lab = l[:-1]; consts[lab] = []
            elif lab is not None: consts[lab].append(l)
            else: consts.setdefault(None, []).append(l)       # an `align` before the first label
            continue
        out.append(l)
    if None in consts:                                         # it belongs to the first object
        pre = consts.pop(None)
        if consts: consts[next(iter(consts))][:0] = pre
    return consts, out

def fp_consts(consts):
    """split_consts' objects -> {label: (directive, value text)} of the FP constants only (fdata / fdatad, the last
    one of an object), the form pairs_model.py checks against the image (split_consts' result before cc900-data)"""
    out = {}
    for lab, ls in consts.items():
        for l in ls:
            if l.startswith('\tfdata'):
                out[lab] = tuple(l.strip().split('\t'))
    return out

def translate_data(lines, locals_):
    """an f_const object's lines -> llvm-mc data lines (names of the function's local labels kept as they are)"""
    import struct
    out = []
    for l in lines:
        p = l.strip().split(None, 1); op = p[0].lower()
        if op == 'align':
            # V4.23 aligns within its own f_const section, which the firmware's linker placed where it liked: the
            # sub-CPU's AudioChannel_CaseOffsets sits at the odd 0xF703.  The tree's label is the object's place, so
            # no padding is written here (a .balign would shift the table and everything after it by a byte)
            out.append('\t; V4.23: align %s (within its f_const section; the label places the object)' % p[1]); continue
        if op in ('fdata', 'fdatas', 'fdatad'):          # fdatas 1.0...e+002F: single precision, the value with an F
            b = struct.pack('<d' if op == 'fdatad' else '<f', float(p[1].strip().rstrip('FfDdLl')))
            out.append('\t.byte ' + ', '.join('0x%02x' % x for x in b) + '\t; %s %s' % (op, p[1].strip())); continue
        out.append(translate_line(l, {}, locals_))
    return out

def translate_function(name, lines, syms):
    consts, lines = split_consts(lines)
    CONSTS.clear(); CONSTS.update(consts)
    locals_ = {l[:-1] for l in lines if l.endswith(':') and not l.startswith('\t')}
    out = []
    for l in lines:
        if 'section' in l: continue
        if l.endswith(':') and not l.startswith('\t') and l[:-1] == name:
            bare = name.lstrip('_.')
            out += ['\t.globl %s' % bare, bare + ':']; continue
        out.append(translate_line(l, syms, locals_))
    return out

def relax(text, assemble):
    """asm900's j: jr when the target is in reach, else jrl.  `assemble(text)` returns llvm-mc's stderr; each line
    it reports out of range becomes jrl, until none is."""
    lines = text.split('\n')
    for _ in range(20):
        err = assemble('\n'.join(lines))
        bad = sorted({int(m.group(1)) for m in re.finditer(r':(\d+):\d+: error: [^\n]*(out of range|too far|range)', err)})
        if not bad: return '\n'.join(lines)
        changed = False
        for n in bad:
            l = lines[n - 1]
            if '\tjr ' in l: lines[n - 1] = l.replace('\tjr ', '\tjrl '); changed = True
            elif '\tjr\t' in l: lines[n - 1] = l.replace('\tjr\t', '\tjrl\t'); changed = True
        if not changed: return '\n'.join(lines)
    return '\n'.join(lines)

def main():
    import frontend, codegen
    a = sys.argv[1:]
    src, symf = a[0], a[1]
    opt = a[a.index('--opt') + 1] if '--opt' in a else 'O3XS'
    pers = a[a.index('--personality') + 1] if '--personality' in a else 'kn5000'
    only = a[a.index('--only') + 1].split(',') if '--only' in a else None
    defines = [x[2:] for x in a if x.startswith('-D')]; incs = [x[2:] for x in a if x.startswith('-I')]
    syms = load_symbols(symf)
    unit = frontend.load(src, defines, incs, adecl='--adecl' in a)
    out = codegen.compile_unit(unit, opt=opt, adecl='--adecl' in a, personality=pers)
    print('\t.text')
    for name, lines in out.items():
        if only and name.lstrip('_.') not in only: continue
        if not lines or not lines[0].endswith(':') or lines[0][:-1] != name: continue   # data objects, unsupported
        print('\n'.join(translate_function(name, lines, syms)))

if __name__ == '__main__':
    main()
