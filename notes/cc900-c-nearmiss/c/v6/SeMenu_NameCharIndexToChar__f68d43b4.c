/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/semenu_routines_m129.c (2026-11-16-68-p6-r12)
   sha256 f68d43b44849ec6bedb9d46fb202fad6b3db6f0029532ac3d9345c18c0eb571e (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char GUI_DisplayStructData_0x1129[];
void SeMenu_NameCharIndexToChar(unsigned char c, unsigned char *out)
{
	if (c >= 97) {
		*out = 32;
		return;
	}
	*out = GUI_DisplayStructData_0x1129[c];
}
