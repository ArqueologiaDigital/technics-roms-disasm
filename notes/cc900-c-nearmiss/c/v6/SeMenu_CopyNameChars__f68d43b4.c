/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/semenu_routines_m129.c (2026-11-16-68-p6-r12)
   sha256 f68d43b44849ec6bedb9d46fb202fad6b3db6f0029532ac3d9345c18c0eb571e (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
void SeMenu_CopyNameChars(unsigned char *d, unsigned char *s, unsigned char n)
{
	unsigned char i;

	for (i = 0; i < n; i++) *d++ = *s++;
}
