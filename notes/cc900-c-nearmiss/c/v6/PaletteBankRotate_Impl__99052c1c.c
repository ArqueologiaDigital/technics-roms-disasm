/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_window_procs_m0.c (2026-11-19-29-p6-r46)
   sha256 99052c1c97da6d5910d9cb030f67ab125bc2074be6015ad582ccf72bcd779d2c (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
