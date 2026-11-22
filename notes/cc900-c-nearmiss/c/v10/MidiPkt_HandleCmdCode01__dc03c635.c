/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/midi_dispatch_handlers_m0_xr.c (2026-11-21-2-p6-r58)
   sha256 dc03c6358e629cc18254d0b2d6aba633fca9f9a4e2428938bca496fbe69adb15 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
struct mq;
typedef struct mq *mqp;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char __near ram_bd18;
extern unsigned char __near ram_bd20;
extern unsigned char __near ram_bc68;
extern unsigned char __near ram_bc69;
extern unsigned char __near ram_bc6a;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
void MidiPkt_HandleCmdCode01(void)
{
	if (ram_bd20 == 1) {
		ram_bc68 = SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 6);
		ram_bc69 = SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 7);
		ram_bc6a = SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 8);
		ram_bd18 |= 0x80;
		ram_bd20 = 2;
	} else {
		((unsigned char *)MIDISEQ_ACTIVE_BUF_PTR)[4] = 0x18;
		ram_bd18 &= ~0x10;
	}
}
