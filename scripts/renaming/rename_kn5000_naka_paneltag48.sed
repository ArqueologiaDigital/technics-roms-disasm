# Lane open11/kn5000-naka (2026-11-06): PanelTag48_UpdateAudioConfig's switch (ParamEdit_SwitchOffsets,
# indexed by SWBTWR_PAYLOAD_1, the changed byte of record 0x48) sends entries 0-2 to the epilogue and
# entry 3 to the label that was called _StyleNumber; that arm reads PANEL_STYLE+3 (APC memory / mode)
# and writes AUDIO_CONFIG_FLAGS bits 0-2 / 4.  It is the APC-mode arm (notes/NEXT-STEPS-2026-10-17.md
# had said so).  Prefix rule: its _Skip / _Join labels follow.
s/; PanelTag48_UpdateAudioConfig_StyleNumber: Offset 0 of record 0x48 (the style number; also the switch base): when/; PanelTag48_UpdateAudioConfig_ApcMode: Offset 3 of record 0x48 (PANEL_STYLE+3, APC memory \/ mode; also the switch base): when/
s/\bPanelTag48_UpdateAudioConfig_StyleNumber/PanelTag48_UpdateAudioConfig_ApcMode/g
