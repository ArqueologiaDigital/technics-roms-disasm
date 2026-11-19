/* Phase 6, lane_p6 helper L, round 5, form a: module 303.  Retry of FetchOscTableEntry_Prologue (r45 O3Xr form a
   +19: only the table count's register differs, H where the ROM has E).  Round 3's form a with the count declared
   last (idiom 4). */
/* cc900-module: ApplyProgramChangeAs_DoLookupRe */   /* scripts/analysis/cc900/module_calls.py v10 */

struct cell2 { unsigned char a, b; };
extern unsigned char ApplyProgramChangeAs_DoLookupRe(void);
extern unsigned char *__near SOUND_TABLE_BASE;
extern void FetchOscTableEntry_Prologue(unsigned char *p, long off);

void FetchOscTableEntry_Prologue(unsigned char *p, long off)
{
	unsigned char lim;
	unsigned char row;
	unsigned char col;
	unsigned char *t;
	struct cell2 *e;
	unsigned char n;

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
