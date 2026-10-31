#!/usr/bin/env python3
"""Apply the 2026-10-31 HD-AE5000 FLS / RCM / PC-link names to the four HD-AE5000 trees.

What it does (evidence in notes/open4-kn5000-b/hdae/README.md, "kn5000-44c" and "kn5000-e7f"):
  * FLS item bytes +80 / +112 are the AS (AUTO START) / AL (AUTO LOAD) options of the owner's
    manual: HDAE5000_FlsItem_SetByte80/112 -> HDAE5000_FlsItem_SetAutoStart/SetAutoLoad.
  * HDAE5000_Get_Status_Byte / Set_Status_Byte read the FLS auto-load-pending flag and set the
    "sequencer stopped while away from the FLS page" flag: renamed, and the four FLS-chain RAM
    bytes get .equ names (v2.x 0x22AD96.., v1.x 0x22AD4E..; each tree's own addresses).
  * HDAE5000_RAM_HdStreamBufferEnd is only ever used as the RCM stream context (u16 state, dir,
    song, result; HDAE5000_RcmStream_InitialState is ldirw'd over it): HDAE5000_RAM_RcmStreamState.
  * PC-link services 29 / 30 call RootFn_SleepMainTask / RootFn_WakeUpMainTask (v2.x only).
Files are read and written as bytes (they hold non-UTF-8 .ascii).  Idempotent.

Usage: python3 notes/open4-kn5000-b/hdae/probes/apply_hdae_fls_names.py   (from the repo root)
"""
import pathlib
import re

TREES = {
    'hdae5000': ('hd-ae5000_v2_06i.s', 0x22ad96),
    'hdae5000_v2_01i': ('hd-ae5000_v2_01i.s', 0x22ad96),
    'hdae5000_v1_15i': ('hd-ae5000_v1_15i.s', 0x22ad4e),
    'hdae5000_v1_10i': ('hd-ae5000_v1_10i.s', 0x22ad4e),
}
RENAMES = [
    (b'HDAE5000_FlsItem_SetByte80', b'HDAE5000_FlsItem_SetAutoStart'),
    (b'HDAE5000_FlsItem_SetByte112', b'HDAE5000_FlsItem_SetAutoLoad'),
    (b'HDAE5000_Get_Status_Byte', b'HDAE5000_Fls_GetAutoLoadPending'),
    (b'HDAE5000_Set_Status_Byte', b'HDAE5000_Fls_SetSeqStopPending'),
    (b'HDAE5000_RAM_HdStreamBufferEnd', b'HDAE5000_RAM_RcmStreamState'),
    (b'HdStreamBufferEnd', b'RcmStreamState'),
    (b'HDAE5000_PPORT_Svc29_MainHook0538', b'HDAE5000_PPORT_Svc29_SleepMainTask'),
    (b'HDAE5000_PPORT_Svc30_MainHook053C', b'HDAE5000_PPORT_Svc30_WakeUpMainTask'),
]
VARS = [(0, b'HDAE5000_RAM_FlsChainFls'), (2, b'HDAE5000_RAM_FlsChainItem'),
        (4, b'HDAE5000_RAM_FlsAutoLoadPending'), (5, b'HDAE5000_RAM_FlsSeqStopPending')]
EQU_TEXT = {
    b'HDAE5000_RAM_FlsChainFls': b'word: FLS of the item loaded last whose AL (AUTO LOAD) option is on; HDAE5000_FlsLoadScreen loads the next item from here',
    b'HDAE5000_RAM_FlsChainItem': b'word: that item (0-31); the next load takes item + 1, then item 0 of the next FLS',
    b'HDAE5000_RAM_FlsAutoLoadPending': b'1 while an AL chain is pending (the item just loaded had AL set); HDAE5000_Fls_GetAutoLoadPending returns it',
    b'HDAE5000_RAM_FlsSeqStopPending': b'1 when the sequencer stopped (sqsrtc bit 2 fell) during an AL chain while another title was shown; on return to the HD title HDAE5000_Boot_Init posts EVT_HDAE_SEQ_STOP to the FLS page',
}
HEADERS = [
    (rb'; Item BC of FLS record WA, when set: its byte at \+80 = E \(its meaning is not\n; established\)\.\n',
     b'; Item BC of FLS record WA, when set: its AS (AUTO START) option byte at +80 =\n'
     b'; E (0/1).  HDAE5000_FlsLoadScreen starts the sequencer after loading an item\n'
     b'; whose AS byte is 1 (HamaFn_SwbtWr panel code 0x48 bit 5); the FLS lists\n'
     b'; mark it with "*" (owner\'s manual: "AUTO START (AS)").\n'),
    (rb'; Item BC of FLS record WA, when set: its byte at \+112 = E \(its meaning is not\n; established\)\.\n',
     b'; Item BC of FLS record WA, when set: its AL (AUTO LOAD) option byte at +112 =\n'
     b'; E (0/1).  Loading an item whose AL byte is 1 arms the chain\n'
     b'; (HDAE5000_RAM_FlsAutoLoadPending): when the sequencer stops, the next item\n'
     b'; is loaded (owner\'s manual: "AUTO LOAD (AL)").\n'),
    (rb'\{u16 dir; u16 song; u8 byte80; u8\n; byte112\}', b'{u16 dir; u16 song; u8 AS; u8\n; AL}'),
    (rb'\+48 \(song \+ 1\), \+80, \+112\.', b'+48 (song + 1), +80 (AS), +112 (AL).'),
    (rb'; L = the byte at RAM 0x22AD9A \(its role is not established\)\.\n',
     b'; L = HDAE5000_RAM_FlsAutoLoadPending: 1 while an FLS AUTO LOAD chain waits\n'
     b'; for the sequencer to stop (HDAE5000_Frame_Handler_Status).\n'),
    (rb'; Store A at RAM 0x22AD9B \(its role is not established\)\.\n',
     b'; HDAE5000_RAM_FlsSeqStopPending = A: the sequencer stopped during an FLS\n'
     b'; AUTO LOAD chain while another title was shown (HDAE5000_Frame_Handler_Status).\n'),
]


def tok(addr):
    return re.compile(rb'\b0x%s\b' % (b'%06x' % addr), re.I)


root = pathlib.Path('.')
for tree, (main, base) in TREES.items():
    for p in sorted((root / tree).glob('*.s')):
        b = p.read_bytes()
        o = b
        for old, new in RENAMES:
            b = b.replace(old, new)
        for off, name in VARS:
            b = tok(base + off).sub(name, b)
        for pat, rep in HEADERS:
            b = re.sub(pat, rep, b)
        if p.name == main:
            if b'HDAE5000_RAM_FlsChainFls,' not in b:
                anchor = re.search(rb'\n(\t\.equ HDAE5000_RAM_RcmStreamState, [^\n]*)\n', b)
                lines = b''.join(b'\t.equ %s, 0x%06x\t; %s\n' % (n, base + o2, EQU_TEXT[n]) for o2, n in VARS)
                b = b[:anchor.end()] + lines + b[anchor.end():]
            b = re.sub(rb'(\t\.equ HDAE5000_RAM_RcmStreamState, 0x[0-9a-f]+)\t; end of HdStreamBuffer \(HDAE5000_HD_WriteStream\)',
                       rb'\1\t; the RCM stream context (u16 state, dir, song, last result), right after HdStreamBuffer: HDAE5000_LoadSong_Rcm / _SaveSong_Rcm ldirw HDAE5000_RcmStream_InitialState over it, HDAE5000_RcmStream_Read / _Write keep their state word here', b)
        if b != o:
            p.write_bytes(b)
            print('edited', p)
