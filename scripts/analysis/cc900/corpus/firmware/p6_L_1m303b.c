/* Phase 6, lane_p6 helper L, round 1, form b: module 303, FetchOscTableEntry_Prologue with both clamps as
   conditional expressions, the table's count read as a char at +8's low byte through a long, and the cell
   addressed as a 2-byte record array subscripted with col + row * n. */
/* cc900-module: ApplyProgramChangeAs_DoLookupRe */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char ApplyProgramChangeAs_DoLookupRe(void);
extern unsigned char *__near SOUND_TABLE_BASE;
extern void FetchOscTableEntry_Prologue(unsigned char *p, long off);

struct cell2 { unsigned char a, b; };

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
	row = p[0] < lim ? p[0] : 0;
	col = p[1] < n ? p[1] : 0;
	e = *(struct cell2 **)(t + off);
	e += (unsigned int)(col + row * n);
	p[3] = e->a;
	p[4] = e->b;
}
