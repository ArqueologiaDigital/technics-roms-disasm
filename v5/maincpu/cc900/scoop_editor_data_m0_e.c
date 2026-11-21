/* Functions of display/scoop_editor_data.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

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
