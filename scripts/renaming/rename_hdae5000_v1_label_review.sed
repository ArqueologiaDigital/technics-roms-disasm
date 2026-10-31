# HD-AE5000 v1.15i / v1.10i: the label check's rename suggestions
# (scripts/analysis/hdae5000_version_label_check.py; notes/hdae5000-versions-2026-10-24/README.md,
# "v1.x label review").  Byte-neutral: every rule renames a label, deletes an unreferenced one,
# or spells a number with the symbol whose value it is.
#   sed -i -f scripts/renaming/rename_hdae5000_v1_label_review.sed \
#       hdae5000_v1_15i/{hd-ae5000_v1_15i,hdae5000_ui_display,hdae5000_hd_driver}.s \
#       hdae5000_v1_10i/{hd-ae5000_v1_10i,hdae5000_ui_display,hdae5000_hd_driver}.s
#
# --- HDAE5000_PPORT_Cmd09_SendFilesToPc: v1.x has eight part blocks (masks 0x01..0x80) and no
# ninth; the port left v2.x's .Lsfsb_bit<k> one block off and named three blocks _Skip/_Skip2/
# _Skip3.  Block k (mask 1<<k) is now .Lsfsb_bit<k>.  .Lsfsb_bit2 and .Lsfsb_bit6 stood inside
# a block (between its BytesLeft and SendMaskLo stores) and nothing branched to them.
/^\.Lsfsb_bit2:/d
/^\.Lsfsb_bit6:/d
s/^HDAE5000_PPORT_Cmd09_SendFilesToPc_Skip:$/.Lsfsb_bit1:\t\t\t\t; — Bit 1 (0x02)/;t
s/^\.Lsfsb_bit1:.*$/.Lsfsb_bit2:\t\t\t\t; — Bit 2 (0x04)/;t
s/^HDAE5000_PPORT_Cmd09_SendFilesToPc_Skip2:$/.Lsfsb_bit4:\t\t\t\t; — Bit 4 (0x10)/;t
s/^\.Lsfsb_bit4:.*$/.Lsfsb_bit5:\t\t\t\t; — Bit 5 (0x20)/;t
s/^HDAE5000_PPORT_Cmd09_SendFilesToPc_Skip3:$/.Lsfsb_bit6:\t\t\t\t; — Bit 6 (0x40)/;t
s/^\.Lsfsb_bit5:.*$/.Lsfsb_bit7:\t\t\t\t; — Bit 7 (0x80)/;t
s/[\t ]*; jp NZ, \.Lsfsb_bit[0-9]$//
s/(\.Lsfsb_bit1:24)/(@SFSB2:24)/
s/(\.Lsfsb_bit4:24)/(@SFSB5:24)/
s/(\.Lsfsb_bit5:24)/(@SFSB7:24)/
s/(HDAE5000_PPORT_Cmd09_SendFilesToPc_Skip:24)/(@SFSB1:24)/
s/(HDAE5000_PPORT_Cmd09_SendFilesToPc_Skip2:24)/(@SFSB4:24)/
s/(HDAE5000_PPORT_Cmd09_SendFilesToPc_Skip3:24)/(@SFSB6:24)/
s/(@SFSB\([0-9]\):24)/(.Lsfsb_bit\1:24)/
# the odd blocks read the part mask by number
s/^\tld\ta, (0x23c4e4:24)$/\tld\ta, (HDAE5000_RAM_PportPartMask:24)/
#
# --- HDAE5000_RAM_PportPartMaskHi: v1.x has no second mask byte (no ninth part); the port gave
# the name the part mask's own address, 0x23c4e4, so one address had two names.  Every use reads
# or writes the part mask.
/^\t\.equ HDAE5000_RAM_PportPartMaskHi, /d
s/HDAE5000_RAM_PportPartMaskHi\b/HDAE5000_RAM_PportPartMask/g
#
# --- HDAE5000_PPORT_Cmd10_RcvDataFromPc (v1.15i): v1.x has no "flag byte 2, bit 0" block, so the
# label in front of the closing jump is the exit, as v1.10i already names it.
s/^\.Lrfsb_flag2_bit0:.*$/.Lrfsb_exit:/;t
s/(\.Lrfsb_flag2_bit0:24)/(.Lrfsb_exit:24)/
#
# --- HDAE5000_SaveOptSwEventCatch: case 0x0a (select every part) is v2.x's _Skip3 (mask 0x00ff
# in v1.x, 0x01ff in v2.x); v1.x has no case 0x8b, so there is no _Skip3.._Skip6 chain to keep.
s/HDAE5000_SaveOptSwEventCatch_Skip7\b/HDAE5000_SaveOptSwEventCatch_Skip3/g
#
# --- HDAE5000_CopyFdSongToHd_Pmt: v1.x reads 64 KiB per pass (v2.x 32 KiB) and writes the first
# chunk before a read-and-append loop.  Names by meaning, from v2.x's where one matches:
#   .Lts925_1     first read and HD_WriteFile (was _Skip3; v2.x .Lts925_1)
#   .Lts925_loop  read and HD_AppendFile, repeated (was .Lts925_1; v2.x .Lts925_loop)
#   .Lts925_4     repeat while the read returned a full 64 KiB (was .Lts925_2; v2.x .Lts925_4)
#   .Lts925_5     mark the song's part present (was _Skip2; v2.x .Lts925_5)
#   .Lts925_close fclose and return the result (was _Skip; v2.x falls through to it)
# The old .Lts925_loop (between a cp and its jr) and .Lts925_4 (inside the mark block) were
# referenced by nothing.
/^\.Lts925_loop:$/d
/^\.Lts925_4:$/d
s/^\.Lts925_1:$/.Lts925_loop:/;t
s/^\.Lts925_2:$/.Lts925_4:/;t
s/^HDAE5000_CopyFdSongToHd_Pmt_Skip3:$/.Lts925_1:/;t
s/^HDAE5000_CopyFdSongToHd_Pmt_Skip2:$/.Lts925_5:/;t
s/^HDAE5000_CopyFdSongToHd_Pmt_Skip:$/.Lts925_close:/;t
s/^\tjr\tz, \.Lts925_1$/\tjr\tz, .Lts925_loop/
s/HDAE5000_CopyFdSongToHd_Pmt_Skip3$/.Lts925_1/
s/HDAE5000_CopyFdSongToHd_Pmt_Skip2$/.Lts925_5/
s/HDAE5000_CopyFdSongToHd_Pmt_Skip$/.Lts925_close/
s/^\tld\txbc, (xbc + 0xe88)$/\tld\txbc, (xbc + WS_HamaFnTable)/
s/^\tld_sril\txhl, (xbc + 0xa8)$/\tld_sril\txhl, (xbc + HamaFn_fread_ext)/
s/^\tlda\txwa, (0x20165a:24)$/\tlda\txwa, (HDAE5000_RAM_SongRecords-0x780+40:24)/
#
# --- The label check's "moved" rows: v2.x labels of the ninth part (bit 8, slot 8, flag byte 2)
# that the port left on v1.x code which has no ninth part.  Each now names what it labels.
#   HDAE5000_TypeSel_Init        .LHD_Data_Copy__bit8 -> __done (the retd after bit 7)
#   HDAE5000_Song_IsUsed         .Ltco_slot8 -> .Ltco_none (HL = 0xffff: no part present)
#   HDAE5000_Song_PartMask       .Ltl_chk8: referenced by nothing, deleted with its comment
#   HDAE5000_Song_CheckFreeSpace .Lcv_bit8 -> .Lcv_validate (the total-size check)
#   HDAE5000_PPORT_InitRegionDescriptors  .Lir_flag2_bit0 -> .Lir_done (its ret)
s/\.LHD_Data_Copy__bit8\b/.LHD_Data_Copy__done/g
/^\t; --- Slot 8: base 0x201676 ---$/d
s/\.Ltco_slot8\b/.Ltco_none/g
/^\t; --- Check slot 8: 0x201676 ---$/d
/^\.Ltl_chk8:$/d
/^\t; --- Bit 8: fixed constant 0x5000 ---$/d
s/\.Lcv_bit8\b/.Lcv_validate/g
s/\.Lir_flag2_bit0\b/.Lir_done/g
