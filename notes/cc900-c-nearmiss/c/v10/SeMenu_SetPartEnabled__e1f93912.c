/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_16m129b.c (2026-11-16-118-p6-r23)
   sha256 e1f939121c7ad447e188656d758a6d6e67dbc8a81d34b27530935ef406815dbb (tar-sha256); compiled at -O3 -Xr */
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
	unsigned char n;

	if (part >= 1 && part <= 4) {
		SeMenu_LoadObjEntries(&obj);
		n = part * 2 - 2;
		m = SeMenu_BitShiftMask(1, n);
		if (on == 0) SEMENU_PART_MASK &= ~m;
		else SEMENU_PART_MASK |= m;
		v = SEMENU_PART_MASK;
		if (obj == 0) SeMenu_RegisterElement_Extended(0, 17, &v, m);
		else SeMenu_SetupDisplayObject_Alt1(0, 13, &v, m);
	}
}
