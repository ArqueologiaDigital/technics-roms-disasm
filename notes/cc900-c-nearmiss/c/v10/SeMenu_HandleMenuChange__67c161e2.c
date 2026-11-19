/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_1m129a.c (2026-11-19-15-p6-r42)
   sha256 67c161e25dfdbf9eb6d31ace3b1df1a2d2c1933e524fb9780054924a984863ac (tar-sha256); compiled at -O3 -XS -Xr */
#define TT_SQDRMEDT 0x98
extern void SeMenu_ReadObjData(unsigned char *d);
extern void SeMenu_ResetSubIndex(void);
extern unsigned char SeMenu_AdvanceSubIndex(void);
extern void SeMenu_ReadObjParam(unsigned char *p);
extern void SeMenu_SetupDisplayObject(unsigned char *p);
extern int SeMenu_RegisterElement_Type2(int a, int c, int e, int s);
extern void SeMenu_SetCurrentStep(int v);
extern void SeMenu_FillEntryTable(unsigned char *t);
extern void SeMenu_ComputeParamTableAddr(int n, unsigned char *t);
extern void SeMenu_SendEvent(int title, int refresh);
void SeMenu_HandleMenuChange(void)
{
	unsigned char d;
	unsigned char tab[16];
	unsigned char prm;

	SeMenu_ReadObjData(&d);
	if (d == 0) {
		SeMenu_ResetSubIndex();
		SeMenu_AdvanceSubIndex();
		SeMenu_ReadObjParam(&prm);
		SeMenu_SetupDisplayObject(&prm);
		SeMenu_RegisterElement_Type2(0, 0, 10, 16);
		SeMenu_SetCurrentStep(1);
		return;
	}
	SeMenu_ReadObjParam(&prm);
	SeMenu_FillEntryTable(tab);
	SeMenu_ComputeParamTableAddr(prm, tab);
	if (SeMenu_AdvanceSubIndex() <= 0x7f) {
		SeMenu_ReadObjParam(&prm);
		SeMenu_SetupDisplayObject(&prm);
		SeMenu_RegisterElement_Type2(0, 0, 10, 16);
	} else {
		SeMenu_SetCurrentStep(0);
		SeMenu_ResetSubIndex();
		SeMenu_SendEvent(TT_SQDRMEDT, 0);
	}
}
