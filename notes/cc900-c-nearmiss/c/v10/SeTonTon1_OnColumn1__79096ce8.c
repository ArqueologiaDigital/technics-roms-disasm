/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_13m152a.c (2026-11-19-83-p6-r56)
   sha256 79096ce836227de2ba8486e9940bda9297d86c4371b139b1283c81267b96f5ef (tar-sha256); compiled at -Xr */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_SetupMenuDisplay(int mode);
extern int SeMenu_IsPartEnabled(int);
extern void SeMenu_SetPartEnabled();
void SeTonTon1_OnColumn1(unsigned char a)
{
	unsigned char p;
	unsigned char flag;

	SeMenu_LoadPartParam(0, &p);
	flag = a & 0x7f;
	if (SeMenu_IsPartEnabled(p) != 0) {
		if (flag == 0)
			return;
		SeMenu_SetPartEnabled(p, 0);
	} else {
		if (flag != 0)
			return;
		SeMenu_SetPartEnabled(p, 1);
	}
	SeTitle_DrawField(34, 1);
	SeMenu_SetupMenuDisplay(1);
}
