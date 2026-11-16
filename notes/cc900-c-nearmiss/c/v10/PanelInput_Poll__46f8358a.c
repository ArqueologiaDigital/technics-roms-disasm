/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/audio_control_engine_m277.c (2026-11-16-111-p6-r22-staged)
   sha256 46f8358a09a0164aa3b6088928048accac6db5b173e0c234f24f6f310161aac5 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void PanelInput_DrainRxQueue(void);
extern void PanelInput_ScanPedalPorts(void);
extern void PanelInput_QueueCpuAdcChanges(void);
extern unsigned int __near ram_8ec2;
extern unsigned int __near SYSTEM_TIMESTAMP;
extern unsigned char __near CURRENT_TITLE;
void PanelInput_Poll(void)
{
	ram_8ec2 = SYSTEM_TIMESTAMP;
	if (CURRENT_TITLE != 247) {
		PanelInput_DrainRxQueue();
		PanelInput_ScanPedalPorts();
		PanelInput_QueueCpuAdcChanges();
	}
}
