/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/tonegen_fileio_handlers_m277.c (2026-11-19-92-p6-r57)
   sha256 b6d9cb190cfd75e7e1d7f075f7bc9a1579ba0984693877ce0676251b7b8ff548 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct pevt { unsigned char code, a, b, c; };
extern unsigned char __near ram_8df0;
extern unsigned char __near ram_8df2;
extern unsigned char __near ram_8df4;
extern struct pevt __near PANEL_EVENT_QUEUE[];
extern unsigned char *PanelInput_ChangeQueue(void);
extern void PanelButton_FetchChange(void);
extern void PanelButton_DispatchChange(void);
extern void PanelInput_ClearChangeQueue(void);
extern void VoiceEntry_FindMasterVolume(void);
void PanelButton_ProcessChanges(void)
{
	ram_8df0 = 0;
	ram_8df2 = 0;
	while ((ram_8df4 = PanelInput_ChangeQueue()[(int)ram_8df0 * 3]) != 0xff) {
		PanelButton_FetchChange();
		PanelButton_DispatchChange();
	}
	PANEL_EVENT_QUEUE[ram_8df2].code = 0xff;
	PanelInput_ClearChangeQueue();
	VoiceEntry_FindMasterVolume();
}
