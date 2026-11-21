/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: MidiPkt_RecoverIfXferAborted MidiTable_DispatchHelper MidiTable_FlushArpNotes SeqChan_StepCmd_Field1to2 SeqChan_StepCmd_Field2to3 SeqChan_StepCmd_Field4to5 SeqChan_StepCmd_Field5to6 SeqChan_StepCmd_Field8to9 SeqChan_StepCmd_Field9to10 SeqChan_XferStep_AccompBlock1 SeqChan_XferStep_AccompBlock2 SeqChan_XferStep_StyleImageBlock1 */   /* scripts/analysis/cc900/module_calls.py v10 */

struct mq;
typedef struct mq *mqp;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char __near ram_bc58;
extern unsigned char __near ram_bc60;
extern unsigned char __near ram_bba8;
extern unsigned char __near ram_bba9;
extern unsigned char __near ram_bbaa;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
extern void MidiPkt_HandleCmdCode01(void);

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
