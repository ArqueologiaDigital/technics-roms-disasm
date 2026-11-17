/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/semenu_routines.c (2026-11-16-55-p6-r10)
   sha256 b7ccb695e706fbb3799e336e9b9e5e86f1efe41c8679fcbddf815f81b28a3eb5 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
unsigned char SeMenu_BitShiftMask_End(unsigned char a, unsigned char n)
{
	unsigned char r = a;
	unsigned int i;

	for (i = 0; i < n; i++) r >>= 1;
	return r;
}
