/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m9a.c (2026-11-16-22-p6-m9)
   sha256 d82be9969bfcff2f1bb280e2fa82aeed8573c9916cec0bb8d50ccc60ae4d54b0 (name+funcs); compiled at -O3 -XS -Xr */
extern unsigned char Text_CharGlyphMap[], SysEx49_LevelCurve128[], SysEx49_VoiceIndexMap8[], DEMO_CURRENT_SONG;
void FontGlyph_ByteData(unsigned char *s, unsigned char *d) { *d = Text_CharGlyphMap[*s]; }
