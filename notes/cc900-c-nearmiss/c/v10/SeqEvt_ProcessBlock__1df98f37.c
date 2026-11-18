/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_5m234a.c (2026-11-18-33-p6-r37)
   sha256 1df98f3702e730ab9fe97097a63ec11b83af1d37dd908e4eeb031970c72e2b9b (tar-sha256); compiled at -O3 -Xr */
struct cur4 { unsigned int blk; unsigned int ofs; };
extern struct cur4 SeqEvt_ProcessBlock_LocalInit;
extern unsigned char Part_ReadSubBlock32(unsigned int, unsigned int);
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern unsigned char SeqEvent_ProcessRhythm4Ch(struct cur4 *);
int SeqEvt_ProcessBlock(unsigned char part)
{
	int n;
	unsigned char go;
	struct cur4 c;
	unsigned char r;

	n = 0;
	go = 1;
	c = SeqEvt_ProcessBlock_LocalInit;
	r = Part_ReadSubBlock32(0, part);
	if (r != 16 && r != 13)
		return 0;
	c.blk = Part_ReadVoiceWord(0, part);
	c.ofs = 5;
	do {
		r = SeqEvent_ProcessRhythm4Ch(&c);
		if (r == 132)
			go = 0;
		else if (r == 130) {
			n = 0;
			go = 0;
		} else if (r == 129)
			n++;
	} while (go == 1);
	return n;
}
