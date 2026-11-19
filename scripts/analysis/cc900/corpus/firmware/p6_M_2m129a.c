/* Phase 6, lane_p6 helper M, round 2, module 129 (audio/semenu_routines.s), form a.
   SeMenu_ApplyFilter: store the part's filter parameter (index part + 13, or + 14 for the other object kind) with
   the table's byte 13, redraw the part display, then rebuild the part's 16-bit cell ram_6a2[part - 1] as
   (t[15] << 8) + t[14], stored after each step as the ROM does (like the built SeMenu_InitObjEntry).
   Frame: obj +0, the 36-byte table +2, the parameter +38. */
/* cc900-module: SeMenu_FillObjTable SeMenu_LoadObjEntries SeMenu_SetupPartDisplay SeMenu_StorePartParam */

extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_FillObjTable(unsigned char *t);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_SetupPartDisplay(int mode, unsigned char *t, int n);
extern unsigned int __near ram_6a2[];
extern void SeMenu_ApplyFilter(unsigned char a);

void SeMenu_ApplyFilter(unsigned char a)
{
	unsigned char tbl[36];
	unsigned char obj;
	unsigned int *p;
	unsigned char *t;

	SeMenu_LoadObjEntries(&obj);
	SeMenu_FillObjTable(tbl);
	if (obj == 0) {
		SeMenu_StorePartParam((unsigned char)(a + 13), tbl[13]);
		SeMenu_SetupPartDisplay(a, tbl, 13);
	} else {
		SeMenu_StorePartParam((unsigned char)(a + 14), tbl[13]);
		SeMenu_SetupPartDisplay((unsigned char)(a + 1), tbl, 13);
	}
	p = &ram_6a2[(unsigned char)(a - 1)];
	t = tbl;
	*p = t[15];
	*p <<= 8;
	*p += t[14];
}
