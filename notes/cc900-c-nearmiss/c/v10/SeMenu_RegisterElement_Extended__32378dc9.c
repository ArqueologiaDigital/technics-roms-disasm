/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_2m129a.c (2026-11-19-19-p6-r43)
   sha256 32378dc9228e44ae21e6a84bdb4e9f965843a58b76181062ede977b1d86bf4b5 (tar-sha256); compiled at -O3 -Xr
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

	for (p = (unsigned char *)&o; p < (unsigned char *)&o + 9; p++)
		*p = 0;
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
