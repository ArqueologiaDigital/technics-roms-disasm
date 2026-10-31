#!/usr/bin/env python3
"""Per PC-link command, which bytes of the 256-byte link packet does the HD-AE5000 read and write?

QUESTION: hdae5000-filesystem.md carried an "older reading, not re-verified" packet layout.  This
reads each handler HDAE5000_PPORT_Cmd01_.. Cmd20_ in an HD-AE5000 tree's hdae5000_ui_display.s
and prints, per command:
  * the services it runs (WA = n before `call HDAE5000_PPORT_CallService`; 26 = show status);
  * whether it latches packet bytes 1..4 as arguments (HDAE5000_PPORT_LatchPacketArgs:
    dir, song, part mask low, part mask high);
  * packet offsets it reads/writes directly while XIX/XIY point at HDAE5000_RAM_PportPacket;
  * the info-block ranges it copies into the reply (HDAE5000_PPORT_CopyInfoToPacket BC..HL);
  * the transfers it makes (SendPacket / SendBlock / RecvBlock / SendRegionToPc ...).
It is a reading aid over the source text, not an emulator: the README cites the lines it lists.

Usage: python3 notes/open4-kn5000-b/hdae/probes/pport_packet_map.py [hdae5000/hdae5000_ui_display.s]
"""
import re
import sys

path = sys.argv[1] if len(sys.argv) > 1 else 'hdae5000/hdae5000_ui_display.s'
lines = open(path, 'rb').read().decode('latin-1').splitlines()
start = re.compile(r'^(HDAE5000_PPORT_Cmd(\d\d)_\w+):')
cmds = []
cur = None
for ln in lines:
    m = start.match(ln)
    if m and "_Str" in m.group(1):
        m = None
    if m:
        cur = {'name': m.group(1), 'n': int(m.group(2)), 'body': []}
        cmds.append(cur)
        continue
    if cur is not None:
        if re.match(r'^HDAE5000_PPORT_CommandDone:', ln):
            cur = None
            continue
        cur['body'].append(ln.split(';')[0])
XFER = ('SendPacket', 'SendBlock', 'RecvBlock', 'SendRegionToPc', 'SendTwoRegions', 'RecvCustomData',
        'RecvSector', 'SendByte', 'InitRegionDescriptors', 'RequestSongInfo', 'FlagPacketError')
for c in cmds:
    svc, copies, rd, wr, xf = [], [], set(), set(), []
    latch = False
    wa = bc = hl = None
    ptr = {}
    for s in c['body']:
        s = s.strip()
        m = re.match(r'ldw? wa, (0x[0-9A-Fa-f]+|\d+)(?::i3)?$', s)
        if m:
            wa = int(m.group(1), 0)
        m = re.match(r'ldw bc, (0x[0-9A-Fa-f]+)$', s) or re.match(r'ld bc, (\d+):i3$', s)
        if m:
            bc = int(m.group(1), 0)
        m = re.match(r'ldw hl, (0x[0-9A-Fa-f]+)$', s)
        if m:
            hl = int(m.group(1), 0)
        m = re.match(r'lda (xi[xy]), \(HDAE5000_RAM_PportPacket:24\)', s)
        if m:
            ptr[m.group(1)] = 0
            continue
        m = re.match(r'ld (xi[xy]), \(HDAE5000_RAM_PportInfoPtr:24\)', s)
        if m:
            ptr.pop(m.group(1), None)
        m = re.match(r'add (xi[xy]), (0x[0-9A-Fa-f]+|\d+)$', s)
        if m and m.group(1) in ptr:
            ptr[m.group(1)] += int(m.group(2), 0)
        if 'call HDAE5000_PPORT_CallService' in s and wa is not None:
            svc.append(wa)
            if wa == 1:   # service 1 returns XIX = HDAE5000_RAM_PportInfoBlock
                ptr.pop('xix', None)
        if 'call HDAE5000_PPORT_LatchPacketArgs' in s:
            latch = True
        if 'call HDAE5000_PPORT_CopyInfoToPacket' in s:
            copies.append('0x%02X..0x%02X' % (bc, hl - 1))
        for x in XFER:
            if re.search(r'call HDAE5000_PPORT_%s\b' % x, s):
                xf.append(x)
        for reg in list(ptr):
            for m in re.finditer(r'\(%s(?: \+ |\+)(0x[0-9A-Fa-f]+|\d+)\)|\(%s\)' % (reg, reg), s):
                off = ptr[reg] + (int(m.group(1), 0) if m.group(1) else 0)
                dst = s.split(',')[0]
                (wr if '(' in dst and reg in dst else rd).add(off)
    print('Cmd%02d %s' % (c['n'], c['name'].split('_', 3)[3]))
    print('   services   :', ' '.join(str(x) for x in svc) or '-')
    print('   args 1..4  :', 'latched (dir, song, mask lo, mask hi)' if latch else '-')
    print('   pkt read   :', ' '.join('+0x%02X' % x for x in sorted(rd)) or '-')
    print('   pkt write  :', ' '.join('+0x%02X' % x for x in sorted(wr)) or '-')
    print('   info copy  :', ' '.join(copies) or '-')
    print('   transfers  :', ' '.join(xf) or '-')
