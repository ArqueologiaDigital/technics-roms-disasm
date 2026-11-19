/* Phase 6, lane_p6 helper L, round 2, form a: module 131 (audio/sound_editor_ui.s).
   - UpdSeSel_ProcessStep: step 0 registers the element and moves to step 1; step 1 checks the object, then picks a
     mode from the entry table's top two bits (0x80 / 0x40 / other); then the detailed or simple update by the
     object entry.  The ROM shares the SetDisplayState and SetCurrentStep calls between branches (cross-jumps).
     The SeMenu callees (another module) take their char arguments as ints.  if / else chain on t[0]. */
/* cc900-module: UpdSeSel_DetailedUpdate UpdSeSel_SimpleUpdate */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern void UpdSeSel_ProcessStep(void);

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
