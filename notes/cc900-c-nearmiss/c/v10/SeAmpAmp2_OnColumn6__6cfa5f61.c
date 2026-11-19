/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_8m128d.c (2026-11-19-49-p6-r49)
   sha256 6cfa5f619332db740a4d6d21144a6463844b8bd6a72bac511a8ba9acffc5afa5 (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern unsigned char SeMenu_StepNoteParamInRange(int, int, int, int);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_DrawKeyScaleGraph(int, int);
extern void SeMenu_BindDialToColumn(int col);
void SeAmpAmp2_OnColumn6(unsigned char a)
{
	unsigned char part;
	unsigned char x;
	unsigned char y;
	unsigned char *q;

	SeMenu_LoadPartParam(0, &x);
	if (SeMenu_StepNoteParamInRange(a, 2, (unsigned char)(x + 1), 127) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(2, &y);
		q = &y;
		SeMenu_RegisterElement_Extended(part, 28, q, 127);
		SeTitle_DrawField(44, 2);
		SeMenu_DrawKeyScaleGraph(0, 0);
	}
	SeMenu_BindDialToColumn(6);
}
