/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/graphics_text_vga_m274_xs.c (2026-11-16-92-p6-r18)
   sha256 f5c5ed3871a8a0d18c1465aae67d329af86c467670a6518277bd90fce2b3c8d2 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -XS -Xr */
extern unsigned char Text_CharGlyphMap[], SysEx49_LevelCurve128[], SysEx49_VoiceIndexMap8[], DEMO_CURRENT_SONG;
void FontGlyph_ByteData(unsigned char *s, unsigned char *d) { *d = Text_CharGlyphMap[*s]; }
