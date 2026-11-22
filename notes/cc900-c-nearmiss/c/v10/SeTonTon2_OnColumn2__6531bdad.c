/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_20r2m152g.c (2026-11-21-5-p6-r60)
   sha256 6531bdada219431f1444fa6b8eb07e7613837e0ce4aeb877e23b450b2ef5b736 (tar-sha256); compiled at -O3 -XS -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern unsigned char SeMenu_BitShiftMask_End(int, int);
extern unsigned char SeMenu_BitShiftMask(int, int);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_BindDialToColumn(int col);
void SeTonTon2_OnColumn2(unsigned char a)
{
	unsigned char part;
	unsigned char mask;
	unsigned char val;
	unsigned char m;
	unsigned char sel;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(1, &mask);
	SeMenu_LoadPartParam((unsigned char)(part + 1), &val);
	sel = SeMenu_BitShiftMask_End(mask, (unsigned char)(part + part - 2));
	sel &= 3;
	if ((a & 0x7f) == 0) {
		if (val & 0x80)
			return;
		if (sel == 1) {
			val |= 0x80;
			sel = 0;
		} else
			sel++;
	} else {
		if (val & 0x80) {
			val &= 0x7f;
			sel = 1;
		} else {
			if (sel == 0)
				return;
			sel--;
		}
	}
	m = SeMenu_BitShiftMask(3, (unsigned char)(part + part - 2));
	mask &= ~m;
	mask |= SeMenu_BitShiftMask(sel, (unsigned char)(part + part - 2));
	SeMenu_RegisterElement_Extended(part, 0, &val, 128);
	SeMenu_RegisterElement_Extended(0, 18, &mask, m);
	SeMenu_StorePartParam((unsigned char)(part + 1), val);
	SeMenu_StorePartParam(1, mask);
	SeTitle_DrawField(35, 1);
	SeMenu_BindDialToColumn(2);
}
