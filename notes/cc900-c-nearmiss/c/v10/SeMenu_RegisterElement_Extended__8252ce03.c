/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_4m129a.c (2026-11-19-29-p6-r46)
   sha256 8252ce031a8e217bd71c1c5525243c2402129978bcf3fde3ebdef2b3474dbf4d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct seobj { unsigned char flags, master, field, one, value, mask, x6, x7, x8; };
extern void SeMenu_LoadMasterPtr(unsigned char *m);
extern void SeMenu_SetObjectFlags(int);
extern void SeMenu_FlushDisplayObj(struct seobj *);
int SeMenu_RegisterElement_Extended(unsigned char id, unsigned char field, unsigned char *v, unsigned int mask)
{
	unsigned char m;
	struct seobj o;
	unsigned char *e;
	unsigned char *p;
	unsigned char f;

	p = (unsigned char *)&o;
	e = p + 9;
	do
		*p++ = 0;
	while (p < e);
	SeMenu_LoadMasterPtr(&m);
	f = 0x80;
	o.flags = f;
	f |= 0x08;
	o.flags = f;
	o.master = m;
	o.field = field;
	o.one = 1;
	o.value = *v;
	o.mask = mask;
	SeMenu_SetObjectFlags(id);
	SeMenu_FlushDisplayObj(&o);
	return 0;
}
