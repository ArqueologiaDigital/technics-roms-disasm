/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sound_editor_ui_m0.c (2026-11-19-92-p6-r57)
   sha256 c7d93f6a790c2532ab437973621f3de346642688ec71d7501141927852450910 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr
   cc900-name: SeM_CWU_S3C3H=SeMenu_CopyWriteUpdate_Step3_Code_3_Helper
   cc900-name: SeM_CWU_S3H14=SeMenu_CopyWriteUpdate_Step3_Helper14 */
extern void SeM_CWU_S3H14(int);
extern void SeMenu_SetSelectedRow(int);
extern void SeMenu_TriggerNotification(int);
extern void SeMenu_GetWriteMemSlot(unsigned char *);
extern void SeWrtMem_SelectMemorySlotSound(int);
extern void SeM_CWU_S3C3H(int, int);
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
