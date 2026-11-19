/* Phase 6, lane_p6 helper M, round 2, module 6 (boot/system_handlers.s), form b (alternative to p6_M_2m6a.c).
   VRAM_FillRect: the row end kept in the parameter y0 itself (y0 += 12 after y = y0), so the frame slot +4 is the
   parameter's home. */

extern void VRAM_FillRect(unsigned int x0, unsigned int y0, unsigned char c);

void VRAM_FillRect(unsigned int x0, unsigned int y0, unsigned char c)
{
	unsigned int y;
	unsigned int x;
	unsigned int xe;

	y = y0;
	y0 += 12;
	for (; y < y0; y++) {
		x = x0;
		xe = x + 6;
		for (; x < xe; x += 2)
			((unsigned int *)0x1a0000L)[((unsigned long)y * 320 + x) >> 1] = c | ((unsigned int)c << 8);
	}
}
