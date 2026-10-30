"""HDAE5000_Frame_Handler: v1.x has no lyric box to feed the song position to.

v1.15i's frame handler (0x28c103) starts with the sqsrtc watch (`ld XWA,(<sqsrtc ptr>) /
ld A,(XWA) / and A,0x04 / cp A,(<previous>)`, after an `inc 1,(0x22b3da)` the passes
align); v2.x first, while a lyric box is open, computes the position from sqbtof /
sq_beadt and posts EV_TICKS (0x01ca0004) to it.  That part goes, with its header line.
"""
import re
from _edit import read, write

f = "hdae5000_ui_display.s"
s = read(f)
s, n = re.subn(rb"\tld xwa, \(HDAE5000_RAM_LyricBoxObj:24\); the open lyric box, or -1\n(?:.*\n)*?"
               rb"(?=HDAE5000_Frame_Handler_Status:\n)", b"", s)
assert n == 1
s, n = re.subn(rb"\t; 1\. While a lyric box is open \(HDAE5000_RAM_LyricBoxObj != -1\)(?:.*\n)*?"
               rb"(?=\t; 2\. \(_Status\))", b"\t; (v1.x has no lyric box, so no song-position post: v2.x's part 1.)\n", s)
assert n == 1
write(f, s)
print("ok")
