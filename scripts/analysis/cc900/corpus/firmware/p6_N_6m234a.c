/* lane_p6 helper N, round 6, form a: module 234 (sequencer/sequencer_engine.s), retries of p6_N_5m234a.
   - Part_SetClearVoiceBit7 (p6-r47 O3Xr: +22): V4.23 folded -3 + 0xd0 into one `add c,0xcd`; the ROM multiplies,
     subtracts 3, then adds 0xd0.  Form a: the byte p * 3 - 3 cast to unsigned char before adding 0xd0.
   - PartCtrl_WriteBytePair (p6-r47 Xr: +16): the ROM keeps the next block number in WA after the compare (a plain
     assignment, then the test), and builds the first address in XDE before adding the base into XHL.  Form a:
     plain `n = ...; if (n == 0xffff)`, the offset in an unsigned long local.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PartCtrl_ReadWord Part_ReadByteDirect Part_WriteByte */

extern unsigned char Part_ReadByteDirect(unsigned char, unsigned int);
extern void Part_WriteByte(unsigned char, unsigned int, unsigned char);

void Part_SetClearVoiceBit7(unsigned char s, unsigned char p, unsigned char on)
{
	unsigned char v;

	v = Part_ReadByteDirect(s, (unsigned char)((unsigned char)(p * 3 - 3) + 0xd0));
	if (on != 0)
		v |= 0x80;
	else
		v &= ~0x80;
	Part_WriteByte(s, (unsigned char)((unsigned char)(p * 3 - 3) + 0xd0), v);
}

extern unsigned char ram_b0000[];
extern unsigned int PartCtrl_ReadWord(unsigned int n);

int PartCtrl_WriteBytePair(unsigned int blk, unsigned int off, unsigned char *s)
{
	unsigned char *p;
	unsigned long o;
	unsigned int n;

	o = ((unsigned long)(blk - 1) << 8) + off;
	p = (unsigned char *)((unsigned long)ram_b0000 + o);
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
