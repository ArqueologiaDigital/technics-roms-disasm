/* Phase 6, lane_p6 helper M, round 8, module 128 (display/scoop_editor_data.s), form d: SeAmpAmp2_OnColumn4/5/6
   retry (run r48: +38 / +53 / +38 @O3Xr).  The ROM takes &y into XDE before pushing the stack argument (127) of
   SeMenu_RegisterElement_Extended; V4.23 pushed first: the frame address assigned to a variable before the call
   (lane_p6's idiom 1).  Everything else as p6_M_7m128c.c. */
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
	unsigned char *q;

	SeMenu_LoadPartParam(0, &x);
	if (SeMenu_StepNoteParamInRange(a, 1, 0, (unsigned char)(x - 1)) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(1, &y);
		q = &y;
		SeMenu_RegisterElement_Extended(part, 27, q, 127);
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
	unsigned char *q;

	SeMenu_LoadPartParam(1, &x);
	SeMenu_LoadPartParam(2, &z);
	if (SeMenu_StepNoteParamInRange(a, 0, (unsigned char)(x + 1), (unsigned char)(z - 1)) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(0, &y);
		q = &y;
		SeMenu_RegisterElement_Extended(part, 26, q, 127);
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
