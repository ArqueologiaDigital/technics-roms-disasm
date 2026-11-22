/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_32r1m236a.c (2026-11-22-17-p6-r84)
   sha256 5755c8edc65e3a380b64bc94d0f44c99b18779cdd53dd8edaeb5965f63942d5f (tar-sha256); compiled at -O3 -Xr */
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

	SEQ_ERROR_CODE = 0;
	ram_287f = a;
	SeqVoice_SeekToBar(ram_2652, ram_288d);
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
