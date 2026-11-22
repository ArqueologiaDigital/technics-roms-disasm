/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/midi_dispatch_handlers_m0_xr.c (2026-11-21-2-p6-r58)
   sha256 9fe51107568ff28e99e9cb5aedc1e34505b40ab8bdd0b5b58c2e97bbf656663e (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
struct mq;
typedef struct mq *mqp;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char __near ram_bc58;
extern unsigned char __near ram_bc60;
extern unsigned char __near ram_bba8;
extern unsigned char __near ram_bba9;
extern unsigned char __near ram_bbaa;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
void MidiPkt_HandleCmdCode01(void)
{
	if (ram_bc60 == 1) {
		ram_bba8 = SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 6);
		ram_bba9 = SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 7);
		ram_bbaa = SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 8);
		ram_bc58 |= 0x80;
		ram_bc60 = 2;
	} else {
		((unsigned char *)MIDISEQ_ACTIVE_BUF_PTR)[4] = 0x18;
		ram_bc58 &= ~0x10;
	}
}
