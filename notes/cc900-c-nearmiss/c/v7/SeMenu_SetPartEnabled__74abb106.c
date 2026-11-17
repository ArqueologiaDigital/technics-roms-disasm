/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/semenu_routines_m129.c (2026-11-16-122-p6-r24-staged)
   sha256 74abb106c8d3e45165064f2d94575287aca8746d5f160c5d2a881194b780b282 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_LoadObjEntries(unsigned char *);
extern unsigned char SeMenu_BitShiftMask(int, int);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void SeMenu_SetupDisplayObject_Alt1(int, int, unsigned char *, unsigned int);
extern unsigned char __near SEMENU_PART_MASK;
void SeMenu_SetPartEnabled(unsigned char part, unsigned char on)
{
	unsigned char v;
	unsigned char obj;
	unsigned char m;

	if (part < 1 || part > 4) return;
	SeMenu_LoadObjEntries(&obj);
	m = SeMenu_BitShiftMask(1, (unsigned char)(part + part - 2));
	if (on == 0) SEMENU_PART_MASK &= ~m;
	else SEMENU_PART_MASK |= m;
	v = SEMENU_PART_MASK;
	if (obj == 0) SeMenu_RegisterElement_Extended(0, 17, &v, m);
	else SeMenu_SetupDisplayObject_Alt1(0, 13, &v, m);
}
