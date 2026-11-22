/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sound_editor_ui_m0.c (2026-11-21-5-p6-r60)
   sha256 eebeff521df4291489dd86daa4841a6bbb435bdc8184b31e5837d1bf887f669c (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern unsigned char SeMenu_StepNoteParamInRange(int, int, int, int);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_DrawPartRangeGraph(int, int, int);
extern void SeMenu_BindDialToColumn(int col);
void SeTonRan1_OnColumn5(unsigned char a)
{
	unsigned char x;
	unsigned char z;
	unsigned char part;
	unsigned char y[1];

	SeMenu_LoadPartParam(1, &x);
	SeMenu_LoadPartParam(4, &z);
	x &= 0x7f;
	z &= 0x7f;
	if (SeMenu_StepNoteParamInRange(a, 3, x, z) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(3, &y[0]);
		SeMenu_RegisterElement_Extended(part, 32, &y[0], 127);
		SeTitle_DrawField(36, 3);
		SeMenu_DrawPartRangeGraph(0, part, 1);
	}
	SeMenu_BindDialToColumn(5);
}
