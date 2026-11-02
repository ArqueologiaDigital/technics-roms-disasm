# Voice_Slot_ApplyPitchJitter (v142 0x02B3C0; only caller Voice_Init_Type1, 0x02C3CC) adds (tick & 7) to the word at
# 0x0451CE, which the ToneGen_StagingBlock banner (v142 core/05_voice_params_and_tvf.s) maps to TG register
# +0x040, the recording selector (class << 12 | entry) -- not to a pitch.  The effect is a random choice of
# one of 8 consecutive directory entries; IC307 page 2 has exactly such 8-entry groups at the nine Organ
# Click selectors 0x6028..0x6068 (notes/open6-kn5000-d/misc/README.md section 4, probe
# probes/ic307_unselected_entries.py).  Apply to v142/v141/v140 sources, symbols/subcpu*_symbols_reference.txt.
s/\bVoice_Slot_ApplyPitchJitter\b/WaveSel_AddRandomEntryOffset/g
