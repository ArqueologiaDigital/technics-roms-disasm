"""kn7000_manual.sym names some library functions at their register-save `call`
entry instead of at the movm prologue LIB_CONVERT starts them at. For each name
whose LIB_CONVERT start S is a `movm [..], (sp)` and whose manual address E is
the instruction after the movm + `add -N, sp` prologue, move the plain name to S
and name E `<name>_entry` (the file's two-entry convention). Run from kn7000/."""
import re, sys
sys.path.insert(0, 'tools')
import gen_program_s as G

rom = open(G.ROM, 'rb').read()
lines = open('kn7000_manual.sym', 'rb').read().split(b'\n')
have = set()
for l in lines:
    m = re.match(rb'0x([0-9A-Fa-f]+)\s+(\S+)', l)
    if m and not l.lstrip().startswith(b';'):
        have.add(m.group(2).decode())
out, fixed = [], 0
for l in lines:
    m = re.match(rb'0x([0-9A-Fa-f]{8})(\s+)(\S+)(.*)$', l)
    if m and not l.lstrip().startswith(b';'):
        e, nm = int(m.group(1), 16), m.group(3).decode()
        if nm in G.LIB_CONVERT and G.LIB_CONVERT[nm][0] != e:
            s = G.LIB_CONVERT[nm][0]
            fo = s - G.LIB_DELTA
            ok = rom[fo] == 0xCF                       # movm [..], (sp)
            p = fo + 2
            if rom[p] == 0xF8 and rom[p + 1] == 0xFE:   # add imm8, sp
                p += 3
            elif rom[p] == 0xFA and rom[p + 1] == 0xFE: # add imm16, sp
                p += 4
            ok = ok and p + G.LIB_DELTA == e and nm + '_entry' not in have
            if not ok:
                print(f'SKIP {nm}: LIB_CONVERT {s:#x}, manual {e:#x}')
                out.append(l)
                continue
            out.append(b'0x%08X' % s + m.group(2) + m.group(3) + m.group(4))
            out.append(b'0x%08X  %s_entry' % (e, nm.encode()))
            fixed += 1
            continue
    out.append(l)
open('kn7000_manual.sym', 'wb').write(b'\n'.join(out))
print('fixed', fixed)
