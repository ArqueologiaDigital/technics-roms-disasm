/* Phase 6, lane_p6 helper M, round 9, module 128 (display/scoop_editor_data.s), form c: SeAmpAmp2_OnColumn4/5/6
   retry (run r49: +54 / +69 / +54).  The ROM evaluates RegisterElement_Extended's arguments in order: the part
   into WA, &y into XDE, then pushes 127, then BC = field; V4.23 pushed the constant before taking &y (r48) or took
   &y before the part (r49, `q = &y`).  This form passes the 127 through a local (lane_sub's idiom: a constant
   argument through a local is loaded in argument order). */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern unsigned char SeMenu_StepNoteParamInRange(int, int, int, int);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_DrawKeyScaleGraph(int, int);
extern void SeMenu_BindDialToColumn(int col);
extern void SeAmpAmp2_OnColumn4(unsigned char a);
extern void SeAmpAmp2_OnColumn5(unsigned char a);
extern void SeAmpAmp2_OnColumn6(unsigned char a);

void SeAmpAmp2_OnColumn4(unsigned char a)
{
	unsigned char part;
	unsigned char x;
	unsigned char y;
	unsigned int k;

	SeMenu_LoadPartParam(0, &x);
	if (SeMenu_StepNoteParamInRange(a, 1, 0, (unsigned char)(x - 1)) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(1, &y);
		k = 127;
		SeMenu_RegisterElement_Extended(part, 27, &y, k);
		SeTitle_DrawField(44, 1);
		SeMenu_DrawKeyScaleGraph(0, 0);
	}
	SeMenu_BindDialToColumn(4);
}

void SeAmpAmp2_OnColumn5(unsigned char a)
{
	unsigned char part;
	unsigned char x;
	unsigned char z;
	unsigned char y;
	unsigned int k;

	SeMenu_LoadPartParam(1, &x);
	SeMenu_LoadPartParam(2, &z);
	if (SeMenu_StepNoteParamInRange(a, 0, (unsigned char)(x + 1), (unsigned char)(z - 1)) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(0, &y);
		k = 127;
		SeMenu_RegisterElement_Extended(part, 26, &y, k);
		SeTitle_DrawField(44, 0);
		SeMenu_DrawKeyScaleGraph(0, 0);
	}
	SeMenu_BindDialToColumn(5);
}

void SeAmpAmp2_OnColumn6(unsigned char a)
{
	unsigned char part;
	unsigned char x;
	unsigned char y;
	unsigned int k;

	SeMenu_LoadPartParam(0, &x);
	if (SeMenu_StepNoteParamInRange(a, 2, (unsigned char)(x + 1), 127) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(2, &y);
		k = 127;
		SeMenu_RegisterElement_Extended(part, 28, &y, k);
		SeTitle_DrawField(44, 2);
		SeMenu_DrawKeyScaleGraph(0, 0);
	}
	SeMenu_BindDialToColumn(6);
}
