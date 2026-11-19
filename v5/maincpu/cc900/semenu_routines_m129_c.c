/* Functions of audio/semenu_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeMenu_AdvanceSubIndex SeMenu_ComputeParamTableAddr SeMenu_FillEntryTable SeMenu_LoadObjEntries SeMenu_LoadPartParam SeMenu_LoadRawAddr SeMenu_ReadObjData SeMenu_ReadObjParam SeMenu_RegisterElement_Extended SeMenu_RegisterElement_Type2 SeMenu_ResetSubIndex SeMenu_SendEvent SeMenu_SetCurrentStep SeMenu_SetupDisplayObject SeMenu_SetupDisplayObject_Alt1 SeMenu_ValidatePartNumber */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern void SeMenu_HandleMenuChange(void);

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
