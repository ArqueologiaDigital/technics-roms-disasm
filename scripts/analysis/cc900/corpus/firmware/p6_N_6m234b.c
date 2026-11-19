/* lane_p6 helper N, round 6, form b: module 234 (sequencer/sequencer_engine.s), retries of p6_N_5m234a.
   Form b against a: Part_SetClearVoiceBit7's table offset in an unsigned char local computed in two statements
   (o = p * 3 - 3; o += 0xd0) and passed twice; PartCtrl_WriteBytePair with round 5's address expression and only
   the plain assignment of n.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PartCtrl_ReadWord Part_ReadByteDirect Part_WriteByte */

extern unsigned char Part_ReadByteDirect(unsigned char, unsigned int);
extern void Part_WriteByte(unsigned char, unsigned int, unsigned char);

void Part_SetClearVoiceBit7(unsigned char s, unsigned char p, unsigned char on)
{
	unsigned char v;
	unsigned char o;

	o = p * 3 - 3;
	o += 0xd0;
	v = Part_ReadByteDirect(s, o);
	if (on != 0)
		v |= 0x80;
	else
		v &= ~0x80;
	Part_WriteByte(s, o, v);
}

extern unsigned char ram_b0000[];
extern unsigned int PartCtrl_ReadWord(unsigned int n);

int PartCtrl_WriteBytePair(unsigned int blk, unsigned int off, unsigned char *s)
{
	unsigned char *p;
	unsigned int n;

	p = (unsigned char *)((unsigned long)ram_b0000 + (((unsigned long)(blk - 1) << 8) + off));
	*p = s[0];
	if (off == 0xff) {
		n = PartCtrl_ReadWord(blk);
		if (n == 0xffff)
			return -1;
		p = (unsigned char *)((unsigned long)ram_b0000 + (((unsigned long)(n - 1) << 8) + 5));
	} else
		p++;
	*p = s[1];
	return 0;
}
