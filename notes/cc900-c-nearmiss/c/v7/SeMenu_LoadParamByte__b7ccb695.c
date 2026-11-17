/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/semenu_routines.c (2026-11-16-55-p6-r10)
   sha256 b7ccb695e706fbb3799e336e9b9e5e86f1efe41c8679fcbddf815f81b28a3eb5 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_6ba[];
void SeMenu_LoadParamByte(unsigned char n, unsigned char *out)
{
	*out = ram_6ba[(unsigned char)(n - 1)];
}
