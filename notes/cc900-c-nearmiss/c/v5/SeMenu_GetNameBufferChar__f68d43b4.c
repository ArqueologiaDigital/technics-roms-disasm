/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/semenu_routines_m129.c (2026-11-16-68-p6-r12)
   sha256 f68d43b44849ec6bedb9d46fb202fad6b3db6f0029532ac3d9345c18c0eb571e (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char ram_20c39[], ram_20bf3[];
void SeMenu_GetNameBufferChar(unsigned char i, unsigned char *out)
{
	if (i > 15) return;
	*out = ram_20bf3[i];
}
