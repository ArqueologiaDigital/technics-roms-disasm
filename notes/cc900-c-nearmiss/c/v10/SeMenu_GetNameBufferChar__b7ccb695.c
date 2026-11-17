/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/semenu_routines.c (2026-11-16-55-p6-r10)
   sha256 b7ccb695e706fbb3799e336e9b9e5e86f1efe41c8679fcbddf815f81b28a3eb5 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char ram_20c39[], ram_20bf3[];
void SeMenu_GetNameBufferChar(unsigned char i, unsigned char *out)
{
	if (i > 15) return;
	*out = ram_20bf3[i];
}
