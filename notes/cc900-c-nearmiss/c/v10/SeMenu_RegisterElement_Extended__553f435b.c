/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_2m129b.c (2026-11-19-19-p6-r43)
   sha256 553f435ba3ec7547aa3e02cc38ed29b346be62827ab76c6a7c279264a58c5c74 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct seobj { unsigned char flags, master, field, one, value, mask, x6, x7, x8; };
extern void SeMenu_LoadMasterPtr(unsigned char *m);
extern void SeMenu_SetObjectFlags(int);
extern void SeMenu_FlushDisplayObj(struct seobj *);
int SeMenu_RegisterElement_Extended(unsigned char id, unsigned char field, unsigned char *v, unsigned char mask)
{
	unsigned char m;
	struct seobj o;
	unsigned char *p;
	unsigned char *e;

	p = (unsigned char *)&o;
	e = p + 9;
	do
		*p++ = 0;
	while (p < e);
	SeMenu_LoadMasterPtr(&m);
	o.flags = 0x80;
	o.flags |= 0x08;
	o.master = m;
	o.field = field;
	o.one = 1;
	o.value = *v;
	o.mask = mask;
	SeMenu_SetObjectFlags(id);
	SeMenu_FlushDisplayObj(&o);
	return 0;
}
