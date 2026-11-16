#!/usr/bin/env python3
"""Write the C declarations of the main CPU's workspace and its two function tables, as the HD-AE5000 reaches them.

QUESTION ANSWERED / WHY: the HD-AE5000 calls the main CPU through `ws->tab[0x100].fns->F` (offsets RootFn_*) and
`ws->tab[0x109].fns->F` (HamaFn_*), where ws = HDAE5000_RAM_MainWorkspacePtr.  Run 2026-11-16-44-hd-r1 showed that
V4.23 at -Xr reproduces the ROM's single `ld xhl,(xwa+d16)` only for a struct MEMBER; indexing an array of function
pointers gives `lda` then `ld`.  So each table is a struct whose members sit at the offsets the tree's `.equ
RootFn_*` / `.equ HamaFn_*` give (hdae5000/hd-ae5000_v2_06i.s), padded between.  The object-table entry is 14
bytes with the function table first, and the workspace's entries start at +10 (WS_RootFnTable = 0x0e0a =
10 + 14 * 0x100, WS_HamaFnTable = 0x0e88 = 10 + 14 * 0x109).  Run 2026-11-16-48-hd-r2b: even a member gives
`lda` then `ld` when it is called directly; the ROM's single load needs the member read as a value, through a cast
to the function type (UiObj_SetCaption matched that way).  So the members are `void *` and every call casts them:
CALLV(ROOT->F)(args), CALLR(type, ROOT->F)(args).

    python3 -B notes/cc900-c-hdae5000-2026-11-16/gen_ws_header.py > OUT.h
"""
import os, re

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
SRC = os.path.join(REPO, 'hdae5000', 'hd-ae5000_v2_06i.s')
EQU = re.compile(r'^\s*\.equ\s+(RootFn|HamaFn)_(\w+),\s*(0x[0-9a-fA-F]+)')


def struct(tag, fields):
    out = ['struct %s {' % tag]
    at, pad = 0, 0
    for off, name in sorted(fields):
        if off > at:
            out.append('    void *pad%d[%d];' % (pad, (off - at) // 4))
            pad += 1
        out.append('    void *%s;' % name.lstrip('_'))
        at = off + 4
    out.append('};')
    return out


def main():
    t = {'RootFn': [], 'HamaFn': []}
    for l in open(SRC, encoding='latin-1'):
        m = EQU.match(l)
        if m:
            t[m.group(1)].append((int(m.group(3), 16), m.group(2)))
    print('/* the main CPU workspace and its function tables (gen_ws_header.py, from the RootFn_* / HamaFn_* .equ) */')
    print('typedef void (*VFN)();')
    print('\n'.join(struct('RootFns', t['RootFn'])))
    print('\n'.join(struct('HamaFns', t['HamaFn'])))
    print('struct ObjTab { void *fns; char rest[10]; };')
    print('struct NakaWs { char hdr[10]; struct ObjTab tab[0x10a]; };')
    print('extern struct NakaWs *HDAE5000_RAM_MainWorkspacePtr;')
    print('#define ROOT ((struct RootFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x100].fns)')
    print('#define HAMA ((struct HamaFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x109].fns)')
    print('/* every call goes through a cast: CALLR(int, ROOT->GetTitleNow)(), CALLV(ROOT->SendEvent)(obj, ev, arg) */')
    print('#define CALLR(t, f) ((t (*)())(f))')
    print('#define CALLV(f) ((void (*)())(f))')


if __name__ == '__main__':
    main()
