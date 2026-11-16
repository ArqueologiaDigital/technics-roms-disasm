/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/dsp_config_sysex_m290_xs.c (2026-11-16-92-p6-r18)
   sha256 77e0ac35465b705afdfc57ebb8bf6762a2bfc99d1082db7648a84d5ad23c6062 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -XS -Xr */
extern unsigned char Text_CharGlyphMap[], SysEx49_LevelCurve128[], SysEx49_VoiceIndexMap8[], DEMO_CURRENT_SONG;
unsigned char SysEx_ClampVoiceIndex128_49(unsigned char a) { if (a >= 0x80) a = 0; return SysEx49_LevelCurve128[a]; }
