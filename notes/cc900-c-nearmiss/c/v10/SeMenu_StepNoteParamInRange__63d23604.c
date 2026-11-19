/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_5m129e.c (2026-11-19-29-p6-r46)
   sha256 63d23604d5c02876bdf7f86218eac5a093912c6381e64a6e2a5bfa22f7260e29 (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
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
