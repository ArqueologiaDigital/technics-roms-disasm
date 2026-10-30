"""v1.x has no lyrics, no floppy lyric selector and no file-selection backdrop: delete the code.

Evidence (the ROM images, scripts/tools/port_hdae5000_version.py registered_table):
  * v1.15i's ApFunction name table (registered as 0x42A) lacks SfxTlxBitCheck,
    DelTlxEditCheck, BitmapButt01 (HDAE5000_Alloc_Memory_3, the FilePanel bitmap) and
    LyricJumpEditCheck, and the EV_* messages of the lyric box and the floppy selector;
  * its class table (0x16A) has 10 classes: no TtlScreenR3, LyricBox or FDFileSelect;
  * "TLhd", "TLtr", ".TLX", ".TTX", "XLT.", "LyricBox", "FDFileSelect" and "TtlScreenR3" occur
    0 times in v1.15i (and v1.10i), 1-7 times each in v2.01i.
So every routine that only these reach goes: the lyric box and its Lyrics_* helpers (with
SwapBytes, Read_Table_* and the VarLen codec, which only they call), the floppy lyric list,
the TLX part of song load / save / copy / delete, HDAE5000_StrRev (only FdLyricList_AddTlx
calls it).  port_hdae5000_version.py status v1_15i showed each of them as a hunk with
(almost) nothing on the v1.15i side: LyricBoxProc..FdLyricList_AddTlx 9,653 B -> 0,
SfxTlxBitCheck 229 -> 0, LoadSong_Tlx 262 -> 3, CopyFdSongToHd_Tlx 302 -> 0, StrRev 95 -> 0.
"""
from _edit import delete_routines

delete_routines("hd-ae5000_v1_15i.s", ["HDAE5000_Alloc_Memory_3", "HDAE5000_TtlScreenR3Proc"])
delete_routines("hdae5000_hd_driver.s", ["HDAE5000_SfxTlxBitCheck", "HDAE5000_LyricJumpEditCheck"])
delete_routines("hdae5000_filesystem.s", ["HDAE5000_LBNTlxBitCheck_Unregistered", "HDAE5000_DelTlxEditCheck"])
delete_routines("hdae5000_ui_display.s", [
    "HDAE5000_LyricBoxProc", "HDAE5000_Lyrics_ClearBuffer", "HDAE5000_Lyrics_CheckFile",
    "HDAE5000_Lyrics_LoadTestFile", "HDAE5000_Lyrics_PlayToPosition", "HDAE5000_Lyrics_ResetState",
    "HDAE5000_Lyrics_ReadSongInfo", "HDAE5000_Lyrics_FillLines", "HDAE5000_Lyrics_FindEvent",
    "HDAE5000_Lyrics_ParseEvent", "HDAE5000_Read_Table_Word", "HDAE5000_Read_Table_Multi",
    "HDAE5000_Lyrics_ReadVarLen", "HDAE5000_Lyrics_WriteVarLen", "HDAE5000_Lyrics_CheckHeaderChunk",
    "HDAE5000_Lyrics_CheckTrackChunk", "HDAE5000_SwapBytes32", "HDAE5000_SwapBytes16",
    "HDAE5000_FDFileSelectProc", "HDAE5000_FdLyricList_Scan", "HDAE5000_FdLyricList_AddTlx",
    "HDAE5000_LoadSong_Tlx", "HDAE5000_SaveSong_Tlx", "HDAE5000_TlxPart_Describe",
    "HDAE5000_CopyFdSongToHd_Tlx", "HDAE5000_DeleteSongPart_Tlx"])
delete_routines("hdae5000_utilities.s", ["HDAE5000_StrRev"])
