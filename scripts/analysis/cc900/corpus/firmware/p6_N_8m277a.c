/* lane_p6 helper N, round 8, form a: module 277 (audio/tonegen_fileio_handlers.s), new function.
   PanelButton_ProcessChanges: drains the panel change queue (3-byte entries, 0xff ends; the queue pointer is
   fetched anew each time), dispatching each change, then terminates the panel event queue, clears the change
   queue and finds the master volume (tail jump).  The loop jumps to its test at the bottom first: -Xr.
   cc900-options: -Xr
*/
/* cc900-module: PanelButton_DispatchChange PanelButton_FetchChange VoiceEntry_FindMasterVolume */

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
