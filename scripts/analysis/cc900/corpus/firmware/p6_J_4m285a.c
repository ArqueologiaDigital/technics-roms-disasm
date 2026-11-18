/* Phase 6, lane_p6 helper J, round 4, module 285 (midi/midi_dispatch_handlers.s, -O3 -Xr), form a:
   SndParam_AllocAndCopyPreset.  Copy the 0xea-byte factory preset bank to a Malloc'd buffer, refresh its two
   record tables (23 six-byte records from +0 whose +4 / +5 bytes are read through the record's pointer, then 16
   from +138 whose +5 byte is +4 masked by the pointed byte), clear +216 when no preset is selected, and write it to
   flash bank 0..2 (0x3d3010 / 0x3d3110 / 0x3d3210); Free runs on every path (also with a 0 buffer).
   Loops as do-while (the ROM has no entry test); the bank switch compares 2, 1, 0 (last case first). */

extern unsigned char *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern unsigned char SndParam_PresetBanks[];
extern unsigned char MainMpst_ReadPresetIndex(void);
extern void FlashWrite(int, unsigned char *, unsigned int, long);

void SndParam_AllocAndCopyPreset(unsigned char bank)
{
	unsigned char *p;
	unsigned char *r;
	unsigned char *e;
	unsigned char *s;

	p = Malloc(0xea);
	if (p != 0 && bank < 3) {
		Mem_Copy(p, SndParam_PresetBanks, 0xea);
		r = p + 5;
		e = r + 138;
		do {
			s = *(unsigned char **)(r - 5);
			r[-1] = *s++ & 7;
			r[0] = *s;
			r += 6;
		} while (r < e);
		r = p + 143;
		e = r + 96;
		do {
			s = *(unsigned char **)(r - 5);
			r[0] = r[-1] & *s;
			r += 6;
		} while (r < e);
		if (MainMpst_ReadPresetIndex() == 0)
			*(long *)(p + 216) = 0;
		switch (bank) {
		case 0:
			FlashWrite(1, p, 0xea, 0x3d3010L);
			break;
		case 1:
			FlashWrite(1, p, 0xea, 0x3d3110L);
			break;
		case 2:
			FlashWrite(1, p, 0xea, 0x3d3210L);
			break;
		}
	}
	Free(p);
}
