/* Phase 6, probe m9 (form b): larger leaf functions of v10 (graphics_text_vga.s, dsp_config_sysex.s,
   file_demo_proc.s, seq_event_playback.s), each under its firmware name (Read/Write_VGA_Register are the ROM's
   _Read/_Write_VGA_Register).  The reference model refuses most of them (indexing through a constant pointer,
   an array used as a pointer) or picks other registers; V4.23 is asked which C gives the ROM's bytes. */
extern unsigned char Text_CharGlyphMap[], SysEx49_LevelCurve128[], SysEx49_VoiceIndexMap8[], DEMO_CURRENT_SONG;
extern long Palette_8bit_RGBA[];
extern unsigned int ram_272cc, ram_272ce, DEMO_ACTIVE_ENTRY, DemoSong_EntryCol[];
extern long *PART_RECORD_PTRS;
void SetPaletteRGB(int i, long rgb) { long *p = (long *)0x324fc; p[i] = rgb; }
long Table_LookupDword(int i) { long *p = (long *)0x324fc; return p[i]; }
unsigned char Read_VGA_Register(unsigned int r) { unsigned char *p = (unsigned char *)0x170000; return p[r]; }
void Write_VGA_Register(unsigned int r, unsigned char v) { int d = 0; unsigned char *p; while (++d < 0x80) ; p = (unsigned char *)0x170000; p[r] = v; }
void FontGlyph_ByteData(unsigned char *s, unsigned char *d) { unsigned char c = *s; *d = Text_CharGlyphMap[c]; }
void InitPaletteRGB(void) { long *d = (long *)0x324fc; long *s; for (s = Palette_8bit_RGBA; s < Palette_8bit_RGBA + 256; ) *d++ = *s++; }
unsigned char SysEx_ClampVoiceIndex128_49(unsigned char a) { return SysEx49_LevelCurve128[a < 0x80 ? a : 0]; }
unsigned char SysEx_ClampVoiceIndex8_49(unsigned char a) { return SysEx49_VoiceIndexMap8[a < 0x8 ? a : 0]; }
void FileIO_BuildRecordPath_Done(unsigned char a) { unsigned int b = 1; if (a >= 10) return; b <<= a; ram_272ce |= b; }
void FileIO_FormatName_Loop(unsigned char a) { unsigned int b = 1; if (a >= 10) return; b <<= a; ram_272cc |= b; }
void FileIO_BuildRecordPath_Return(unsigned char a) { unsigned int b = 1; if (a >= 10) return; b <<= a; ram_272ce &= ~b; }
void FileIO_FormatName_Copy(unsigned char a) { unsigned int b = 1; if (a >= 10) return; b <<= a; ram_272cc &= ~b; }
long Demo_LookupPartTableEntry(unsigned char i) { return *(PART_RECORD_PTRS + i); }
void Demo_SelectEntry_LoadPattern(void) { unsigned int i = DEMO_CURRENT_SONG; DEMO_ACTIVE_ENTRY = DemoSong_EntryCol[i]; }
void AccPlay_ClearSlotTable(void) { unsigned char *p; for (p = (unsigned char *)0x7e7b; p != (unsigned char *)0x7f0b; p += 9) *p = 0; }
