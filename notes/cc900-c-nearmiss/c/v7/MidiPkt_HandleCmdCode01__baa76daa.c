/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/midi_dispatch_handlers_m0_xr.c (2026-11-21-2-p6-r58)
   sha256 baa76daa1ad86fc37bf81a2d5c317bc06aadc60ba43f13a742f614d5e8c9543d (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
struct mq;
typedef struct mq *mqp;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char __near ram_bc7c;
extern unsigned char __near ram_bc84;
extern unsigned char __near ram_bbcc;
extern unsigned char __near ram_bbcd;
extern unsigned char __near ram_bbce;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
void MidiPkt_HandleCmdCode01(void)
{
	if (ram_bc84 == 1) {
		ram_bbcc = SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 6);
		ram_bbcd = SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 7);
		ram_bbce = SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 8);
		ram_bc7c |= 0x80;
		ram_bc84 = 2;
	} else {
		((unsigned char *)MIDISEQ_ACTIVE_BUF_PTR)[4] = 0x18;
		ram_bc7c &= ~0x10;
	}
}
