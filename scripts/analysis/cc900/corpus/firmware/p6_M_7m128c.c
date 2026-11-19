/* Phase 6, lane_p6 helper M, round 7, module 128 (display/scoop_editor_data.s), form c: the AMP2 (key scale) page.
   SeAmpAmp2_OnColumn3: step parameter block 3 (range 255/0/50/206, popup 44, id 29); when the step reports 1, copy
   the block's value to part parameter 10 and redraw the key-scale graph.  Columns 4-6: step a note-range bound with
   SeMenu_StepNoteParamInRange (the other bound +-1 as its limit, 4th argument on the stack); when it moved,
   re-register the field (27 / 26 / 28), redraw its title field (__cdecl SeTitle_DrawField(44, n)) and the graph.
   SeAmpAmp2_OnSideRow1: both paths end in a tail jump in the ROM (an if / else of two calls).
   Address-taken locals in reverse declaration order (the frame's lowest slot declared last). */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

#define TT_SEAMPENV1 0x2d

extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern unsigned char SeMenu_StepNoteParamInRange(int, int, int, int);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_DrawKeyScaleGraph(int, int);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_ToggleSolo(void);
extern void SeAmpAmp2_OnColumn3(unsigned char a);
extern void SeAmpAmp2_OnColumn4(unsigned char a);
extern void SeAmpAmp2_OnColumn5(unsigned char a);
extern void SeAmpAmp2_OnColumn6(unsigned char a);
extern void SeAmpAmp2_OnSideRow1(unsigned char a);

void SeAmpAmp2_OnColumn3(unsigned char a)
{
	unsigned char part;
	unsigned char t;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(3, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (SeMenu_StepParamFieldAndSend(44, 3, part, 29, buf) == 1) {
		SeMenu_LoadPartParam(3, &t);
		SeMenu_StorePartParam(10, t);
		SeMenu_DrawKeyScaleGraph(0, 0);
	}
	SeMenu_BindDialToColumn(3);
}

void SeAmpAmp2_OnColumn4(unsigned char a)
{
	unsigned char part;
	unsigned char x;
	unsigned char y;

	SeMenu_LoadPartParam(0, &x);
	if (SeMenu_StepNoteParamInRange(a, 1, 0, (unsigned char)(x - 1)) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(1, &y);
		SeMenu_RegisterElement_Extended(part, 27, &y, 127);
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

void SeAmpAmp2_OnColumn6(unsigned char a)
{
	unsigned char part;
	unsigned char x;
	unsigned char y;

	SeMenu_LoadPartParam(0, &x);
	if (SeMenu_StepNoteParamInRange(a, 2, (unsigned char)(x + 1), 127) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(2, &y);
		SeMenu_RegisterElement_Extended(part, 28, &y, 127);
		SeTitle_DrawField(44, 2);
		SeMenu_DrawKeyScaleGraph(0, 0);
	}
	SeMenu_BindDialToColumn(6);
}

void SeAmpAmp2_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
	else
		SeMenu_SendEvent(TT_SEAMPENV1, 0);
}
