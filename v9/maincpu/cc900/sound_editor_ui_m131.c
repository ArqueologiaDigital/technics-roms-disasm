/* Functions of audio/sound_editor_ui.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
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
