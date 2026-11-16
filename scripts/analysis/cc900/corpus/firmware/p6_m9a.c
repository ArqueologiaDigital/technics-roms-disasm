/* Phase 6, probe m9 (form a): larger leaf functions of v10 (graphics_text_vga.s, dsp_config_sysex.s,
   file_demo_proc.s, seq_event_playback.s), each under its firmware name (Read/Write_VGA_Register are the ROM's
   _Read/_Write_VGA_Register).  The reference model refuses most of them (indexing through a constant pointer,
   an array used as a pointer) or picks other registers; V4.23 is asked which C gives the ROM's bytes. */
extern unsigned char Text_CharGlyphMap[], SysEx49_LevelCurve128[], SysEx49_VoiceIndexMap8[], DEMO_CURRENT_SONG;
extern long Palette_8bit_RGBA[];
extern unsigned int ram_272cc, ram_272ce, DEMO_ACTIVE_ENTRY, DemoSong_EntryCol[];
extern long *PART_RECORD_PTRS;
void SetPaletteRGB(int i, long rgb) { ((long *)0x324fc)[i] = rgb; }
long Table_LookupDword(int i) { return ((long *)0x324fc)[i]; }
unsigned char Read_VGA_Register(unsigned int r) { return *(unsigned char *)(0x170000 + r); }
void Write_VGA_Register(unsigned int r, unsigned char v) { int d = 0; do d++; while (d < 0x80); *(unsigned char *)(0x170000 + r) = v; }
void FontGlyph_ByteData(unsigned char *s, unsigned char *d) { *d = Text_CharGlyphMap[*s]; }
void InitPaletteRGB(void) { long *d = (long *)0x324fc; long *s = Palette_8bit_RGBA; long *e = s + 256; do *d++ = *s++; while (s < e); }
unsigned char SysEx_ClampVoiceIndex128_49(unsigned char a) { if (a >= 0x80) a = 0; return SysEx49_LevelCurve128[a]; }
unsigned char SysEx_ClampVoiceIndex8_49(unsigned char a) { if (a >= 0x8) a = 0; return SysEx49_VoiceIndexMap8[a]; }
void FileIO_BuildRecordPath_Done(unsigned char a) { if (a < 10) ram_272ce |= 1 << a; }
void FileIO_FormatName_Loop(unsigned char a) { if (a < 10) ram_272cc |= 1 << a; }
void FileIO_BuildRecordPath_Return(unsigned char a) { if (a < 10) ram_272ce &= ~(1 << a); }
void FileIO_FormatName_Copy(unsigned char a) { if (a < 10) ram_272cc &= ~(1 << a); }
long Demo_LookupPartTableEntry(unsigned char i) { return PART_RECORD_PTRS[i]; }
void Demo_SelectEntry_LoadPattern(void) { DEMO_ACTIVE_ENTRY = DemoSong_EntryCol[DEMO_CURRENT_SONG]; }
void AccPlay_ClearSlotTable(void) { unsigned char *p = (unsigned char *)0x7e7b; for (;;) { *p = 0; p += 9; if (p == (unsigned char *)0x7f0b) break; } }
