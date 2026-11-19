/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_3m273b.c (2026-11-19-22-p6-r45)
   sha256 540d846cc8732e3bff530d15c442083b5a81a5daee9430065e9b38a22df69fd0 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern unsigned char OFFSCREEN_BUFFER_1[];
void PaletteBankRotate_Impl(void)
{
	unsigned char *p;
	int y;
	int x;
	unsigned char *b;

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
