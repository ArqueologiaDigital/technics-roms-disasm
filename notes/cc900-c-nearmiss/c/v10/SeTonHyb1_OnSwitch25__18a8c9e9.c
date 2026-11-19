/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_12m152a.c (2026-11-19-76-p6-r55)
   sha256 18a8c9e99c16f85e523dbca0dca71027b3a818f4bb8f9c3df561baafca33f13b (tar-sha256); compiled at -Xr */
#define TT_SETONTON1 0x22
#define TT_SETONTON2 0x23
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
void SeTonHyb1_OnSwitch25(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1) {
		if (a == 0)
			SeMenu_SendEvent(TT_SETONTON2, 0);
		else
			SeMenu_SendEvent(TT_SETONTON1, 0);
	}
}
