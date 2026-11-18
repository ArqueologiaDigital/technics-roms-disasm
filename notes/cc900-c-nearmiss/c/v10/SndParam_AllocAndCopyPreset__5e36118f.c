/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_4m285a.c (2026-11-18-33-p6-r37)
   sha256 5e36118f764ac200e39c492d5df01f45323ce4dc803f9a6b5452cfe1620c0ce9 (tar-sha256); compiled at -O3 -Xr */
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
