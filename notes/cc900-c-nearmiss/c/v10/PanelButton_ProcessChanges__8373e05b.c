/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_8m277a.c (2026-11-19-68-p6-r52)
   sha256 8373e05b8ccc37e05e19e56925412592c712ec95bdbaaf016cfbf3739a80fb93 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
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
	while ((ram_8e90 = PanelInput_ChangeQueue()[ram_8e8c * 3]) != 0xff) {
		PanelButton_FetchChange();
		PanelButton_DispatchChange();
	}
	PANEL_EVENT_QUEUE[ram_8e8e].code = 0xff;
	PanelInput_ClearChangeQueue();
	VoiceEntry_FindMasterVolume();
}
