#!/usr/bin/env python3
"""Print, per KN5000 TRACK ASSIGN value, the panel-record (tag, offset, mask, handler) lists the
sequencer records (SeqTrackAssign_RecordMapTable) and plays back (SeqTrackAssign_PlaybackMapTable).
Usage: dump_track_assign_maps.py V10_PROGRAM_ROM   (base 0xE00000; v10 symbol addresses below)"""
import sys, struct
rom = open(sys.argv[1], 'rb').read(); BASE = 0xE00000
PARTTAG = 0xFCBA03; REC = 0xFCBA47; PLAY = 0xFCBFA3
def rd(a, n): return rom[a-BASE:a-BASE+n]
tags = rd(PARTTAG, 20)
names = {0:'RIGHT1',1:'LEFT',2:'RIGHT2',12:'DRUMS',13:'CHORD',14:'APC',15:'CONTROL',16:'RHYTHM'}
def lst(p):
    out = []
    while True:
        e = rd(p, 4)
        if e[0] == 0xFF: break
        out.append('%02X/%02X m%02X h%d' % (e[0], e[1], e[2], e[3])); p += 4
    return out
for v in range(20):
    r = struct.unpack('<I', rd(REC + 4*v, 4))[0]; p = struct.unpack('<I', rd(PLAY + 4*v, 4))[0]
    print('assign %2d (%s) part tag %02X' % (v, names.get(v, 'PART?'), tags[v]))
    print('   record  @%06X: %s' % (r, ', '.join(lst(r))))
    print('   playback@%06X: %s' % (p, ', '.join(lst(p))))
