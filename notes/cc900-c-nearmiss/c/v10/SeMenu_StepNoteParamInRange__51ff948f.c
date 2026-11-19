/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_6m129a.c (2026-11-19-37-p6-r47)
   sha256 51ff948f52550821e5cb0c6bcb99c2f8d7a0aa4baac87720319592f120038957 (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam();
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
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
