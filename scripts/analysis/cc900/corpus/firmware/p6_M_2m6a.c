/* Phase 6, lane_p6 helper M, round 2, module 6 (boot/system_handlers.s), form a.
   VRAM_FillRect: fill a 6 x 12 pixel cell of the 320-wide 8-bit VRAM at 0x1a0000 with colour c, a word (two pixels)
   at a time.  Frame: the row end +4 (built by a store and an add to memory), c +6, x0 +8; y in IX, x in IY, the
   column end in BC.  The VRAM base is a converted constant pointer (ld immediate + add). */

extern void VRAM_FillRect(unsigned int x0, unsigned int y0, unsigned char c);

void VRAM_FillRect(unsigned int x0, unsigned int y0, unsigned char c)
{
	unsigned int y;
	unsigned int ye;
	unsigned int x;
	unsigned int xe;

	y = y0;
	ye = y0;
	ye += 12;
	for (; y < ye; y++) {
		xe = (x = x0) + 6;
		for (; x < xe; x += 2)
			((unsigned int *)0x1a0000L)[((unsigned long)y * 320 + x) >> 1] = c | ((unsigned int)c << 8);
	}
}
