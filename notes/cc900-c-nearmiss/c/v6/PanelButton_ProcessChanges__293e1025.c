/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/tonegen_fileio_handlers_m277.c (2026-11-19-92-p6-r57)
   sha256 293e102585e88bf0155aa604fda508501cf9e82575ec443f6e22ba2f73403b6f (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct pevt { unsigned char code, a, b, c; };
extern unsigned char __near ram_8dcc;
extern unsigned char __near ram_8dce;
extern unsigned char __near ram_8dd0;
extern struct pevt __near PANEL_EVENT_QUEUE[];
extern unsigned char *PanelInput_ChangeQueue(void);
extern void PanelButton_FetchChange(void);
extern void PanelButton_DispatchChange(void);
extern void PanelInput_ClearChangeQueue(void);
extern void VoiceEntry_FindMasterVolume(void);
void PanelButton_ProcessChanges(void)
{
	ram_8dcc = 0;
	ram_8dce = 0;
	while ((ram_8dd0 = PanelInput_ChangeQueue()[(int)ram_8dcc * 3]) != 0xff) {
		PanelButton_FetchChange();
		PanelButton_DispatchChange();
	}
	PANEL_EVENT_QUEUE[ram_8dce].code = 0xff;
	PanelInput_ClearChangeQueue();
	VoiceEntry_FindMasterVolume();
}
