/* Phase 6, lane_p6 helper M, round 4, module 6, form a: VRAM_FillRect retry (run r42: +1, the frame).
   The ROM keeps the row end ye in the frame (+4, built by a store and `add (xsp+4),12`, compared from memory),
   c at +6, x0 at +8, y in IX; V4.23 kept ye in a register (frame 4).  A no-code `&ye;` keeps it in the frame. */

extern void VRAM_FillRect(unsigned int x0, unsigned int y0, unsigned char c);

void VRAM_FillRect(unsigned int x0, unsigned int y0, unsigned char c)
{
	unsigned int y;
	unsigned int ye;
	unsigned int x;
	unsigned int xe;

	&ye;
	y = y0;
	ye = y0;
	ye += 12;
	for (; y < ye; y++) {
		xe = (x = x0) + 6;
		for (; x < xe; x += 2)
			((unsigned int *)0x1a0000L)[((unsigned long)y * 320 + x) >> 1] = c | ((unsigned int)c << 8);
	}
}
