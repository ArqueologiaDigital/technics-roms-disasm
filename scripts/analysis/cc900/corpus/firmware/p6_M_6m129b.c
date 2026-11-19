/* Phase 6, lane_p6 helper M, round 6, module 129, form b: SeMenu_StepNoteParamInRange (alternative to
   p6_M_6m129a.c): the same goto layout and `val = val + step`, with the prototyped StorePartParam(int, int). */
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
	if ((a & 0x7f) != 0)
		goto down;
	if (val >= 127 || val >= hi)
		goto fail;
step:
	if (val == 0)
		val = 11;
	SeMenu_SwitchToValueStep(a, &step);
	val = val + step;
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
down:
	if (val != 0 && val > lo)
		goto step;
fail:
	return 0;
}
