#!/usr/bin/env python3
"""QUESTION ANSWERED: do nearmiss.py's small helpers added on 2026-11-18 do what their docstrings say?  No VM, no
listing: made-up inputs only.  Exit 1 on a failure.
  - pair_rows: old rows without listing_name (a first variant, two ERR-dup variants, an ERR-name row) pair with the
    re-checked rows by order and by name;
  - untranslated_shapes: a `cannot translate` stop keeps only the mnemonic, register names, `sym` and `N`;
  - tool_error: llvm-mc's errors become their messages plus the refused line's mnemonic only.

usage: python3 -B notes/cc900-c-nearmiss/probes/selftest.py"""
import os
import subprocess
import sys
import tempfile

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'analysis', 'cc900'))
import nearmiss  # noqa: E402

FAIL = []


def check(what, got, want):
    print('%-4s %s: %r' % ('ok' if got == want else 'FAIL', what, got))
    if got != want:
        FAIL.append(what)


def main():
    old = [dict(listing='L', function='F', status='MATCH'), dict(listing='L', function='F', status='ERR-dup'),
           dict(listing='L', function='F', status='ERR-dup'), dict(listing='L', function='g_short', status='ERR-name'),
           dict(listing='L2', function='F', status='NEAR', listing_name='F')]
    res = [dict(listing='L', function='F', listing_name='F', status='MATCH'),
           dict(listing='L', function='F', listing_name='F_a', status='NEAR'),
           dict(listing='L', function='F', listing_name='F_b', status='MATCH'),
           dict(listing='L', function='G_Long', listing_name='g_short', status='DIFF'),
           dict(listing='L2', function='F', listing_name='F', status='MATCH')]
    p = nearmiss.pair_rows(old, res)
    check('pair_rows', [p[id(r)]['listing_name'] + '/' + p[id(r)]['listing'] for r in old],
          ['F/L', 'F_a/L', 'F_b/L', 'g_short/L', 'F/L2'])

    check('untranslated_shapes', nearmiss.untranslated_shapes(
        'x.c: F: to_llvm cannot translate:\n\t; untranslated (a byte register llvm-mc cannot name): cp A,QE\n'
        '\t; untranslated (a byte register llvm-mc cannot name): cp C,QE\n\t; untranslated: ld XIX,_ram_23e0 + 0x4c'),
        'to_llvm cannot translate: a byte register llvm-mc cannot name: cp A,QE, cp C,QE; ld XIX,sym + N')
    check('untranslated_shapes data', nearmiss.untranslated_shapes(
        'x.c: F: to_llvm cannot translate the data of Tab:\n\t; untranslated: dw _Foo_Bar - S12, 3'),
        'to_llvm cannot translate data: dw sym - sym, N')

    src = '\t.text\nf:\n\tld\txwa, 1\n\tldxx\twa, 3\n\tld\ta, (xwa+qiz+3)\n'
    with tempfile.TemporaryDirectory() as d:
        s = os.path.join(d, 'bad.s')
        open(s, 'w').write(src)
        r = subprocess.run([os.path.join(nearmiss.LLVM_BIN, 'llvm-mc'), '-triple=tlcs900', '-filetype=obj', s,
                            '-o', os.devnull], capture_output=True, text=True)
    check('tool_error', nearmiss.tool_error(r.stderr, src.split('\n')),
          "unrecognized instruction mnemonic (ldxx); expected ')' after a register-indexed operand (ld)")
    return 1 if FAIL else 0


if __name__ == '__main__':
    sys.exit(main())
