/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/audio_control_engine_m277.c (2026-11-16-111-p6-r22-staged)
   sha256 e3a2ed92fe74daa6687f3f284aff6af65035a31b68a9e661ec7acbeb80190b3d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void PanelInput_DrainRxQueue(void);
extern void PanelInput_ScanPedalPorts(void);
extern void PanelInput_QueueCpuAdcChanges(void);
extern unsigned int __near ram_8e02;
extern unsigned int __near SYSTEM_TIMESTAMP;
extern unsigned char __near CURRENT_TITLE;
void PanelInput_Poll(void)
{
	ram_8e02 = SYSTEM_TIMESTAMP;
	if (CURRENT_TITLE != 247) {
		PanelInput_DrainRxQueue();
		PanelInput_ScanPedalPorts();
		PanelInput_QueueCpuAdcChanges();
	}
}
