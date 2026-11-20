/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

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
