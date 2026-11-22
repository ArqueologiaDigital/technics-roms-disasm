/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/scoop_editor_data_m0.c (2026-11-21-5-p6-r60)
   sha256 cb2969306088181a5781e855ee3d593c2e8f2093f2a18b7ab1dcb7faa771c25d (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
	unsigned char y[1];

	SeMenu_LoadPartParam(1, &x);
	SeMenu_LoadPartParam(2, &z);
	if (SeMenu_StepNoteParamInRange(a, 0, (unsigned char)(x + 1), (unsigned char)(z - 1)) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(0, &y[0]);
		SeMenu_RegisterElement_Extended(part, 26, &y[0], 127);
		SeTitle_DrawField(44, 0);
		SeMenu_DrawKeyScaleGraph(0, 0);
	}
	SeMenu_BindDialToColumn(5);
}
