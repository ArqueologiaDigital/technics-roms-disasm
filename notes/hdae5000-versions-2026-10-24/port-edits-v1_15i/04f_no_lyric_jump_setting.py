"""v1.x keeps three setting bytes in sector 1, not four: no HDAE5000_RAM_LyricJump.

v1.15i (unidasm): HDAE5000_HD_LoadSettings reads QuickLoadMode (0x229da9), LoadByNumberMode
(0x229daa) and JumpAfterLoad (0x229dab) from the sector and returns (0x295901-0x295919);
SaveSettings writes the same three, then the 0xffffffff long (0x29595d-0x29597a); HD_Init
(0x293279-0x293285), HD_Format and BuildSettingsSector (0x294922-0x294935) set or copy
three.  v2.x has a fourth, LyricJump (0x229dac), and five places that, when it is 2 and the
loaded part mask has the TLX bit (0x0100), show the lyrics screen (HDAE5000_OBJ_Tech_lyrics):
no `cp (0x229dab), 2` exists in v1.15i.  All of it goes.
"""
import re
from _edit import read, write

def sub(f, pat, rep, count):
    s = read(f)
    s, n = re.subn(pat, rep, s)
    assert n == count, (f, pat[:60], n)
    write(f, s)

# the "show the lyrics after load" blocks: from the test of LyricJump through the post
for f, n in (("hdae5000_hd_driver.s", 3), ("hdae5000_filesystem.s", 2)):
    sub(f, rb"\tcp\s+\(HDAE5000_RAM_LyricJump:24\), (?:2|0x02)[^\n]*\n(?:[^\n]*\n){1,14}?"
           rb"(?:[^\n]*HDAE5000_OBJ_Tech_lyrics[^\n]*\n)(?:[^\n]*\n){1,3}?\t+call\s*\(xhl\)[^\n]*\n", b"", n)
u = "hdae5000_ui_display.s"
sub(u, rb"\tld\t\(HDAE5000_RAM_LyricJump:24\), 1\n(?=\tld\t\(0x229dc6:24\), 0\n)", b"", 1)
sub(u, rb"(\tld\t\(HDAE5000_RAM_JumpAfterLoad:24\), a\n)\tinc 1, xix\n\tld\ta, \(xix\)\n"
       rb"\tld\t\(HDAE5000_RAM_LyricJump:24\), a\n", rb"\1", 2)
sub(u, rb"\tld a, \(xix\+\)\n\tld\t\(HDAE5000_RAM_JumpAfterLoad:24\), a\n\tld\ta, \(xix\)\n"
       rb"\tld\t\(HDAE5000_RAM_LyricJump:24\), a\n",
    b"\tld\ta, (xix)\n\tld\t(HDAE5000_RAM_JumpAfterLoad:24), a\n", 1)
sub(u, rb"\tld\ta, \(HDAE5000_RAM_LyricJump:24\)\n\tld \(xix\+\), a\n", b"", 1)
sub(u, rb"(\tld\t\(HDAE5000_RAM_JumpAfterLoad:24\), 1\n\tinc 1, xix\n)\tld\t\(xix\), 0x01\n"
       rb"\tld\t\(HDAE5000_RAM_LyricJump:24\), 1\n\tinc 1, xix\n", rb"\1", 1)
print("ok")
sub("hd-ae5000_v1_15i.s", rb"\t\.equ HDAE5000_RAM_LyricJump, 0x229dac[^\n]*\n", b"", 1)
