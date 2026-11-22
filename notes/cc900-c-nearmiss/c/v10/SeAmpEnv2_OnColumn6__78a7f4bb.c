/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_20r1m128c.c (2026-11-21-2-p6-r58)
   sha256 78a7f4bb62cc44413f29fd1a1a7b916f4b4bee6a96137c8206efcdd3f2050496 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern unsigned char SeMenu_StepNoteParamInRange(int, int, int, int);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_DrawKeyScaleGraph(int, int);
extern void SeMenu_BindDialToColumn(int col);
void SeAmpEnv2_OnColumn6(unsigned char a)
{
	unsigned char part;
	unsigned char x;
	unsigned char y[1];

	SeMenu_LoadPartParam(2, &x);
	if (SeMenu_StepNoteParamInRange(a, 4, (unsigned char)(x + 1), 127) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(4, y);
		SeMenu_RegisterElement_Extended(part, 50, y, 127);
		SeTitle_DrawField(46, 4);
		SeMenu_DrawKeyScaleGraph(2, 0);
	}
	SeMenu_BindDialToColumn(6);
}
