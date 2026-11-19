/* Phase 6, lane_p6 helper L, round 3, form a: module 303.  Retry of FetchOscTableEntry_Prologue (round 1 O3Xr form a
   had the ROM's shape; the index differs).  The ROM adds the offset onto the table base in place (`t += off`,
   add xbc,(frame)), multiplies row * n as a 16-bit product and adds the zero-extended column to it, scaled for
   2-byte cells.  Locals declared n, row, col (register choice). */
/* cc900-module: ApplyProgramChangeAs_DoLookupRe */   /* scripts/analysis/cc900/module_calls.py v10 */

struct cell2 { unsigned char a, b; };
extern unsigned char ApplyProgramChangeAs_DoLookupRe(void);
extern unsigned char *__near SOUND_TABLE_BASE;
extern void FetchOscTableEntry_Prologue(unsigned char *p, long off);

void FetchOscTableEntry_Prologue(unsigned char *p, long off)
{
	unsigned char lim;
	unsigned char n;
	unsigned char row;
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
