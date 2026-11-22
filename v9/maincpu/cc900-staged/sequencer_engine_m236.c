/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqPart_ComputeStepCount SeqPart_CountEventsInRange SeqPart_ReplayForward */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near ram_2652;
extern unsigned int __near ram_27f4;
extern unsigned int __near SEQ_OP_DEST_MEASURE;
extern unsigned int __near ram_265c;
extern unsigned int __near ram_265e;
extern unsigned int __near ram_269c;
extern unsigned int __near ram_26a2;
extern unsigned int __near ram_26ac;
extern unsigned int __near ram_26b8;
extern unsigned int __near ram_26ae;
extern unsigned long __near ram_26ba;
extern unsigned int __near ram_287d;
extern unsigned int __near SEQOP_SECONDARY_BLOCK;
extern unsigned int __near SEQOP_SECONDARY_OFFSET;
extern void SeqPart_CountEventsInRange(unsigned int *, unsigned int *);
extern void SeqBuf_ComputePageLayout(void);
extern void SeqPart_ReplayForward(void);
extern void Part_WriteWordAndByte(unsigned int, unsigned int);
void SeqPart_ComputeStepCount(unsigned int a);
extern void SeqPart_ComputeStepCount(unsigned int a);
extern void SeqPart_Splice(void);

void SeqPart_Splice(void)
{
	unsigned int a;
	unsigned int b;

	SEQ_ERROR_CODE = 0;
	SeqPart_CountEventsInRange(&a, &b);
	if (SEQ_ERROR_CODE != 0) return;
	ram_27f4 = SEQ_OP_DEST_MEASURE - a - 1;
	SeqPart_ComputeStepCount(a);
	if (SEQ_ERROR_CODE != 0) return;
	ram_269c = ram_265c;
	ram_26a2 = ram_265e;
	SeqBuf_ComputePageLayout();
	if (SEQ_ERROR_CODE != 0) return;
	ram_26ac = ram_26b8;
	ram_26ae = ram_26ba;
	SeqPart_ReplayForward();
	if (SEQ_ERROR_CODE != 0) return;
	ram_287d = ram_2652;
	ram_265e = SEQOP_SECONDARY_OFFSET;
	ram_265c = SEQOP_SECONDARY_BLOCK;
	Part_WriteWordAndByte(ram_265c, (unsigned char)ram_265e);
}
