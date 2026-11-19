/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_14m152a.c (2026-11-19-92-p6-r57)
   sha256 22c7b9a48171c72ebec27ce931d00035feba8eb9fe66fe2fd75f038fbcd9b8ea (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_StorePartParam(int, int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_GetWriteMemSlot(unsigned char *);
extern void SeMenu_SetWriteMemSlot(int);
void SeWrtMem_OnSideRow4(unsigned char a)
{
	unsigned char slot;
	unsigned char d[4];
	unsigned char *p;
	unsigned char *q;

	if (a != 0)
		return;
	SeMenu_GetWriteMemSlot(&slot);
	if (slot == 0)
		return;
	slot--;
	SeMenu_SetWriteMemSlot(slot);
	p = d;
	*p = slot / 20;
	q = &p[1];
	*q = slot % 20;
	(*p)++;
	(*q)++;
	SeMenu_StorePartParam(0, *p);
	SeMenu_StorePartParam(1, d[1]);
	SeTitle_DrawField(62, 0);
	SeTitle_DrawField(62, 1);
}
