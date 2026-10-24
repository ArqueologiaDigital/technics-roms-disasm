"""The RAM image: WindowState_Init's tail is 12 bytes shorter, the six lyric lines are
35 bytes each (v2.06i: 40).

A record of a one-off hand edit of hdae5000_v2_01i/ (see README.md here); it matches
exact text of the tree as it was then and will not apply again.
"""
import os
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
T = os.path.join(ROOT, 'hdae5000_v2_01i') + '/'


def rep(f, old, new, count=1):
    s = open(T + f, 'rb').read()
    assert s.count(old) == count, (f, s.count(old), old[:80])
    s = s.replace(old, new)
    open(T + f, 'wb').write(s)


rep('hdae5000_init_data.s',
    b'\t.short 0xffff, 0xffff, 0xffff, 0xffff, 0x0001, 0x0000, 0x0000, 0x0000\n'
    b'\t.short 0x0000, 0x0000, 0x0000, 0x0000, 0x0000\n'
    b'HDAE5000_WindowGeometry_Init:\n',
    b'\t.short 0xffff, 0xffff, 0xffff, 0xffff, 0x0001, 0x0000, 0x0000\n'
    b'HDAE5000_WindowGeometry_Init:\n')
rep('hdae5000_init_data.s',
    b'HDAE5000_LyricLines_Init:\n'
    b'\t; RAM 0x23a0aa = HDAE5000_RAM_LyricLines: the six 40-byte text lines of the\n'
    b'\t; lyric window; HDAE5000_Lyrics_FillLines (hdae5000_ui_display.s) scrolls\n'
    b'\t; them up one line (0x23a0d2 -> 0x23a0aa) before refilling the last\n'
    b'\t.zero 240\n',
    b'HDAE5000_LyricLines_Init:\n'
    b'\t; HDAE5000_RAM_LyricLines: the six text lines of the lyric window, 35 bytes\n'
    b'\t; each in v2.01i (40 in v2.06i); HDAE5000_Lyrics_FillLines\n'
    b'\t; (hdae5000_ui_display.s) scrolls them up one line before refilling the last\n'
    b'\t.zero 210\n')
print('ok')
