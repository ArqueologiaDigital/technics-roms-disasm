/* Phase 6, lane_p6 helper M, round 6, module 129, form a: SeMenu_StepNoteParamInRange retry (run r46: +75 @Xr).
   Spots: (1) `val += step` gave V4.23's add to memory; the ROM loads val, adds step, stores: `val = val + step`;
   (2) block order: the ROM places the up-direction test inline, then the stepping code, then the down-direction
   test and the shared `return 0` at the end: written with gotos in that order; (3) the StorePartParam call: the
   ROM loads both arguments straight into WA / BC, the listing went through DE: the callee declared K&R here. */
/* cc900-module: SeMenu_LoadPartParam SeMenu_StorePartParam SeMenu_SwitchToValueStep */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam();
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
