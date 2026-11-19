/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_12m287a.c (2026-11-19-92-p6-r57)
   sha256 d0dd4b54cb317f57198717be27865010ea5a745471c4975fd1a1b159ec39d424 (tar-sha256); compiled at -O3 -Xr
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
