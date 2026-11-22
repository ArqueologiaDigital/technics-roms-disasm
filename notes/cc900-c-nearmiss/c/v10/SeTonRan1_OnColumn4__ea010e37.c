/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_20r1m152c.c (2026-11-21-2-p6-r58)
   sha256 ea010e37c2bbe8c4e35bcdd4c10f277a66cfa73f3f7bbe62a0ebca4bde02aeb1 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern unsigned char SeMenu_StepNoteParamInRange(int, int, int, int);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_DrawPartRangeGraph(int, int, int);
extern void SeMenu_BindDialToColumn(int col);
void SeTonRan1_OnColumn4(unsigned char a)
{
	unsigned char x;
	unsigned char z;
	unsigned char part;
	unsigned char y[1];

	SeMenu_LoadPartParam(2, &x);
	SeMenu_LoadPartParam(3, &z);
	x &= 0x7f;
	z &= 0x7f;
	if (SeMenu_StepNoteParamInRange(a, 1, x, z) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(1, y);
		SeMenu_RegisterElement_Extended(part, 30, y, 127);
		SeTitle_DrawField(36, 1);
		SeMenu_DrawPartRangeGraph(0, part, 1);
	}
	SeMenu_BindDialToColumn(4);
}
