"""Three fixes: WriteConfirmEditCheck's label back on its first instruction (the labels
of the deleted lyric colour routines had piled up in front of it); HD_LoadSettings'
last store is the lyric jump byte; the frame handler's object id 0x7F013E kept numeric.
(Run in two goes on the day: the first two parts, then the third.)

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


import sys
if 0:
  pass
# WriteConfirmEditCheck: its label had been left behind the pile of the labels of
# LyricForeColorCheck / LyricBackColorCheck, which v2.01i does not have
s = open(T + 'hdae5000_hd_driver.s', 'rb').read()
a = s.index(b'\tret\n\n\tpush xiz\n\tld\txiz, xwa\nHDAE5000_LyricJumpEditCheck_Default_OnRamDataReq:\n')
b = s.index(b'HDAE5000_WriteConfirmEditCheck:\n\t; registered as "WriteConfirmEditCheck" in HDAE5000_ObjHandler_Table\n', a)
b2 = b + len(b'HDAE5000_WriteConfirmEditCheck:\n\t; registered as "WriteConfirmEditCheck" in HDAE5000_ObjHandler_Table\n')
seg = s[a:b2]
assert seg.count(b'\tld\txwa, xbc\n') == 1
s = s[:a] + (b'\tret\n\n'
             b'; v2.01i has no LyricForeColorCheck / LyricBackColorCheck (the lyric colour\n'
             b'; settings of v2.06i): WriteConfirmEditCheck follows LyricJumpEditCheck.\n'
             b'HDAE5000_WriteConfirmEditCheck:\n'
             b'\t; registered as "WriteConfirmEditCheck" in HDAE5000_ObjHandler_Table\n'
             b'\tpush xiz\n\tld\txiz, xwa\n\tld\txwa, xbc\n') + s[b2:]
open(T + 'hdae5000_hd_driver.s', 'wb').write(s)

# HD_LoadSettings: v2.01i's last settings byte is the lyric jump
rep('hdae5000_ui_display.s', b'\tld\t(HDAE5000_RAM_LyricBackColor:24), a\n\tpop xiz\n\tret\n',
    b'\tld\t(HDAE5000_RAM_LyricJump:24), a\n\tpop xiz\n\tret\n')

# Frame_Handler_Status__init_display: the object id is numerically the same as in v2.06i
# (0x7F013E), which in v2.01i is the unnamed object 318, not FLS_FILE_LOAD_SW_EDIT (320)
s = open(T + 'hdae5000_ui_display.s', 'rb').read()
n = s.count(b'\tld xwa, HDAE5000_OBJ_FLS_FILE_LOAD_SW_EDIT')
assert n == 4, n
k = s.index(b'\tld xwa, HDAE5000_OBJ_FLS_FILE_LOAD_SW_EDIT\t; Display params')
head, tail = s[:k], s[k:]
tail = tail.replace(b'\tld xwa, HDAE5000_OBJ_FLS_FILE_LOAD_SW_EDIT\t; Display params',
    b'\t; [INFERENCE] a stale id: 0x7F013E is FLS_FILE_LOAD_SW_EDIT in v2.06i, but in v2.01i\n'
    b'\t; object 318 is unnamed and FLS_FILE_LOAD_SW_EDIT is 320 (HDAE5000_Set_Menu_Visibility\n'
    b'\t; uses that); this code kept the old number.\n'
    b'\tld\txwa, 0x007f013e', 1)
tail = tail.replace(b'\tld xwa, HDAE5000_OBJ_FLS_FILE_LOAD_SW_EDIT\n', b'\tld\txwa, 0x007f013e\n', 2)
s = head + tail
open(T + 'hdae5000_ui_display.s', 'wb').write(s)
print('ok')
