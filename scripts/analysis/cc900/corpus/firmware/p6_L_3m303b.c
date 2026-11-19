/* Phase 6, lane_p6 helper L, round 3, form b: module 303, FetchOscTableEntry_Prologue as form a with the locals
   declared col, row, n, the product in an unsigned int local, and the cell index on unsigned char pointers
   (index * 2 written out). */
/* cc900-module: ApplyProgramChangeAs_DoLookupRe */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char ApplyProgramChangeAs_DoLookupRe(void);
extern unsigned char *__near SOUND_TABLE_BASE;
extern void FetchOscTableEntry_Prologue(unsigned char *p, long off);

void FetchOscTableEntry_Prologue(unsigned char *p, long off)
{
	unsigned char col;
	unsigned char row;
	unsigned char n;
	unsigned char lim;
	unsigned char *t;
	unsigned char *e;
	unsigned int m;

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
	e = *(unsigned char **)t;
	m = row * n;
	e += (unsigned int)(col + m) * 2;
	p[3] = e[0];
	p[4] = e[1];
}
