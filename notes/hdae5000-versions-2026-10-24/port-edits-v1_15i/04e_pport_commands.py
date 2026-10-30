"""PC-link commands 01 and 20 as v1.x has them (hdae5000_ui_display.s).

v1.15i, unidasm:
  * command 01 (0x291984): status record, HDAE5000_PPORT_ClearPacket, service 3, then on
    success HDAE5000_PPORT_CopyInfoToPacket (BC = 0x97, HL = 0xbf) and on failure
    HDAE5000_PPORT_FlagPacketError.  It does not latch packet bytes 1-2 (v2.x: into
    0x239098 / 0x23909a) and does not compare the PC program's version with
    HDAE5000_FileFormat_VersionMajor -- so no "Error : Wrong Dll Ver " record either;
  * service 03 stores no file-format version at PportInfoBlock+200 / +201;
  * command 20 (0x292824) is `jp HDAE5000_PPORT_CommandDone` alone: no status record, no
    XAP flash transfer.  Its record in the status-string table reads "20>nothing" (as 12,
    15 and 19 do); v2.x's "20>End flash right" / "20>End flash false" are not there.
"""
import re
from _edit import read, write

f = "hdae5000_ui_display.s"
s = read(f)
s, n = re.subn(rb"\tlda xix, \(HDAE5000_RAM_PportPacket:24\)\n\tnop\n\tld a, \(xix \+ 1\)\t+; read flag byte 1\n"
               rb"(?:.*\n){6}\tnop\n(?=\tcall HDAE5000_PPORT_ClearPacket\n)", b"", s)
assert n == 1, "flag bytes"
s, n = re.subn(rb"\tjp z, \(\.Lc2b_check_compat:24\)[^\n]*\n\tnop\n\tjp \.Lc2b_do_cleanup\n\.Lc2b_check_compat:\n"
               rb"(?:.*\n)*?\.Lc2b_do_cleanup:\n",
               b"\tjp z, (.Lc2b_compat_ok:24)\t\t\t; success: copy the info block\n\tnop\n", s)
assert n == 1, "compat check"
s, n = re.subn(rb"HDAE5000_PPORT_Cmd20_SendXapFileFlash:[^\n]*\n(?:.*\n)*?(?=\nHDAE5000_PPORT_CommandDone:)",
               b"HDAE5000_PPORT_Cmd20_Nothing:\n"
               b"\t; PC-link command 20: HDAE5000_PPORT_CommandTable entry 19.  Does nothing, and\n"
               b"\t; unlike 12, 15 and 19 shows no status record (v2.x flashes a XAP file here).\n"
               b"\tjp HDAE5000_PPORT_CommandDone\n", s)
assert n == 1, "cmd20"
s = s.replace(b"HDAE5000_PPORT_Cmd20_SendXapFileFlash_Str_N20_Send_XapFile_flash:\t.asciz \"20>Send XapFile flash \"",
              b"HDAE5000_PPORT_Cmd20_Nothing_Str_N20_nothing:\t.asciz \"20>nothing            \"")
s, n = re.subn(rb"HDAE5000_PPORT_Cmd20_Str_EndFlashRight:\n(?:.*\n){2}HDAE5000_PPORT_Cmd20_Str_EndFlashFalse:\n(?:.*\n){2}"
               rb"HDAE5000_PPORT_Cmd01_SendInfosAboutHd_Str_Error_Wrong_Dll_Ver:[^\n]*\n\t\.byte 0x00[^\n]*\n", b"", s)
assert n == 1, "records"
s = re.sub(rb"HDAE5000_PPORT_Cmd20_SendXapFileFlash(?![\w])", b"HDAE5000_PPORT_Cmd20_Nothing", s)
# service 03: the info block ends at +190 (CopyInfoToPacket copies 0xbf bytes): no
# file-format version bytes at +200 / +201
s, n = re.subn(rb"\tld\ta, \(HDAE5000_RAM_FileFormat_VersionMajor:24\)\n\tld\t\(HDAE5000_RAM_PportInfoBlock\+200:24\), a\n"
               rb"\tld\ta, \(HDAE5000_RAM_FileFormat_VersionMinor:24\)\n\tld\t\(HDAE5000_RAM_PportInfoBlock\+201:24\), a\n", b"", s)
assert n == 1, "svc03"
write(f, s)
print("ok")
