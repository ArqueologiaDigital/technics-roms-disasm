/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_5a.c (2026-11-16-45-p6-r9)
   sha256 0a24d3abb3ad01135d3ba1544257bdeae1dc14fc21da9794d409ad64bba47312 (tar-sha256); compiled at -Xr */
extern long ApPostEvent(long, long, long);
extern long StorageArea_NameTable[], StorageArea_UnitNames[], SingleLoad_BankCaptionByMode[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern long __near ram_81b6;
long SingleLoadModeFunc(long a, long evt, long p)
{
	switch (evt) {
	case 0x1e50004L:
		ram_81b6 = p;
		break;
	case 0x1c0000bL:
		ApPostEvent(ram_81b6, 0x1c0000fL, StorageArea_NameTable[SINGLE_LOAD_AREA]);
		break;
	}
	return 0;
}
