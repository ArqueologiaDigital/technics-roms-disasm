/* helper V, round 21r1, module 131 (audio/sound_editor_ui.s): the sound editor's entry defaults and its selection
   refresh.  The callees' byte parameters are passed as int (the ROM loads WA), so they are declared with int. */

extern void SeMenu_SetSoundBank(int);
extern void SeMenu_SetPatchBank(int);
extern void AccWrap_PlayModeDispatch(void);
extern void SeMenu_SetEditEnable(int);
extern void SeMenu_OrPartConfig(int);
extern void SeMenu_SetConfirmState(int);
extern void SeMenu_ClearDisplayBuffer(void);
extern void SeMenu_SetSelectedRow(int);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SetupMenuDisplay(int mode);
extern void SeMenu_RefreshPartDisplay(void);

void InitializeSeMenuDefaults(void)
{
	SeMenu_SetSoundBank(0);
	SeMenu_SetPatchBank(0);
	AccWrap_PlayModeDispatch();
	SeMenu_SetEditEnable(1);
	SeMenu_OrPartConfig(1);
	SeMenu_SetConfirmState(0);
	SeMenu_ClearDisplayBuffer();
}

void UpdateSeMenuSelection(void)
{
	unsigned char k;

	SeMenu_SetSelectedRow(0);
	SeMenu_SetEditEnable(0);
	SeMenu_LoadObjEntries(&k);
	if (k != 2)
		SeMenu_SetupMenuDisplay(0);
	SeMenu_SetConfirmState(0);
	SeMenu_RefreshPartDisplay();
}
