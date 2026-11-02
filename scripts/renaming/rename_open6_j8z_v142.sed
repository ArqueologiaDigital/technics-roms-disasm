# kn5000-j8z, lane open6/kn5000-d naming (2026-11-02): sub-CPU payload v1.42 (v141 / v140 are regenerated from it
# by scripts/generators/create_v141_subcpu_source.py and create_v140_subcpu_source.py).
# Voice_PanReg_WriteDispatchB is TVF_Emit_Registers' twin for the type-2 voices (class (voice+1) & 0x3c = 0x10,
# TVF_Refresh_Sounding_Voices; Voice_Init_Type2): same six cases, the mode from (tonerec+0x0f) & 7 instead of
# (tonerec+0x36) & 7, same staging words 0x0451D4 / 0x0451D6 (TG 0x100 / 0x140, the TVF pair).
s/\bVoice_PanReg_WriteDispatchB/TVF_Emit_Registers_Type2/g
s/\bVoice_PanReg_DispatchB_Mode5_/TVF_Emit_Registers_Type2_Mode5_/g
# The inline case-5 arms of TVF_Emit_Registers itself.
s/\bVoice_PanReg_Dispatch_Mode5_/TVF_Emit_Registers_Mode5_/g
