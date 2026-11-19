/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_13m152a.c (2026-11-19-83-p6-r56)
   sha256 79096ce836227de2ba8486e9940bda9297d86c4371b139b1283c81267b96f5ef (tar-sha256); compiled at -O3 -Xr */
extern void SeWrtSnd_ClearName_Join(void);
void SeWrtSnd_OnSideRow2(unsigned char a)
{
	if (a == 0)
		SeWrtSnd_ClearName_Join();
}
