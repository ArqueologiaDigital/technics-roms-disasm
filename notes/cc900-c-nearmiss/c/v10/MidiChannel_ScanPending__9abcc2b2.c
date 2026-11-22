/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_32r1m278a.c (2026-11-22-17-p6-r84)
   sha256 9abcc2b2d0b04f062ab86db335f7662aba1ec8dd72246a03e7a7cedf50911041 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near CPANEL_LED_IMAGE[];
extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned int __near LED_REQUEST_HOLD_2;
extern unsigned char __near ram_8f4a;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned int __near ram_40f;
extern int SndParam_LookupReadOnly(long);
void MidiChannel_ScanPending(void)
{
	unsigned char *p;
	unsigned char *q;
	int r;

	p = CPANEL_LED_IMAGE;
	if (LED_REQUEST_HOLD_2 & 4) return;
	if (ram_8f4a & 3) return;
	if (ACC_TRANSPORT_STATE & 4) return;
	if (SEQ_RTMCFG & 4) {
		if (SEQ_TRANSPORT_STATE & 4) return;
		p[14] &= 0xf0;
		return;
	}
	r = SndParam_LookupReadOnly(0x28103L);
	q = p + 14;
	if (r == 1) {
		if (!(ram_40f & 0x40)) {
			*q = (*q & 0xf0) | 1;
			return;
		}
	} else {
		if (SEQ_TRANSPORT_STATE & 4) return;
	}
	*q &= 0xf0;
}
