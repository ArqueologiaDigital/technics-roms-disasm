# v6 / v5: give seven routines the v7 / v10 names of the same code (2026-11-20, lane_p6).
# Staged firmware C of v6 / v5 calls them by those names (semenu_routines_m0.c, sound_editor_ui_m0.c,
# semenu_routines_m129.c, fdc_routines_m270_xr_b.c); V4.23's per-tree check could not resolve them.
# Evidence: notes/cc900-phase6-2026-11-16/HANDOFF-2026-11-20.md (each old label's bytes equal v7's at the v7 label,
# 5..48 B, unique in the v6 / v5 ROM; the FDC pair by identical offsets of their Skip / Epilogue neighbours).
# Apply: sed -i -f scripts/renaming/rename_v6v5_semenu_fdc_callees.sed v6/maincpu/<files> v5/maincpu/<files>
s/\bSeMenu_ApplyPartEdit_Helper7\b/SeMenu_DrawPitFilEnvGraph/g
s/\bSeMenu_ApplyPartEdit_Helper12\b/SeMenu_DrawKeyScaleGraph/g
s/\bSeMenu_ApplyPartEdit_Join6\b/SeMenu_ApplyPartEdit_AltStore_Join21/g
s/\bSeMenu_RefreshPartDisplay_Data_2\b/SeMenu_StepParamField/g
s/\bSeMenu_CopyWriteUpdate_Helper15\b/SeMenu_CopyWriteUpdate_Step3_Helper14/g
s/\bFDC_HardwareSetup_Helper3\b/FDC_SendAuxCmd/g
s/\bFDC_HardwareSetup_Helper5\b/FDC_ValidateOpcode/g
# located by port_staged.py from the call operands of staged functions whose other bytes match (2026-11-20);
# the first 12 bytes at each label equal v7's except address operands
s/\bFDC_HardwareSetup_Helper6\b/FDC_SendParams_Specify/g
# (2026-11-21, FDC_CMD_SEND's last unlabelled callee in v6 / v5: find_counterparts.py, two runs of v10's bytes,
# +12:16 and +39:9, agree on this start; v7 already has the name at the same place)
# (2026-11-21, the next two: look-alikes of FDC_SendParams_Specify, so no unique bytes; placed by offsets, the same
# in v10, v7, v6 and v5: Specify + 0x36 = Format, Format + 0x27 = SeekTrack)
s/\bFDC_HardwareSetup_Helper7\b/FDC_SendParams_Format/g
s/\bFDC_HardwareSetup_Helper8\b/FDC_SendParam_SeekTrack/g
s/\bMidiSeq_PartLookup_Data\b/MidiPkt_XferShowResult/g
s/\bMidiSeq_PartConfigure_Data\b/MidiTable_PreDispatchNullRet/g
s/\bSeMenu_CopyWriteUpdate_Helper11\b/SeMenu_GetEntryCount/g
s/\bSeMenu_CopyWriteUpdate_Helper9\b/SeMenu_GetToneIndex/g
