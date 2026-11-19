/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_6m303b.c (2026-11-19-49-p6-r49)
   sha256 4684210f55be0f4c913194fef6762afa1ee59aaea1911f205971b39f3b032052 (tar-sha256); compiled at -O3 -Xr */
struct cell2 { unsigned char a, b; };
extern unsigned char ApplyProgramChangeAs_DoLookupRe(void);
extern unsigned char *__near SOUND_TABLE_BASE;
void FetchOscTableEntry_Prologue(unsigned char *p, long off)
{
	unsigned char lim;
	unsigned char row;
	unsigned char n;
	unsigned char col;
	unsigned char *t;
	struct cell2 *e;

	lim = ApplyProgramChangeAs_DoLookupRe();
	t = SOUND_TABLE_BASE;
	n = (unsigned char)*(long *)(t + 8);
	if (p[0] < lim)
		row = p[0];
	else
		row = 0;
	col = 0;
	if (p[1] < n)
		col = p[1];
	t += off;
	e = *(struct cell2 **)t;
	e += (unsigned int)col + (unsigned int)(row * n);
	p[3] = e->a;
	p[4] = e->b;
}
