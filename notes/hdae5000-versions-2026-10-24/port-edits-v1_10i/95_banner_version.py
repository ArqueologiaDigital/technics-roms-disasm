"""The banner and the version string's label of the v1.10i tree (both came with v1.15i's):
HDAE5000_Str_V115i holds "V1.10i" here (0x2a3bb8), so it is HDAE5000_Str_V110i."""
import re
from _edit import read, write

for f in ("hd-ae5000_v1_10i.s", "hdae5000_ui_display.s", "hdae5000_data_tables.s"):
    s = read(f)
    s = re.sub(rb"HDAE5000_Str_V115i(?![\w])", b"HDAE5000_Str_V110i", s)
    s = s.replace(b'"V1.15i"', b'"V1.10i"')
    if f.startswith("hd-ae5000"):
        s = s.replace(b"; HD-AE5000 expansion ROM v1.15i  (IC4, 512 KiB at 0x280000)",
                      b"; HD-AE5000 expansion ROM v1.10i  (IC4, 512 KiB at 0x280000)")
        s, n = re.subn(rb"; PORTED from the v2\.01i tree \(hdae5000_v2_01i/\) by scripts/tools/port_hdae5000_version\.py:\n"
                       rb"; notes/hdae5000-versions-2026-10-24/port-edits-v1_15i/replay\.sh rebuilds this tree from it,\n",
                       b"; PORTED from the v1.15i tree (hdae5000_v1_15i/), itself ported from v2.01i, by\n"
                       b"; scripts/tools/port_hdae5000_version.py: notes/hdae5000-versions-2026-10-24/\n"
                       b"; port-edits-v1_10i/replay.sh rebuilds this tree from it,\n", s)
        assert n == 1
        s = s.replace(b"byte-identical to the v1.15i dump (SHA-1 581fa58e2cd6fe381cfc312c73771d25ff2e662c).",
                      b"byte-identical to the v1.10i dump (SHA-1 6019f3c28b6277730418974dde4dc6893fced00e).")
        s = s.replace(b"rebuilt_ROMs/hd-ae5000_v1_15i.llvm.elf and symbols/hdae5000_v1_15i_symbols_reference.txt\n;   give every name's v1.15i address.",
                      b"rebuilt_ROMs/hd-ae5000_v1_10i.llvm.elf and symbols/hdae5000_v1_10i_symbols_reference.txt\n;   give every name's v1.10i address.")
        s = s.replace(b"numbers objects as v1.15i does.", b"numbers objects as v1.10i does.")
        s = s.replace(b"; shared/event_codes.s is this tree's own (v1.x numbers the HD-AE5000's messages\n; differently); the rest of shared/ and the pictures that did not change come from\n; hdae5000/ through the build's second -I.",
                      b"; shared/event_codes.s and the boot splash come from hdae5000_v1_15i/ (the build's\n; second -I); the rest of shared/ and the other pictures from hdae5000/ (the third).")
        s = s.replace(b"; HD-AE5000 Hard Disk Expansion ROM, v1.15i\n", b"; HD-AE5000 Hard Disk Expansion ROM, v1.10i\n")
    write(f, s)
print("ok")
