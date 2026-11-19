/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_13m152a.c (2026-11-19-83-p6-r56)
   sha256 79096ce836227de2ba8486e9940bda9297d86c4371b139b1283c81267b96f5ef (tar-sha256); compiled at -Xr */
#define TT_SECTR2    0x3b
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeCtr2_SetSelection(int);
void SeCtr2_OnSideRow3(unsigned char a)
{
	unsigned char v;

	SeMenu_LoadPartParam(0, &v);
	if (a == 0) {
		if (v == 6)
			return;
		SeCtr2_SetSelection(6);
	} else {
		if (v == 5)
			return;
		SeCtr2_SetSelection(5);
	}
	SeMenu_SendEvent(TT_SECTR2, 1);
}
