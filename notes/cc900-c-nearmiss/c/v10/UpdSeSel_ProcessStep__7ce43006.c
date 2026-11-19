/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_2m131a.c (2026-11-19-19-p6-r43)
   sha256 7ce430065c20598ead18e06080627dbb8c1fe17d7423453c19307b4f568dc716 (tar-sha256); compiled at -Xr */
#define TT_DRAWBAR 0xea
extern void SeMenu_ReadObjData(unsigned char *d);
extern void SeMenu_SetDisplayState(int v);
extern int SeMenu_RegisterElement_Type1(int a, int c, int e, int s);
extern void SeMenu_SetCurrentStep(int v);
extern int SeMenu_CheckObjEnabled(int a);
extern int SeMenu_CheckObjValid(int a);
extern void SeMenu_FillEntryTable(unsigned char *t);
extern void SeMenu_SetMode(int v);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_LoadObjEntries(unsigned char *obj);
extern void UpdSeSel_DetailedUpdate(void);
extern void UpdSeSel_SimpleUpdate(void);
void UpdSeSel_ProcessStep(void)
{
	unsigned char obj;
	unsigned char d;
	unsigned char t[16];

	SeMenu_ReadObjData(&d);
	if (d == 0) {
		SeMenu_SetDisplayState(1);
		SeMenu_RegisterElement_Type1(0, 16, 1, 32);
		SeMenu_SetCurrentStep(1);
		return;
	}
	if (d == 1) {
		if (SeMenu_CheckObjEnabled(0x81) != 0 || SeMenu_CheckObjValid(16) != 0) {
			SeMenu_SetCurrentStep(16);
			SeMenu_SetDisplayState(0);
			return;
		}
		SeMenu_FillEntryTable(t);
		t[0] &= 0xc0;
		if (t[0] == 0x80) {
			SeMenu_SetMode(1);
			SeMenu_SetCurrentStep(2);
		} else if (t[0] == 0x40) {
			SeMenu_SetMode(2);
			SeMenu_SendEvent(TT_DRAWBAR, 0);
			SeMenu_SetCurrentStep(0);
			SeMenu_SetDisplayState(0);
			return;
		} else {
			SeMenu_SetMode(0);
			SeMenu_SetCurrentStep(2);
		}
	}
	SeMenu_LoadObjEntries(&obj);
	if (obj == 1)
		UpdSeSel_DetailedUpdate();
	else
		UpdSeSel_SimpleUpdate();
}
