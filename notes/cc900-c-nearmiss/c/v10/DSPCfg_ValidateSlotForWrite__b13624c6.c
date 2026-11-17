/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_2b.c (2026-11-16-35-p6-r3)
   sha256 b13624c69fcb835af433e38ef56581fa94d5aa79da286905b3f16a25d5e2a17d (tar-sha256); compiled at -Xr */
extern void *DspFxRecListPtrTable[];
int DSPCfg_ValidateSlotForWrite(unsigned int a, int s)
{
	if (a > 0x63) return -1;
	if (DspFxRecListPtrTable[a] == 0) return -1;
	switch (s) {
	case 0:
		if (a < 0x10 || a > 0x1b) goto ok;
		return -1;
	case 1:
		if (a == 9 || a == 10) goto ok;
		if (a < 0x10 || a > 0x1b) return -1;
		goto ok;
	case 2:
		if (a < 0x39 || a > 0x3c) return -1;
		goto ok;
	case 3:
		if (a < 0x58 || a > 0x5b) return -1;
		goto ok;
	case 4:
		if (a != 0x4f) return -1;
		goto ok;
	default:
		return -1;
	}
ok:
	return 0;
}
