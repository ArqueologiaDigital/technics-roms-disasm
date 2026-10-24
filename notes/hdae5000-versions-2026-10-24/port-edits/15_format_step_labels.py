"""HD_Format's step labels in v2.01i, put back on the steps v2.06i names them for.

The format routine ends in a chain of look-alike steps (call, test AtaError, jump on
success, else set an error number and leave).  The porting tool named the jump after the
settings-sector write anew (HDAE5000_HD_Format_CompareLoop_Skip4) and slid the local
labels one step on: .LHD_Format_CompareLoop_Skip3 ended up on IdentifyDevice, _Skip4 on
ParseIdentify, and an unreferenced _Skip5 after it.  v2.06i's names are restored:
_Skip3 = soft reset, _Skip4 = IdentifyDevice, _Skip5 = ParseIdentify.  The code is the
same in both versions here; only v2.06i's error number 0x05 is spelled in hex.

RUN (once): python3 notes/hdae5000-versions-2026-10-24/port-edits/15_format_step_labels.py
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
p = os.path.join(ROOT, "hdae5000_v2_01i", "hdae5000_ui_display.s")
s = open(p, "rb").read()
old = (b"\tjp\tz, (HDAE5000_HD_Format_CompareLoop_Skip4:24)\n"
       b"\tld\t(HDAE5000_RAM_AtaError), 0x05\n"
       b"\tjp\tHDAE5000_HD_Format_Exit\n"
       b"HDAE5000_HD_Format_CompareLoop_Skip4:\n"
       b"\tcall\tHDAE5000_ATA_SoftReset\n"
       b"\tcp\t(HDAE5000_RAM_AtaError:24), 0x00\n"
       b"\tjp\tz, (.LHD_Format_CompareLoop_Skip3:24)\n"
       b"\tld\t(HDAE5000_RAM_AtaError:24), 11\n"
       b"\tjp HDAE5000_HD_Format_Exit\n"
       b".LHD_Format_CompareLoop_Skip3:\n"
       b"\tcall HDAE5000_ATA_IdentifyDevice\n"
       b"\tcp\t(HDAE5000_RAM_AtaError:24), 0\n"
       b"\tjp\tz, (.LHD_Format_CompareLoop_Skip4:24)\n"
       b"\tld\t(HDAE5000_RAM_AtaError:24), 6\n"
       b"\tjp HDAE5000_HD_Format_Exit\n"
       b".LHD_Format_CompareLoop_Skip4:\n"
       b"\tcall HDAE5000_HD_ParseIdentify\n"
       b".LHD_Format_CompareLoop_Skip5:\n")
new = (b"\tjp\tz, (.LHD_Format_CompareLoop_Skip3:24)\n"
       b"\tld\t(HDAE5000_RAM_AtaError:24), 5\n"
       b"\tjp HDAE5000_HD_Format_Exit\n"
       b".LHD_Format_CompareLoop_Skip3:\n"
       b"\tcall HDAE5000_ATA_SoftReset\n"
       b"\tcp\t(HDAE5000_RAM_AtaError:24), 0\n"
       b"\tjp\tz, (.LHD_Format_CompareLoop_Skip4:24)\n"
       b"\tld\t(HDAE5000_RAM_AtaError:24), 11\n"
       b"\tjp HDAE5000_HD_Format_Exit\n"
       b".LHD_Format_CompareLoop_Skip4:\n"
       b"\tcall HDAE5000_ATA_IdentifyDevice\n"
       b"\tcp\t(HDAE5000_RAM_AtaError:24), 0\n"
       b"\tjp\tz, (.LHD_Format_CompareLoop_Skip5:24)\n"
       b"\tld\t(HDAE5000_RAM_AtaError:24), 6\n"
       b"\tjp HDAE5000_HD_Format_Exit\n"
       b".LHD_Format_CompareLoop_Skip5:\n"
       b"\tcall HDAE5000_HD_ParseIdentify\n")
assert s.count(old) == 1
open(p, "wb").write(s.replace(old, new))
print("ok")
