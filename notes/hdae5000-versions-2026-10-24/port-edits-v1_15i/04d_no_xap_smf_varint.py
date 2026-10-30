"""v2.x code v1.15i does not have: PC-link services 28-30, the VarInt codec, the SMF header
reader, HDAE5000_StrUpr; and the strings only they or the TLX code read.

  * v1.15i's HDAE5000_PPORT_ServiceTable (0x2914fc) has 28 entries, 0-27: its handlers
    start right after them, at 0x29156c.  Services 28 (FlashXapFile: "XAP" occurs once in
    v1.15i, against the v2.x descriptor's "XAP" and "Send XapFile flash"), 29 and 30
    (the main-CPU hooks +0x538 / +0x53C) are v2.x's;
  * HDAE5000_VarInt_Encode / _Decode, HDAE5000_Smf_SwapBytes32 / 16, _Smf_ReadHeader and
    _Smf_CheckHeader are unreferenced in v2.x (the SMF reader opens a floppy file "rb");
    HDAE5000_StrUpr's only caller was FdLyricList_AddTlx (04).  The anchored `code` pass
    found nothing of them in v1.15i and left their labels on empty bodies, so they go here;
  * the strings: "XAP", the SMF reader's "rb", ".TLX" / "rb" of the TLX part loaders.
"""
from _edit import delete_routines, delete_block, replace, read, write
import re

delete_routines("hdae5000_ui_display.s", [
    "HDAE5000_PPORT_Svc28_FlashXapFile", "HDAE5000_PPORT_Svc29_MainHook0538",
    "HDAE5000_PPORT_Svc30_MainHook053C", "HDAE5000_VarInt_Encode", "HDAE5000_VarInt_Decode",
    "HDAE5000_Smf_SwapBytes32", "HDAE5000_Smf_SwapBytes16", "HDAE5000_Smf_ReadHeader",
    "HDAE5000_Smf_CheckHeader"])
delete_routines("hdae5000_utilities.s", ["HDAE5000_StrUpr"])
for lab in ["HDAE5000_Str_XAP", "HDAE5000_Str_Rb_Smf_ReadHeader", "HDAE5000_FdSong_CheckFiles_Str_TLX",
            "HDAE5000_FdSong_CheckFiles_Str_rb_9", "HDAE5000_CopyFdSongToHd_Tlx_Str_TLX",
            "HDAE5000_CopyFdSongToHd_Tlx_Str_rb"]:
    print("deleted", lab, len(delete_block("hdae5000_data_tables.s", lab)), "lines")

# the service table: entries 28-30 and their stubs go
s = read("hdae5000_ui_display.s")
for k in (28, 29, 30):
    s, n = re.subn(rb"\t\.long \.Lpps_handler_%d\t; entry %d\n" % (k, k), b"", s)
    assert n == 1, k
    s, n = re.subn(rb"\.Lpps_handler_%d:\n(?:\t[^\n]*\n)*?\tnop\n" % k, b"", s)
    assert n == 1, k
s = s.replace(b"\t; 31-entry jump table (entry 0 unused, entries 1-30 = commands)",
              b"\t; 28-entry jump table (entry 0 unused, entries 1-27 = commands)")
s = s.replace(b"\t; --- Handler stubs (commands 0-30) ---", b"\t; --- Handler stubs (commands 0-27) ---")
write("hdae5000_ui_display.s", s)
print("ok")
