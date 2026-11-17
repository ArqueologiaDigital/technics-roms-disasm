/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sprintf_core_m310.c (2026-11-16-68-p6-r12)
   sha256 d44c2985071f7168975c661014e576cca03f33a348113fe02a42ab5a3f11a2c8 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
char *__cdecl Sprintf_OctalToStr(char *p, unsigned long v)
{
	char *q;

	do {
		q = p++;
		*q = (char)((v & 7) + 0x30);
		v >>= 3;
	} while (v != 0);
	*p = 0;
	return p;
}
