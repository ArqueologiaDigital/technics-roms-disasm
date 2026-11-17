/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_14m277.c (2026-11-16-100-p6-r19)
   sha256 896c267752ee5b9a9d413d2490830bed1f63c329ac15f9e062c54bcbaf01aff6 (tar-sha256); compiled at -O3 -XS -Xr */
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
