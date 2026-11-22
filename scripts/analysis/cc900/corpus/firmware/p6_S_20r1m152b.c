/* Phase 6, lane_p6 helper S, round 1 of 2026-11-20, hand source audio/sound_editor_ui.s (m152), form b: the TONE
   RANGE column handlers SeTonRan1_OnColumn3-6, first probes.  The SeAmpAmp2_OnColumn4 shape (p6_M_9m128c.c, r51
   +38) with the bounds' bit 7 cleared and SeMenu_DrawPartRangeGraph(0, part, 1) for the graph.  The one spot
   left in that shape: the ROM loads the part into WA, then &y into XDE, then pushes 127, then BC = field; V4.23
   pushed 127 before taking &y, as if a scalar's address were a constant.  The built SeMenu_CyclePartLfoState
   passes `&val[0]` of an array and V4.23 takes that address BEFORE its push (as the ROM here): form a declares y
   as a one-byte array; form
   b keeps y scalar and assigns the arguments to locals just before the call, the part first, then the
   address (`p = part; q = &y;`): a variable's address is computed where it is assigned.
   cc900-options: -O3 -Xr
*/
/* (no module-local callee: every call here is an absolute `call` in the ROM) */

extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern unsigned char SeMenu_StepNoteParamInRange(int, int, int, int);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_DrawPartRangeGraph(int, int, int);
extern void SeMenu_BindDialToColumn(int col);
extern void SeTonRan1_OnColumn3(unsigned char a);
extern void SeTonRan1_OnColumn4(unsigned char a);
extern void SeTonRan1_OnColumn5(unsigned char a);
extern void SeTonRan1_OnColumn6(unsigned char a);

void SeTonRan1_OnColumn3(unsigned char a)
{
	unsigned char x;
	unsigned char part;
	unsigned char y;
	unsigned int p;
	unsigned char *q;

	SeMenu_LoadPartParam(1, &x);
	x &= 0x7f;
	if (SeMenu_StepNoteParamInRange(a, 2, 0, x) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(2, &y);
		p = part;
		q = &y;
		SeMenu_RegisterElement_Extended(p, 31, q, 127);
		SeTitle_DrawField(36, 2);
		SeMenu_DrawPartRangeGraph(0, part, 1);
	}
	SeMenu_BindDialToColumn(3);
}

void SeTonRan1_OnColumn4(unsigned char a)
{
	unsigned char x;
	unsigned char z;
	unsigned char part;
	unsigned char y;
	unsigned int p;
	unsigned char *q;

	SeMenu_LoadPartParam(2, &x);
	SeMenu_LoadPartParam(3, &z);
	x &= 0x7f;
	z &= 0x7f;
	if (SeMenu_StepNoteParamInRange(a, 1, x, z) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(1, &y);
		p = part;
		q = &y;
		SeMenu_RegisterElement_Extended(p, 30, q, 127);
		SeTitle_DrawField(36, 1);
		SeMenu_DrawPartRangeGraph(0, part, 1);
	}
	SeMenu_BindDialToColumn(4);
}

void SeTonRan1_OnColumn5(unsigned char a)
{
	unsigned char x;
	unsigned char z;
	unsigned char part;
	unsigned char y;
	unsigned int p;
	unsigned char *q;

	SeMenu_LoadPartParam(1, &x);
	SeMenu_LoadPartParam(4, &z);
	x &= 0x7f;
	z &= 0x7f;
	if (SeMenu_StepNoteParamInRange(a, 3, x, z) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(3, &y);
		p = part;
		q = &y;
		SeMenu_RegisterElement_Extended(p, 32, q, 127);
		SeTitle_DrawField(36, 3);
		SeMenu_DrawPartRangeGraph(0, part, 1);
	}
	SeMenu_BindDialToColumn(5);
}

void SeTonRan1_OnColumn6(unsigned char a)
{
	unsigned char x;
	unsigned char part;
	unsigned char y;
	unsigned int p;
	unsigned char *q;

	SeMenu_LoadPartParam(3, &x);
	x &= 0x7f;
	if (SeMenu_StepNoteParamInRange(a, 4, x, 127) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(4, &y);
		p = part;
		q = &y;
		SeMenu_RegisterElement_Extended(p, 33, q, 127);
		SeTitle_DrawField(36, 4);
		SeMenu_DrawPartRangeGraph(0, part, 1);
	}
	SeMenu_BindDialToColumn(6);
}
