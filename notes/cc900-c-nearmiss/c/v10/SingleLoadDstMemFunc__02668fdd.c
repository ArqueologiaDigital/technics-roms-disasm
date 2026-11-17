/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_5b.c (2026-11-16-45-p6-r9)
   sha256 02668fddc4a7ae9f0dcae741aab0cb2afb9cebcd20d58654e0aa4bfa1965ed0a (tar-sha256); compiled at -O3 -Xr */
extern long ApPostEvent(long, long, long);
extern long StorageArea_NameTable[], StorageArea_UnitNames[], SingleLoad_BankCaptionByMode[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SINGLE_LOAD_ALL;
extern long __near ram_81be;
long SingleLoadDstMemFunc(long a, long evt, long p)
{
	long o, *t, v;

	switch (evt) {
	case 0x1e50004L:
		ram_81be = p;
		break;
	case 0x1c0000bL:
		o = ram_81be;
		t = StorageArea_UnitNames;
		if (SINGLE_LOAD_ALL != 0 && SINGLE_LOAD_AREA != 1) v = t[4];
		else v = t[SINGLE_LOAD_AREA];
		ApPostEvent(o, 0x1c0000fL, v);
		break;
	}
	return 0;
}
