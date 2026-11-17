# Voice_ComputePitch_InlineData is code: the 17 bytes after Voice_ComputePitch's ret are a signed clamp
# (WA value, BC high, DE low), a twin of Int_ClampSignedToRange; V4.23 reproduces it from C (run
# 2026-11-16-126-sub-r17, sub_Q_17a).  Apply to v14[0-2]/subcpu/core/06_voice_envelopes_and_channels.s and the
# C that names it; the symbols reference files are regenerated (l2_symbol_reference.py --regen).
s/\bVoice_ComputePitch_InlineData\b/Int_ClampSignedToRange_B/g
