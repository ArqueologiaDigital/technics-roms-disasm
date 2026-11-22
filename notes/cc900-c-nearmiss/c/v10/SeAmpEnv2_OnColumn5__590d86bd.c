/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_20r1m128b.c (2026-11-21-2-p6-r58)
   sha256 590d86bd5f4ce8935a6d52a20c0127045afcb516a42b55cf1f2c33029baf8eea (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern unsigned char SeMenu_StepNoteParamInRange(int, int, int, int);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_DrawKeyScaleGraph(int, int);
extern void SeMenu_BindDialToColumn(int col);
void SeAmpEnv2_OnColumn5(unsigned char a)
{
	unsigned char part;
	unsigned char x;
	unsigned char z;
	unsigned char y;
	unsigned int p;
	unsigned char *q;

	SeMenu_LoadPartParam(4, &z);
	SeMenu_LoadPartParam(3, &x);
	if (SeMenu_StepNoteParamInRange(a, 2, (unsigned char)(x + 1), (unsigned char)(z - 1)) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(2, &y);
		p = part;
		q = &y;
		SeMenu_RegisterElement_Extended(p, 48, q, 127);
		SeTitle_DrawField(46, 2);
		SeMenu_DrawKeyScaleGraph(2, 0);
	}
	SeMenu_BindDialToColumn(5);
}
