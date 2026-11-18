/* Phase 6, lane_p6 helper J, round 4, module 285, form b: SndParam_AllocAndCopyPreset with for loops and the
   failure tests as early gotos to the Free. */

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
	unsigned char *s;

	p = Malloc(0xea);
	if (p == 0)
		goto out;
	if (bank >= 3)
		goto out;
	Mem_Copy(p, SndParam_PresetBanks, 0xea);
	for (r = p + 5; r < p + 143; r += 6) {
		s = *(unsigned char **)(r - 5);
		r[-1] = *s++ & 7;
		r[0] = *s;
	}
	for (r = p + 143; r < p + 239; r += 6) {
		s = *(unsigned char **)(r - 5);
		r[0] = r[-1] & *s;
	}
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
out:
	Free(p);
}
