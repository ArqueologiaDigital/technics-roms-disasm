/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_U_32r1m236b.c (2026-11-22-17-p6-r84)
   sha256 51de6e0221509baca334f989cc16fb6ac65de4ebf48e7d1ddf68348fe4dbc932 (tar-sha256); compiled at -Xr */
/* lane_p6 helper U, round 32r1: roots of sequencer/sequencer_engine.s, module 236 (-O3 -Xr).  Form b: SeqPart_ComputeStepCount loads the seek arguments before
   the store; SeqPart_Splice declares its two frame words in the other order. */
/* cc900-module: SeqPart_ComputeStepCount SeqPart_CountEventsInRange SeqPart_ReplayForward */

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near ram_288d;
extern unsigned char __near ram_2652;
extern unsigned char __near ram_288e;
extern unsigned int __near ram_287f;
extern unsigned int __near ram_27f4;
extern unsigned long __near ram_25da;
extern void SeqVoice_SeekToBar(int, int);
extern unsigned char SeqData_ReadNextByte(void);
extern void SeqTrack_ProcessControlBytes(void);
extern void SeqData_AdvancePosition(void);
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

void SeqPart_ComputeStepCount(unsigned int a)
{
	unsigned int n;
	unsigned char b;
	unsigned char c;
	unsigned char e;

	SEQ_ERROR_CODE = 0;
	c = ram_288d;
	e = ram_2652;
	ram_287f = a;
	SeqVoice_SeekToBar(e, c);
	if (SEQ_ERROR_CODE != 0) return;
	n = 0;
	ram_25da = 0;
	do {
		b = SeqData_ReadNextByte();
		if (b == 0x82) {
			ram_25da = ram_288e - (unsigned long)n;
			n = 0;
			if (ram_27f4 != 0) {
				do {
					SeqTrack_ProcessControlBytes();
					if (SEQ_ERROR_CODE != 0) return;
					n++;
					ram_25da += ram_288e;
				} while (n != ram_27f4);
			}
			ram_25da += 1;
			return;
		}
		if (b == 0x81) n++;
		SeqData_AdvancePosition();
	} while (SEQ_ERROR_CODE == 0);
}

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
