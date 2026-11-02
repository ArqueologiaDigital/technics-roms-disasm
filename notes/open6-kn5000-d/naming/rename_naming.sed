# APPLIED 2026-11-02 by the lane lead in commit 5a5311c56 (see notes/open6-kn5000-d/README.md).
# Renames for files this sub-lane does not own (lane open6/kn5000-d, naming, 2026-11-02).  For the lead to apply
# serially.  The labels themselves were renamed in v10/v9/v7/v6/v5 (scripts/renaming/rename_open6_*.sed); these
# rules fix the prose / generated comments elsewhere that quote the old names.
#
# --- kn5000-j8z.  Files: table_data/panel_memory_presets.s (header + 80 record comments),
#     hdae5000/shared/event_codes.s, hdae5000_v1_15i/shared/event_codes.s (EVT_EXIT_PRESENTATION comment),
#     scripts/generators/gen_msp_factory_defaults_c.py (generates v*/maincpu/msp_factory_defaults.c; its output
#     was already changed by sed), floppy/kn5000/formats.py (then regenerate the .TM.s sources).
# Evidence: PanelMem_InitAllFromFactory / PanelMem_InitFromFactory build the 80 panel memories from table data
# 0x99EC00 / 0x99ECA0 (notes/open6-kn5000-d/naming/README.md, kn5000-j8z).
s/\bDisplay_CopyAndRenderBitmaps\b/PanelMem_InitAllFromFactory/g
s/\bVoiceData_InitAndCopyParams\b/PanelMem_InitFromFactory/g
# SeqSong_ResetAll re-initialises song slots 0..10 (INITIAL SETTING SEQUENCER).
s/\bPart_InitFromPreset\b/SeqSong_ResetAll/g
# MspUser_InitFromFactory fills the accompaniment block area 0x1E8800 (INITIAL SETTING MSP USER).
s/\bVoice_InitBankData\b/MspUser_InitFromFactory/g
# SoundRam_InitFuncTable slot 0: KN5000 SOUND RAM image check + bulk transfer.
s/\bSendPartDataBlock_ClearByte4\b/SoundRam_InitPhase0_SendImage/g
#
# --- kn5000-rld.  Files: v10/v9/v7/v6/v5 maincpu ui_widgets/naka_widget_tables_2.s and .c (label + C struct
#     field + comment), factory_test/fd_test_data.s (the .long), ui_widgets/naka_style_bitmaps.c and
#     naka_widget_tables_2.c (comments quoting names later lanes replaced; same addresses, symbols files).
# 4 zero bytes, the text pointer of FDTest_Group_OnOff (PsEditSwBox, ES_Bottom2): an empty string.
s/\bNakaToggle_OnOff_Data\b/FDTest_Group_OnOff_EmptyText/g
s/\bExitWindow_OK_Data_2\b/SupportClass_PropTypeRecords/g
s/\bMasterSetup_EventDispatch_Data\b/StyleSong_MasterTable_IdColumn/g
s/\bMasterSetup_DialTurn_Underflow_Data\b/StyleSong_MasterTable_LastEntry/g
s/\bMidiPart_PageDisplay_Data\b/MidiSetup_PageIndicatorRect/g
