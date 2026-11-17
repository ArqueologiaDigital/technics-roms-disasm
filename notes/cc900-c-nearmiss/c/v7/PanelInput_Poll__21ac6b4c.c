/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/audio_control_engine_m277.c (2026-11-16-111-p6-r22-staged)
   sha256 21ac6b4c17d996aeba63aaea81014f3dcff638115ae1c3aa2dc2cdc577684474 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void PanelInput_DrainRxQueue(void);
extern void PanelInput_ScanPedalPorts(void);
extern void PanelInput_QueueCpuAdcChanges(void);
extern unsigned int __near ram_8e26;
extern unsigned int __near SYSTEM_TIMESTAMP;
extern unsigned char __near CURRENT_TITLE;
void PanelInput_Poll(void)
{
	ram_8e26 = SYSTEM_TIMESTAMP;
	if (CURRENT_TITLE != 247) {
		PanelInput_DrainRxQueue();
		PanelInput_ScanPedalPorts();
		PanelInput_QueueCpuAdcChanges();
	}
}
