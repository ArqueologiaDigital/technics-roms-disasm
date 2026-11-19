/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/tonegen_fileio_handlers_m277.c (2026-11-19-92-p6-r57)
   sha256 ebba21b6e0cd99ed8432874b5575e5d5d556c893bb22071519c45a29ee390c25 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct pevt { unsigned char code, a, b, c; };
extern unsigned char __near ram_8e8c;
extern unsigned char __near ram_8e8e;
extern unsigned char __near ram_8e90;
extern struct pevt __near PANEL_EVENT_QUEUE[];
extern unsigned char *PanelInput_ChangeQueue(void);
extern void PanelButton_FetchChange(void);
extern void PanelButton_DispatchChange(void);
extern void PanelInput_ClearChangeQueue(void);
extern void VoiceEntry_FindMasterVolume(void);
void PanelButton_ProcessChanges(void)
{
	ram_8e8c = 0;
	ram_8e8e = 0;
	while ((ram_8e90 = PanelInput_ChangeQueue()[(int)ram_8e8c * 3]) != 0xff) {
		PanelButton_FetchChange();
		PanelButton_DispatchChange();
	}
	PANEL_EVENT_QUEUE[ram_8e8e].code = 0xff;
	PanelInput_ClearChangeQueue();
	VoiceEntry_FindMasterVolume();
}
