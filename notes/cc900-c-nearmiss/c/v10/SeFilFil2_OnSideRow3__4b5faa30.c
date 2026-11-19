/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_10m128e.c (2026-11-19-68-p6-r52)
   sha256 4b5faa3085fd6d7f5a7b1e0cf97ee3637adc1926897ee625b2d2344779d223df (tar-sha256); compiled at -Xr */
#define TT_SEFILFIL2 0x36
#define TT_SEFILLFO1 0x39
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
void SeFilFil2_OnSideRow3(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEFILLFO1, 0);
	else if (SeMenu_SelectPartIfEnabled(2) != 0)
		SeMenu_SendEvent(TT_SEFILFIL2, 1);
}
