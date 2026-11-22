/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_32r1m236b.c (2026-11-22-17-p6-r84)
   sha256 51de6e0221509baca334f989cc16fb6ac65de4ebf48e7d1ddf68348fe4dbc932 (tar-sha256); compiled at -O3 -Xr */
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
