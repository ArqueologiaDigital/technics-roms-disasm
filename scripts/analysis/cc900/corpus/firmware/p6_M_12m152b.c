/* Phase 6, lane_p6 helper M, round 12, hand source audio/sound_editor_ui.s, form b: the EASY EDIT, DIGITAL EFFECT
   and WRITE MEMORY pages' side rows and switches.  SeEasy rows 2-5: the shape of SeMenu_ApplyPartEdit_AltStore_Join7
   (switch part parameter 0 to 5..8 / 1..4 unless already so, redraw title field 33); row 1 and the switches: a call
   (or two) inside an if.  Two callees' names share 31 characters with siblings: cc900-name aliases. */
/* cc900-name: SeM_CWU_S3H14=SeMenu_CopyWriteUpdate_Step3_Helper14 */
/* cc900-name: SeM_CWU_S3C3H=SeMenu_CopyWriteUpdate_Step3_Code_3_Helper */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

#define TT_SEMENU    0x20
#define TT_SEWRTMEM  0x3e
#define TT_SEWRTSND  0x3f

extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_SetSelectedRow(int);
extern void SeMenu_TriggerNotification(int);
extern void SeMenu_GetWriteMemSlot(unsigned char *);
extern void SeWrtMem_SelectMemorySlotSound(int);
extern void SeM_CWU_S3H14(int);
extern void SeM_CWU_S3C3H(int, int);
extern void SeEasy_OnSideRow1(unsigned char a);
extern void SeEasy_OnSideRow2(unsigned char a);
extern void SeEasy_OnSideRow3(unsigned char a);
extern void SeEasy_OnSideRow4(unsigned char a);
extern void SeEasy_OnSideRow5(unsigned char a);
extern void SeEasy_OnSwitch15(unsigned char a);
extern void SeDigEff_OnSwitch15(unsigned char a);
extern void SeWrtMem_OnSideRow1(unsigned char a);
extern void SeWrtMem_OnSideRow5(unsigned char a);
extern void SeWrtMem_OnSwitch15(unsigned char a);

void SeEasy_OnSideRow1(unsigned char a)
{
	if (a != 0) {
		SeM_CWU_S3H14(0);
		SeMenu_SendEvent(TT_SEWRTMEM, 0);
	}
}

void SeEasy_OnSideRow2(unsigned char a)
{
	unsigned char v;

	SeMenu_LoadPartParam(0, &v);
	if (a == 0) {
		if (v == 5)
			return;
		SeMenu_StorePartParam(0, 5);
	} else {
		if (v == 1)
			return;
		SeMenu_StorePartParam(0, 1);
	}
	SeTitle_DrawField(33, 0);
}

void SeEasy_OnSideRow3(unsigned char a)
{
	unsigned char v;

	SeMenu_LoadPartParam(0, &v);
	if (a == 0) {
		if (v == 6)
			return;
		SeMenu_StorePartParam(0, 6);
	} else {
		if (v == 2)
			return;
		SeMenu_StorePartParam(0, 2);
	}
	SeTitle_DrawField(33, 0);
}

void SeEasy_OnSideRow4(unsigned char a)
{
	unsigned char v;

	SeMenu_LoadPartParam(0, &v);
	if (a == 0) {
		if (v == 7)
			return;
		SeMenu_StorePartParam(0, 7);
	} else {
		if (v == 3)
			return;
		SeMenu_StorePartParam(0, 3);
	}
	SeTitle_DrawField(33, 0);
}

void SeEasy_OnSideRow5(unsigned char a)
{
	unsigned char v;

	SeMenu_LoadPartParam(0, &v);
	if (a == 0) {
		if (v == 8)
			return;
		SeMenu_StorePartParam(0, 8);
	} else {
		if (v == 4)
			return;
		SeMenu_StorePartParam(0, 4);
	}
	SeTitle_DrawField(33, 0);
}

void SeEasy_OnSwitch15(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEMENU, 0);
}

void SeDigEff_OnSwitch15(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEMENU, 0);
}

void SeWrtMem_OnSideRow1(unsigned char a)
{
	unsigned char slot;

	if (a != 0) {
		SeMenu_GetWriteMemSlot(&slot);
		SeM_CWU_S3C3H(slot, 62);
		SeWrtMem_SelectMemorySlotSound(slot);
		SeMenu_TriggerNotification(35);
		SeM_CWU_S3H14(1);
		SeMenu_SetSelectedRow(0);
	}
}

void SeWrtMem_OnSideRow5(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEWRTSND, 0);
}

void SeWrtMem_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetSelectedRow(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}
