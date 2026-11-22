/* Phase 6, lane_p6 helper S, round 1 of 2026-11-20, module 128 (display/scoop_editor_data.s), form a: the RANGE
   column handlers that call SeMenu_RegisterElement_Extended (SeAmpAmp2 / SeAmpEnv2 / SeFilFil2 OnColumn4-6).
   Base: p6_M_9m128c.c (run r51: +38, everything before the RegisterElement_Extended call matches).  The one spot:
   the ROM loads the part into WA, then &y into XDE, then pushes 127, then BC = field; V4.23 pushed 127 before
   taking &y, as if a scalar's address were a constant.  The built SeMenu_CyclePartLfoState passes `&val[0]` of an
   array and V4.23 takes that address BEFORE its push (as the ROM here): form a declares y as a one-byte array and
   passes &y[0].
   cc900-options: -O3 -Xr
*/
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
extern void SeAmpEnv2_OnColumn4(unsigned char a);
extern void SeAmpEnv2_OnColumn5(unsigned char a);
extern void SeAmpEnv2_OnColumn6(unsigned char a);
extern void SeFilFil2_OnColumn4(unsigned char a);
extern void SeFilFil2_OnColumn5(unsigned char a);
extern void SeFilFil2_OnColumn6(unsigned char a);

void SeAmpAmp2_OnColumn4(unsigned char a)
{
	unsigned char part;
	unsigned char x;
	unsigned char y[1];

	SeMenu_LoadPartParam(0, &x);
	if (SeMenu_StepNoteParamInRange(a, 1, 0, (unsigned char)(x - 1)) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(1, &y[0]);
		SeMenu_RegisterElement_Extended(part, 27, &y[0], 127);
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

void SeAmpAmp2_OnColumn6(unsigned char a)
{
	unsigned char part;
	unsigned char x;
	unsigned char y[1];

	SeMenu_LoadPartParam(0, &x);
	if (SeMenu_StepNoteParamInRange(a, 2, (unsigned char)(x + 1), 127) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(2, &y[0]);
		SeMenu_RegisterElement_Extended(part, 28, &y[0], 127);
		SeTitle_DrawField(44, 2);
		SeMenu_DrawKeyScaleGraph(0, 0);
	}
	SeMenu_BindDialToColumn(6);
}

void SeAmpEnv2_OnColumn4(unsigned char a)
{
	unsigned char part;
	unsigned char x;
	unsigned char y[1];

	SeMenu_LoadPartParam(2, &x);
	if (SeMenu_StepNoteParamInRange(a, 3, 0, (unsigned char)(x - 1)) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(3, &y[0]);
		SeMenu_RegisterElement_Extended(part, 49, &y[0], 127);
		SeTitle_DrawField(46, 3);
		SeMenu_DrawKeyScaleGraph(2, 0);
	}
	SeMenu_BindDialToColumn(4);
}

void SeAmpEnv2_OnColumn5(unsigned char a)
{
	unsigned char part;
	unsigned char x;
	unsigned char z;
	unsigned char y[1];

	SeMenu_LoadPartParam(4, &z);
	SeMenu_LoadPartParam(3, &x);
	if (SeMenu_StepNoteParamInRange(a, 2, (unsigned char)(x + 1), (unsigned char)(z - 1)) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(2, &y[0]);
		SeMenu_RegisterElement_Extended(part, 48, &y[0], 127);
		SeTitle_DrawField(46, 2);
		SeMenu_DrawKeyScaleGraph(2, 0);
	}
	SeMenu_BindDialToColumn(5);
}

void SeAmpEnv2_OnColumn6(unsigned char a)
{
	unsigned char part;
	unsigned char x;
	unsigned char y[1];

	SeMenu_LoadPartParam(2, &x);
	if (SeMenu_StepNoteParamInRange(a, 4, (unsigned char)(x + 1), 127) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(4, &y[0]);
		SeMenu_RegisterElement_Extended(part, 50, &y[0], 127);
		SeTitle_DrawField(46, 4);
		SeMenu_DrawKeyScaleGraph(2, 0);
	}
	SeMenu_BindDialToColumn(6);
}

void SeFilFil2_OnColumn4(unsigned char a)
{
	unsigned char part;
	unsigned char x;
	unsigned char y[1];

	SeMenu_LoadPartParam(0, &x);
	if (SeMenu_StepNoteParamInRange(a, 1, 0, (unsigned char)(x - 1)) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(1, &y[0]);
		SeMenu_RegisterElement_Extended(part, 58, &y[0], 127);
		SeTitle_DrawField(54, 1);
		SeMenu_DrawKeyScaleGraph(0, 0);
	}
	SeMenu_BindDialToColumn(4);
}

void SeFilFil2_OnColumn5(unsigned char a)
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
		SeMenu_RegisterElement_Extended(part, 57, &y[0], 127);
		SeTitle_DrawField(54, 0);
		SeMenu_DrawKeyScaleGraph(0, 0);
	}
	SeMenu_BindDialToColumn(5);
}

void SeFilFil2_OnColumn6(unsigned char a)
{
	unsigned char part;
	unsigned char x;
	unsigned char y[1];

	SeMenu_LoadPartParam(0, &x);
	if (SeMenu_StepNoteParamInRange(a, 2, (unsigned char)(x + 1), 127) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(2, &y[0]);
		SeMenu_RegisterElement_Extended(part, 59, &y[0], 127);
		SeTitle_DrawField(54, 2);
		SeMenu_DrawKeyScaleGraph(0, 0);
	}
	SeMenu_BindDialToColumn(6);
}
