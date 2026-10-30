"""The callers of the TLX part routines 04 deleted: the ninth part (mask bit 8) is not there.

v1.15i's HDAE5000_SaveSong ends its part chain with the MD part (mask bit 7) and branches
straight to the code after it (unidasm of v1.15i at 0x28dbb1-0x28dbe9: `jr NZ,0x28dbe9` /
`jr T,0x28dbe9` after DeleteSongPart_Md, and 0x28dbe9 is `cp (XSP+0x04),0xffff`, the tail).
The same holds for LoadSong (.Ltl2_bit8), CopyFdSongToHd, HDAE5000_Fls_ForgetSong (no
DeleteSongPart_Tlx after DeleteSongPart_Md), the delete loop's bit-8 test (.Lws36b_bit8) and
PC-link service 13, which describes the lyrics (TlxPart_Describe, PportInfoBlock+191..199)
in v2.x and not in v1.15i (unidasm 0x290df6-0x290e0b: the SQF part's zero byte at +150,
then the HD_GetSongInfo call).
"""
from _edit import delete_between, replace

f = "hdae5000_ui_display.s"
delete_between(f, ".Ltl2_bit8", ".Ltl2_final")
delete_between(f, "HDAE5000_SaveSong_Join9", "HDAE5000_SaveSong_Join10")
delete_between(f, "HDAE5000_CopyFdSongToHd_Join9", "HDAE5000_CopyFdSongToHd_Join10")
delete_between(f, ".Lws36b_bit8", ".Lws36b_calc")
replace(f, [
    (b"""	calr HDAE5000_DeleteSongPart_Md
	ld wa, (xsp + 10)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Tlx
""", b"""	calr HDAE5000_DeleteSongPart_Md
"""),
    (b"""	ld	(HDAE5000_RAM_PportInfoBlock+150:24), 0
	lda	xwa, (xsp+68)
	ld	xbc, xwa
	ldw	wa, 0x000a
	call HDAE5000_TlxPart_Describe
	ld xwa, (xsp + 0x44)
	ld	(HDAE5000_RAM_PportInfoBlock+191), xwa
	ld xwa, (xsp + 0x48)
	ld	(HDAE5000_RAM_PportInfoBlock+195), xwa
	ld	(HDAE5000_RAM_PportInfoBlock+199:24), 0
""", b"""	ld	(HDAE5000_RAM_PportInfoBlock+150:24), 0
"""),
])
print("ok")
