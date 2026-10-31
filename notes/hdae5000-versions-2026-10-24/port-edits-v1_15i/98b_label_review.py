"""Clean-up 98b: the label check's rename suggestions on the v1 trees (2026-10-31, lane hdae-ledgers).

scripts/analysis/hdae5000_version_label_check.py v1_15i --base v2_01i listed 6 rename suggestions,
and v1_10i --base v1_15i 1.  scripts/renaming/rename_hdae5000_v1_label_review.sed (its comments give
the evidence per rule) renames them; this script runs it on PORT_TREE and fixes the comments around
the renamed blocks that still described v2.x's nine parts:

  HDAE5000_PPORT_Cmd09_SendFilesToPc  the part-bit chain: block k (mask 1 << k) is .Lsfsb_bit<k>
                                      (the port had v2.x's labels one block off, and _Skip/_Skip2/
                                      _Skip3); v1.x sends 8 region descriptors, not 9, and three
                                      "; region N" comments named the wrong region
  HDAE5000_RAM_PportPartMaskHi        an alias of the part mask (both 0x23c4e4): v1.x has no ninth
                                      part, so every use is the part mask
  HDAE5000_PPORT_Cmd10_RcvDataFromPc  v1.15i's .Lrfsb_flag2_bit0 is the exit (v1.10i: .Lrfsb_exit)
  HDAE5000_SaveOptSwEventCatch        _Skip7 is v2.x's _Skip3 (case 0x0a, every part)
  HDAE5000_CopyFdSongToHd_Pmt         the read / write / append loop, named from v2.x's .Lts925_*
  the "moved" rows                    v2.x's ninth-part labels (.LHD_Data_Copy__bit8, .Ltco_slot8,
                                      .Ltl_chk8, .Lcv_bit8, .Lir_flag2_bit0) on v1.x code that has no
                                      ninth part; HDAE5000_Song_IsUsed and HDAE5000_DeleteDirectory
                                      said "nine" parts (v1.x: 8 slots, 8 DeleteSongPart_* calls)

Byte-neutral (make gate).  NOT idempotent: the sed renames .Lts925_1 to .Lts925_loop and deletes a
`.Lts925_loop:` line, so it runs once per tree.  replay.sh runs it on v1.15i after 98; the v1.10i
tree was fixed by running it once with PORT_TREE=hdae5000_v1_10i, and port-edits-v1_10i/replay.sh
does not run it, because that replay starts from the fixed v1.15i tree.
"""
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _edit as E

ver = E.TREE.replace("hdae5000_", "")
SED = os.path.join(E.ROOT, "scripts", "renaming", "rename_hdae5000_v1_label_review.sed")
files = [E.path(f) for f in ("hd-ae5000_%s.s" % ver, "hdae5000_ui_display.s", "hdae5000_hd_driver.s")]
subprocess.run(["sed", "-i", "-f", SED] + files, check=True)

E.replace("hdae5000_ui_display.s", [
    (b"\t; build transfer buffer (masked bytes + 9 region descriptors),\n"
     b"\t; send to PC via PPORT, then conditionally send each region\n"
     b"\t; based on flag bits (8 bits from byte 1 + 1 bit from byte 2)\n",
     b"\t; build transfer buffer (masked bytes + 8 region descriptors),\n"
     b"\t; send to PC via PPORT, then conditionally send each region\n"
     b"\t; based on part bits 0-7 of HDAE5000_RAM_PportPartMask (v1.x has no ninth part)\n"),
    (b"\t; Copy 9 \xc3\x97 32-bit region descriptors to buffer\n",
     b"\t; Copy 8 \xc3\x97 32-bit region descriptors to buffer\n"),
    (b"\tld xwa, (HDAE5000_RAM_PportRegions+28:24)\t; region 1\n",
     b"\tld xwa, (HDAE5000_RAM_PportRegions+28:24)\t; region 2\n"),
    (b"\tld xwa, (HDAE5000_RAM_PportRegions+52:24)\t; region 4\n",
     b"\tld xwa, (HDAE5000_RAM_PportRegions+52:24)\t; region 5\n"),
    (b"\tld xwa, (HDAE5000_RAM_PportRegions+64:24)\t; region 5\n",
     b"\tld xwa, (HDAE5000_RAM_PportRegions+64:24)\t; region 7\n"),
    (b"; Size one region per part bit of HDAE5000_RAM_PportPartMask (and bit 0 of\n"
     b"; PportPartMaskHi): fixed sizes 0xE40 (bit 0), 0x12CB0 (1), 0x72AA (4) and\n"
     b"; 0x400 (7), and for the ninth part (TLX) the ADDRESS of\n"
     b"; HDAE5000_RAM_LyricFileLength; bits 2, 3, 5, 6 read the size from\n",
     b"; Size one region per part bit of HDAE5000_RAM_PportPartMask (bits 0-7; v1.x\n"
     b"; has no ninth part): fixed sizes 0xE40 (bit 0), 0x12CB0 (1), 0x72AA (4) and\n"
     b"; 0x400 (7); bits 2, 3, 5, 6 read the size from\n"),
    (b"; Does a song hold any part?  Tests the nine first-cluster slots (+36.. of the\n",
     b"; Does a song hold any part?  Tests the eight first-cluster slots (+36.. of the\n"),
    (b"\t; Delete directory WA: every used song of it loses its nine parts\n",
     b"\t; Delete directory WA: every used song of it loses its eight parts\n"),
])
