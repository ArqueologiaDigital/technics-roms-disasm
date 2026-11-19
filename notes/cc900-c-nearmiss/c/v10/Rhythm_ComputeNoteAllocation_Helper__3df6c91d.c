/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_4m234a.c (2026-11-19-13-p6-r41)
   sha256 3df6c91d13a3bb2dc428d96c29fdc0d3b2870d09d8e7e74da368438ec321e33b (tar-sha256); compiled at -O3 -Xr */
struct cur4 { unsigned int blk; unsigned int ofs; };
extern struct cur4 SeqEvt_ProcessBlock_LocalInit_2;
extern unsigned char __near ram_230c;
extern unsigned char Part_ReadSubBlock32(unsigned int, unsigned int);
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern unsigned char SeqEvt_ProcessBlock_Helper(struct cur4 *);
int Rhythm_ComputeNoteAllocation_Helper(unsigned char part)
{
	int n;
	unsigned char go;
	struct cur4 c;

	n = 0;
	go = 1;
	c = SeqEvt_ProcessBlock_LocalInit_2;
	if (Part_ReadSubBlock32(0, part) != 13)
		return 0;
	c.blk = Part_ReadVoiceWord(0, part);
	c.ofs = 5;
	do {
		switch (SeqEvt_ProcessBlock_Helper(&c)) {
		case 176:
		case 177:
			n = ram_230c;
		case 129:
		case 130:
		case 132:
			go = 0;
			break;
		}
	} while (go == 1);
	return n;
}
