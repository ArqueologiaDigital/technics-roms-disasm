"""The names of what 04 / 05 deleted, in the class, message and parameter-name pools and the
registry tables of the .data image (hdae5000_data_tables.s, hdae5000_init_data.s).

From the v1.15i image (tables found through the registration, registered_table):
  * class table 0x16A has 10 records and HDAE5000_RECORD_COUNT is 10; the class-name pool
    after the records' 5,904-byte zero gap starts with AcLanguageText1's (empty) signature
    at 0x299762: no "Gnn" / "FDFileSelect" / "mc^^c^" / "LyricBox" / "TtlScreenR3";
  * the event-name table 0x1CA (0x2e1216) has 3 entries, EV_TimerBack / EV_AfterLoad /
    EV_SeqStop, then its count 3; the message-name table 0x1EA (0x2e1228) 13 (no
    MT_FdSaveLyric / MT_FdLoadLyric / MT_FdInfo / MT_FdFreshUp / MT_SelectAll), count 13;
  * the class procedure / name tables 0x10A / 0x40A have 10 entries;
  * the parameter-name pool's empty names of AcWindowPage1 / IvScreenR2 / AcLanguageText1 are
    at 0x297f5c / 5e / 60 (their propname lists' terminators), TtlScreenR3's is gone;
  * the parameter-name pool ends with IvHddNaming's "func" and 11 zero bytes before
    the record table (0x297f57-0x297f61): no LyricBox / FDFileSelect parameter names, and
    no propname lists for TtlScreenR3, LyricBox, FDFileSelect.
"""
import re
from _edit import read, write, delete_block, delete_lines, replace

D, I = "hdae5000_data_tables.s", "hdae5000_init_data.s"
for lab in ["ClassSig_FDFileSelect", "ClassName_FDFileSelect", "ClassSig_LyricBox", "ClassName_LyricBox",
            "ClassSig_TtlScreenR3", "ClassName_TtlScreenR3"]:
    delete_block(D, lab, with_header=False)
s = read(D)
s, n = re.subn(rb"\n\.zero 5832\n", b"\n.zero 5904\n", s)
assert n == 1
s, n = re.subn(rb"\t\.byte 0x0d, 0x00( +); u16 count = 13 \(LE\); matches HDAE5000_RECORD_TABLE's 13\n",
               lambda m: b"\t.byte 0x0a, 0x00" + m.group(1) + b"; u16 count = 10 (LE); matches HDAE5000_RECORD_TABLE's 10\n", s)
assert n == 1
s, n = re.subn(rb"\t\.zero 15\nHDAE5000_ParamStr_LyricBox_infocolor:\n(?:.*\n)*?\t\.byte 0x00\n(?=\nHDAE5000_RECORD_TABLE:)",
               b"\t.zero 11\n", s)
assert n == 1
write(D, s)
for lab in ["HDAE5000_ParamNames_TtlScreenR3", "HDAE5000_ParamNames_LyricBox", "HDAE5000_ParamNames_FDFileSelect"]:
    delete_block(I, lab, with_header=False)
s = read(I)
gone = [b"EV_DrawFDText", b"EV_InitFDFileSelect", b"EV_Scrollline", b"EV_Drawsyllable", b"EV_Alldraw",
        b"EV_Initlyrics", b"EV_SETPOSITION", b"EV_BEATMESSAGE", b"EV_TICKS", b"EV_INITLYRICPARAM",
        b"MT_FdSaveLyric", b"MT_FdLoadLyric", b"MT_FdInfo", b"MT_FdFreshUp", b"MT_SelectAll",
        b"FDFileSelectProc", b"LyricBoxProc", b"TtlScreenR3Proc"]
for g in gone:
    s, n = re.subn(rb"\t\.long HDAE5000_Str_" + g + rb"\n", b"", s)
    assert n == 1, g
s, n = re.subn(rb"\t\.set HDAE5000_ParamStr_(TtlScreenR3|LyricBox)_End,[^\n]*\n", b"", s)
assert n == 2
# the empty names after TtlScreenR3's sit 2 bytes lower (v1.15i: 0x297f5c / 5e / 60)
for name, old, new in ((b"AcWindowPage1", 0x70, 0x6e), (b"IvScreenR2", 0x72, 0x70), (b"AcLanguageText1", 0x74, 0x72)):
    s, n = re.subn(rb"(\t\.set HDAE5000_ParamStr_" + name + rb"_End,\s+HDAE5000_UI_Config \+ )0x%x\b" % old,
                   rb"\g<1>0x%x" % new, s)
    assert n == 1, name
s = s.replace(b"HDAE5000_EventName_Count:\n\t.short 13\n", b"HDAE5000_EventName_Count:\n\t.short 3\n")
s = s.replace(b"HDAE5000_MessageName_Count:\n\t.short 18\n", b"HDAE5000_MessageName_Count:\n\t.short 13\n")
write(I, s)
print("ok")
