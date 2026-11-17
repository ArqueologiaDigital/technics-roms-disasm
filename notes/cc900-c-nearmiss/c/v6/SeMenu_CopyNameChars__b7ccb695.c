/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/semenu_routines.c (2026-11-16-45-p6-r9)
   sha256 b7ccb695e706fbb3799e336e9b9e5e86f1efe41c8679fcbddf815f81b28a3eb5 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
void SeMenu_CopyNameChars(unsigned char *d, unsigned char *s, unsigned char n)
{
	unsigned char i;

	for (i = 0; i < n; i++) *d++ = *s++;
}
