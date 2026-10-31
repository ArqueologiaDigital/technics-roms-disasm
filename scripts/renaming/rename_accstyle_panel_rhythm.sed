# AccStyle_VelocityTableMain / _Ext / _High hold no velocities: AccStyle_LookupVelocityTable maps the selected
# (program 0x90ea, bank 0x90eb) to the panel's (rhythm group 0x90ee, number 0x90ef), which
# RhythmROM_PatternDisp_Handle90 / SndParam_ResolveVoiceEntry pass to AccVoice_DispatchEntry as L = group,
# H = number (notes/rhythm-data-ic14-2026-10-29/README.md, "The names the panel shows"; open item N-ec33691a).
s/\bAccStyle_VelocityTableHigh_Tail\b/AccStyle_PanelRhythmTable_High_Tail/g
s/\bAccStyle_VelocityTableHigh\b/AccStyle_PanelRhythmTable_High/g
s/\bAccStyle_VelocityTableExt\b/AccStyle_PanelRhythmTable_Ext/g
s/\bAccStyle_VelocityTableMain\b/AccStyle_PanelRhythmTable/g
s/\bAccStyle_LookupVelocityTable\b/AccStyle_LookupPanelRhythm/g
s/\bAccStyle_Velocity_ExtendedRange\b/AccStyle_LookupPanelRhythm_Ext/g
s/\bAccStyle_Velocity_ExtClamp\b/AccStyle_LookupPanelRhythm_ExtClamp/g
s/\bAccStyle_Velocity_HighRange\b/AccStyle_LookupPanelRhythm_High/g
s/\bAccStyle_Velocity_HighClamp\b/AccStyle_LookupPanelRhythm_HighClamp/g
s/\bAccStyle_Velocity_StoreResult\b/AccStyle_LookupPanelRhythm_Store/g
