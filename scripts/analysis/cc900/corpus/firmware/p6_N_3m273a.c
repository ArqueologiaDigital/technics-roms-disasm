/* lane_p6 helper N, round 3, form a: module 273 (ui/ui_window_procs.s), PaletteBankRotate_Impl only, retry of
   p6_N_1m273b (p6-r42 O3Xr: +12).  V4.23 pushed the extern OFFSCREEN_BUFFER_2 / _3 as two word halves where the
   ROM loads them with `ld xwa,imm; push xwa` (as for 0x69800): numeric constants here.  It also gave the pixel
   pointer XHL and the counters BC (rows) / DE (columns), where the ROM has XBC / DE (rows) / HL (columns): form a
   declares the column counter, the row counter, then the pointer.
   cc900-options: -O3 -Xr
*/

extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern unsigned char OFFSCREEN_BUFFER_1[];

void PaletteBankRotate_Impl(void)
{
	unsigned char *b;
	int x;
	int y;
	unsigned char *p;

	b = OFFSCREEN_BUFFER_1;
	Mem_Copy((void *)0x56800L, b, 0x9600);
	b += 0x9600;
	Mem_Copy((void *)0x5fe00L, b, 0x9600);
	p = OFFSCREEN_BUFFER_1;
	y = 0;
	do {
		x = 0;
		do {
			if (*p >= 0xe0)
				*p -= 0x90;
			else
				*p += 0x10;
			p++;
			x++;
		} while (x < 320);
		y++;
	} while (y < 240);
	b = OFFSCREEN_BUFFER_1;
	Mem_Copy((void *)0x69800L, b, 0x9600);
	b += 0x9600;
	Mem_Copy((void *)0x72e00L, b, 0x9600);
}
