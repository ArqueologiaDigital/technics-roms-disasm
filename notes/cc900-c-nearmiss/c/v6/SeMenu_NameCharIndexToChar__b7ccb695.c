/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/semenu_routines.c (2026-11-16-55-p6-r10)
   sha256 b7ccb695e706fbb3799e336e9b9e5e86f1efe41c8679fcbddf815f81b28a3eb5 (tar-sha256); compiled at -O3 -Xr
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
