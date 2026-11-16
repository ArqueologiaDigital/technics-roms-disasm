/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m9b.c (2026-11-16-22-p6-m9)
   sha256 5061182033df816bd8c38592a9bae7f8131de911549bf9c89a81971297466b2d (name+funcs); compiled at (no flags) */
extern unsigned char Text_CharGlyphMap[], SysEx49_LevelCurve128[], SysEx49_VoiceIndexMap8[], DEMO_CURRENT_SONG;
unsigned char SysEx_ClampVoiceIndex8_49(unsigned char a) { return SysEx49_VoiceIndexMap8[a < 0x8 ? a : 0]; }
