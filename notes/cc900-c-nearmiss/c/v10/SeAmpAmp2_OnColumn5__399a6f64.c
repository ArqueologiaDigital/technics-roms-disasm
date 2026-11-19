/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_7m128c.c (2026-11-19-43-p6-r48)
   sha256 399a6f64e1bd2509ac73c81b653a72c356154c5c058429d4720d26812a60af59 (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern unsigned char SeMenu_StepNoteParamInRange(int, int, int, int);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_DrawKeyScaleGraph(int, int);
extern void SeMenu_BindDialToColumn(int col);
void SeAmpAmp2_OnColumn5(unsigned char a)
{
	unsigned char part;
	unsigned char x;
	unsigned char z;
	unsigned char y;

	SeMenu_LoadPartParam(1, &x);
	SeMenu_LoadPartParam(2, &z);
	if (SeMenu_StepNoteParamInRange(a, 0, (unsigned char)(x + 1), (unsigned char)(z - 1)) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(0, &y);
		SeMenu_RegisterElement_Extended(part, 26, &y, 127);
		SeTitle_DrawField(44, 0);
		SeMenu_DrawKeyScaleGraph(0, 0);
	}
	SeMenu_BindDialToColumn(5);
}
