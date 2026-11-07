#!/usr/bin/env python3
"""Check the hand-name rows of a sibling's <model>_manual.sym (lane open14/sibling-names3).

Question it answers: does every hand row this lane added name a routine start that is still a
func_<ADDR> placeholder in the committed source (or already carries this very name after a
regeneration), is every name unique across all of the model's symbol files, labels and data
labels, and does every row cite an evidence class?

    python3 -I kn7000/notes/sibling-names3-probes/hand_names_check.py kn6000 [kn6500 kn2400 ...]

Rows are read from the block between the markers
  `; ---- lane open14/sibling-names3` and the end of the file.  The evidence classes are the
README's: string, gui, io, callee, caller, ram, body, libc, same-body, table (routines), data and var
(a data or RAM address, not a routine); a row says `<class>:` first.
"""
import re, sys

CLASSES = ('string', 'gui', 'io', 'callee', 'caller', 'ram', 'body', 'libc', 'same-body', 'table', 'data', 'var')


def names_of(model):
    out = {}
    files = [f'{model}/{model}.sym', f'{model}/{model}_ported.sym', f'{model}/{model}_aligned.sym',
             f'{model}/{model}_ram.sym', f'{model}/src/program/data/functions.sym']
    for f in files:
        try:
            for ln in open(f, encoding='latin-1'):
                m = re.match(r'\s*(0x[0-9A-Fa-f]+)\s+(\S+)', ln)
                if m:
                    out.setdefault(m.group(2), set()).add((f, int(m.group(1), 16)))
        except FileNotFoundError:
            pass
    for f in (f'{model}/src/labels.inc', f'{model}/src/program/data/labels.sym'):
        try:
            for ln in open(f, encoding='latin-1'):
                m = re.match(r'\s*\.equ\s+(\S+),\s*(0x[0-9a-fA-F]+)', ln) or re.match(r'\s*(0x[0-9A-Fa-f]+)\s+(\S+)', ln)
                if m:
                    a, b = m.groups()
                    if a.startswith('0x'):
                        a, b = b, a
                    out.setdefault(a, set()).add((f, int(b, 16)))
        except FileNotFoundError:
            pass
    return out


def main():
    bad = 0
    for model in sys.argv[1:]:
        txt = open(f'{model}/{model}_manual.sym', encoding='latin-1').read()
        before, _, block = txt.partition('; ---- lane open14/sibling-names3')
        other = {}
        for ln in before.splitlines():
            m = re.match(r'\s*(0x[0-9A-Fa-f]+)\s+(\S+)', ln)
            if m:
                other.setdefault(m.group(2), set()).add(('manual', int(m.group(1), 16)))
        taken = names_of(model)
        seen = {}
        rows = 0
        for ln in block.splitlines():
            m = re.match(r'\s*(0x[0-9A-Fa-f]+)\s+(\S+)\s*(;.*)?$', ln)
            if not m:
                continue
            rows += 1
            a, nm, note = int(m.group(1), 16), m.group(2), (m.group(3) or '')
            cls = re.match(r';\s*([a-z-]+):', note)
            if not cls or cls.group(1) not in CLASSES:
                print(f'{model}: 0x{a:08X} {nm}: no evidence class'); bad += 1
            if nm in seen:
                print(f'{model}: {nm} twice (0x{seen[nm]:08X}, 0x{a:08X})'); bad += 1
            seen[nm] = a
            for src in (other, taken):
                for f, b in src.get(nm, ()):
                    if b != a and not re.search(r'_ram\.sym$', f):
                        print(f'{model}: {nm} at 0x{a:08X} is also {f} 0x{b:08X}'); bad += 1
            ph = f'func_{a:08X}'
            if ph not in taken and nm not in taken and cls and cls.group(1) not in ('data', 'var') and (a >> 24) not in (0x50, 0x90, 0x84):
                print(f'{model}: 0x{a:08X} {nm}: neither {ph} nor the name is a label of the source'); bad += 1
        print(f'{model}: {rows} hand rows of this lane checked')
    print('PASS' if bad == 0 else f'FAIL {bad}')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
