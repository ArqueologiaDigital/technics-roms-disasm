/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_9m277a.c (2026-11-19-75-p6-r54)
   sha256 59e96694af953f213ca1741d814cb80aa3e609abb715ebad9f3e2bd3285a828b (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_8eb2[];
extern unsigned char __near ram_8ec4;
extern unsigned char __near ADC_AN0_OUTPUT[];
extern unsigned char __near ADC_AN1_OUTPUT[];
extern void PanelInput_QueueChange(unsigned char *);
void PanelInput_QueueCpuAdcChanges(void)
{
	unsigned char *q;
	unsigned char *a;

	q = ram_8eb2;
	if (ram_8ec4 < 7) {
		a = ADC_AN0_OUTPUT;
		if (a[1] & 0x80) {
			a[1] &= ~0x80;
			q[0] = 0x1a;
			q[1] = a[0];
			q[2] = 0x7f;
			PanelInput_QueueChange(q);
		}
	}
	if (ram_8ec4 < 7) {
		a = ADC_AN1_OUTPUT;
		if (a[1] & 0x80) {
			a[1] &= ~0x80;
			q[0] = 0x1b;
			q[1] = a[0];
			q[2] = 0x7f;
			PanelInput_QueueChange(q);
		}
	}
}
