# rename_panel.sed -- label renames found by sub-lane open6-kn5000-d/panel (2026-11-02); not applied by the
# sub-lane.  Apply to every maincpu tree that has the names (v10, v9, v7, v6, v5) and the symbol files:
#   sed -i -E -f notes/open6-kn5000-d/panel/rename_panel.sed <files>
#
# MIDI_DistributeParamToChannels (A = part, C = group, E = slot) stores companion[group] = slot in the part's
# companion (VARI) record (PanelTlv_CompanionOfPart); MainVariSet (EVT_VARI_WRITE) and Sound_SetSelection call it.
s/\bMIDI_DistributeParamToChannels\b/PanelVari_SetGroupSlot/g
# VoiceData_DistributeToChannels (A = part, C = group) returns L = companion[group]; PanelButton_SoundGroup and
# PanelButton_RhythmGroup (part 72 -> tag 0x49) call it to recall the group's last sound / style.
s/\bVoiceData_DistributeToChannels\b/PanelVari_GetGroupSlot/g
s/\bVoiceData_DistributeToChannels_Join\b/PanelVari_GetGroupSlot_Join/g
s/\bVoiceData_DistributeToChannels_Skip\b/PanelVari_GetGroupSlot_Skip/g
s/\bVoiceData_DistributeToChannels_Entry\b/PanelVari_GetGroupSlot_Rhythm/g
s/\bVoiceData_DistributeToChannels_Skip2\b/PanelVari_GetGroupSlot_NoRecord/g
s/\bVoiceData_DistributeToChannels_Epilogue\b/PanelVari_GetGroupSlot_Epilogue/g
# VoiceData_RamBlockPtrs: the 16 RAM addresses 0xFDDA + 0x14 i are the companion (VARI) records of parts 0..15
# (tags 0xC0..0xCF, ram_panel_records.s PANEL_VARI_RT1 ..), cleared by VoiceData_ZeroFillAll.
s/\bVoiceData_RamBlockPtrs\b/PanelVari_PartRecordPtrs/g
# SeMenu_TransferPartValues (A = LFO kind 0 AMP / 1 PITCH / 2 FILTER, C = LFO 1..4) stores in (XDE) the tone
# record offset of that LFO's 4-byte entry, 0x3B / 0x2B / 0x4B + 4 (C - 1): the edit element the LFO pages send.
s/\bSeMenu_TransferPartValues\b/SeLfo_GetEntryElement/g
# SeMenu_TransferPartValues_EndData (A = LFO kind) stores in (XBC) the page's selected LFO number (RAM 0x68D /
# 0x68E / 0x68F), forcing it into 1..4.
s/\bSeMenu_TransferPartValues_EndData\b/SeLfo_GetSelectedLfo/g
# (added 2026-11-02, second pass) The CONTROLLER page's request helpers (audio/semenu_routines.s,
# audio/sound_editor_ui.s).  UpdSeSel_DetailedUpdate_SetDisplayState_Helper stores the page's remembered selection
# (RAM 0x695) clamped into 1..6, default 1.
s/\bUpdSeSel_DetailedUpdate_SetDisplayState_Helper\b/SeCtr2_GetSelection/g
# ..._Helper2 maps selection 1 / 2 / 5 / 6 to the sound record's controller-group base 0x17 / 0x1A / 0x23 / 0x26.
s/\bUpdSeSel_DetailedUpdate_SetDisplayState_Helper2\b/SeCtr2_GetGroupBase/g
# ..._Helper3 is its drum-kit twin: 0x15 / 0x18 / 0x21 / 0x24 in the kit-instrument layout.
s/\bUpdSeSel_DetailedUpdate_SetDisplayState_Helper3\b/SeCtr2_GetKitGroupBase/g
# UpdSeSel_DetailedUpdate_Helper5 requests the six FUNCTION bytes 0x18 + 3 k and the selected group's DEPTH and tone
# switches, and stores the group base in page param 13; _Helper6 does the same for a drum kit (0x16 + 3 k).
s/\bUpdSeSel_DetailedUpdate_Helper5\b/SeCtr2_RequestGroupValues/g
s/\bUpdSeSel_DetailedUpdate_Helper5_Loop\b/SeCtr2_RequestGroupValues_Loop/g
s/\bUpdSeSel_DetailedUpdate_Helper6\b/SeCtr2_RequestKitGroupValues/g
s/\bUpdSeSel_DetailedUpdate_Helper6_Loop\b/SeCtr2_RequestKitGroupValues_Loop/g
