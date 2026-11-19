/* Phase 6, lane_p6 helper L, round 3, form b: module 129, SeMenu_ClampAndScaleEnvLevel with the negated factor in a
   plain char local (stored back to s, then used from the local), product negated in place. */
/* cc900-module: SeMenu_LoadPartParam SeMenu_LoadRawAddr */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SeMenu_LoadRawAddr(unsigned char *k);
extern void SeMenu_LoadPartParam(int, char *);
extern void SeMenu_ClampAndScaleEnvLevel(char *p);

void SeMenu_ClampAndScaleEnvLevel(char *p)
{
	char s;
	unsigned char k;
	int v;
	char t;

	SeMenu_LoadRawAddr(&k);
	if (*p > 50)
		*p = 50;
	if (*p < -50)
		*p = -50;
	SeMenu_LoadPartParam(1, &s);
	v = *p;
	if (k == 55)
		return;
	if (s >= 0)
		v *= s;
	else {
		t = -s;
		s = t;
		v *= t;
		v = -v;
	}
	*p = v / 50;
}
