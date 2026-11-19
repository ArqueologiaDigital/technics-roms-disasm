#!/usr/bin/env python3
"""Which translated lines of a V4.23 listing's function does llvm-mc refuse?

QUESTION ANSWERED: sub_v423.py reports "llvm-mc cannot assemble the translation" or "to_llvm cannot translate a line"
for a function; this prints, for that function, the SHAPE of each offending line (mnemonic and operands with numbers
replaced by N / H), so that the checker can learn the form.  It prints no Toshiba text beyond that shape.

usage: python3 -B notes/cc900-c-subcpu-2026-11-16/bad_lines.py LISTING.asm FUNCTION [--cfile C]   (repository root)
"""
import os, re, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import sub_v423 as S                                          # noqa: E402  (sets up the model / build imports)
import check_bytes, to_llvm, listing                          # noqa: E402
import cc900_firmware_c as fw                                 # noqa: E402


def shape(l):
    return re.sub(r'\b\d+\b', 'N', re.sub(r'0x[0-9a-fA-F]+', 'H', l.strip()))


def main():
    a = sys.argv[1:]
    if len(a) < 2:
        sys.exit(__doc__)
    ref = check_bytes.load_reference(os.path.join(S.REPO, 'symbols', 'subcpu_symbols_reference.txt'))
    names = fw.Names(fw.tree_values(os.path.join(S.REPO, 'v142', 'subcpu')), ref)
    to_llvm.SPELL = None
    text = open(a[0], encoding='latin-1').read()
    to_llvm.WIDTHS = listing.attributes(text)
    for n, lines in listing.split(text).items():
        if n.lstrip('._') != a[1]:
            continue
        try:
            body = to_llvm.translate_function(n, lines, names)
        except KeyError as e:
            print('cannot resolve', e); return 1
        for l in body:
            l = S.erp_word(S.erp_byte(l.replace('$+', '.+')))
            if l.endswith(':') or '.globl' in l:
                continue
            if 'untranslated' in l:
                # to_llvm writes `untranslated: ...` and `untranslated (a byte register llvm-mc cannot name): ...`;
                # split on the word, not on `untranslated:` (helper AP, 2026-11-19: the second form crashed here)
                print('untranslated:', shape(l.split('untranslated', 1)[1])); continue
            try:
                check_bytes.assemble('\t.text\nX:\n%s\n' % l)
            except subprocess.CalledProcessError:
                print('refused:', shape(l))
    return 0


if __name__ == '__main__':
    sys.exit(main())
