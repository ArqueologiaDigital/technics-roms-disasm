#!/usr/bin/env python3
"""Host routines that call one XAPR plug-in header slot (lane open14/sibling-names3).

Question it answers: which routine of a host image (KN6000, KN6500) loads the plug-in's header word
+0x20 .. +0x54 (`mov (0x978000XX), aN` / `calls (aN)`), and what does the plug-in call that slot?
The slot names are the HD-SX3 plug-in's own header (../../../hdsx3/README.md, "the header";
hdsx3/src/program.s's first table).  A routine that loads exactly one slot and is still func_<ADDR>
gets the row `XaprCall<slot name without XaprExt>`.

    python3 -I kn7000/notes/sibling-names3-probes/xapr_slot_callers.py kn6500 [--rows]
"""
import re, sys
sys.path.insert(0, __file__.rsplit('/', 1)[0])
import routine_graph as g

SLOTS = {}
lines = open('hdsx3/src/program.s', 'rb').read().split(b'\n')
k = 0
for ln in lines:
    m = re.match(rb'\t\.long\t(\w+)', ln)
    if m and k < 32:
        SLOTS[4 + 4 * k] = m.group(1).decode()  # the word after "XAPR" is +4
        k += 1
    elif k:
        if not m:
            break


def main():
    model = sys.argv[1]
    rows = '--rows' in sys.argv
    rs = g.parse(model)
    for r, body in rs.items():
        offs = {int(m.group(1), 16) for i in body for m in [re.search(r'\(0x978000([0-9a-f]{2})\)', i)] if m}
        if len(offs) != 1:
            continue
        off = offs.pop()
        slot = SLOTS.get(off, '?')
        if rows:
            if g.PLACE.match(r) and slot.startswith('XaprExt'):
                nm = 'XaprCall' + slot[len('XaprExt'):]
                print(f'0x{r[5:]}  {nm:<24}; table: calls the XAPR header slot +0x{off:02X} (`mov (0x978000{off:02x}), aN / calls (aN)`) when XaprBoardPresent: the plug-in\'s {slot}')
        else:
            print(f'{r:28} +0x{off:02X} {slot}')


if __name__ == '__main__':
    main()
