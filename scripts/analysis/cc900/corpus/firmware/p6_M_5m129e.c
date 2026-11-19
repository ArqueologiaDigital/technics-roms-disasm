/* Phase 6, lane_p6 helper M, round 5, module 129 (audio/semenu_routines.s), new: SeMenu_StepNoteParamInRange.
   Step a note-range parameter (part parameter c, bit 7 a flag kept aside) by the dial step, clamped to 12..127 and
   to [lo, hi] (lo < 12 means 12, hi < 12 means no limit 0); refuses (returns 0) at the end of the range in the
   step's direction.  Four arguments, the last on the stack (retd 2).  Every local in the frame (-Xr):
   flag +0, step +2, val +4. */
/* cc900-module: SeMenu_LoadPartParam SeMenu_StorePartParam SeMenu_SwitchToValueStep */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepNoteParamInRange(unsigned char a, unsigned char c, unsigned char lo, unsigned char hi);

unsigned char SeMenu_StepNoteParamInRange(unsigned char a, unsigned char c, unsigned char lo, unsigned char hi)
{
	unsigned char flag;
	unsigned char val;
	unsigned char step;

	SeMenu_LoadPartParam(c, &val);
	flag = val & 0x80;
	val &= 0x7f;
	if (lo != 0 && lo < 12)
		lo = 12;
	if (hi != 0 && hi < 12)
		hi = 0;
	if ((a & 0x7f) == 0) {
		if (val >= 127 || val >= hi)
			return 0;
	} else {
		if (val == 0 || val <= lo)
			return 0;
	}
	if (val == 0)
		val = 11;
	SeMenu_SwitchToValueStep(a, &step);
	val += step;
	if (val < 12)
		val = 0;
	else if (val > 127)
		val = 127;
	if (val < lo)
		val = lo;
	if (val > hi)
		val = hi;
	val |= flag;
	SeMenu_StorePartParam(c, val);
	return 1;
}
