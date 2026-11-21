/* Functions of audio/sound_editor_ui.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
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
	unsigned char y[1];

	SeMenu_LoadPartParam(1, &x);
	x &= 0x7f;
	if (SeMenu_StepNoteParamInRange(a, 2, 0, x) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(2, &y[0]);
		SeMenu_RegisterElement_Extended(part, 31, &y[0], 127);
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
	unsigned char y[1];

	SeMenu_LoadPartParam(2, &x);
	SeMenu_LoadPartParam(3, &z);
	x &= 0x7f;
	z &= 0x7f;
	if (SeMenu_StepNoteParamInRange(a, 1, x, z) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(1, &y[0]);
		SeMenu_RegisterElement_Extended(part, 30, &y[0], 127);
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

void SeTonRan1_OnColumn6(unsigned char a)
{
	unsigned char x;
	unsigned char part;
	unsigned char y[1];

	SeMenu_LoadPartParam(3, &x);
	x &= 0x7f;
	if (SeMenu_StepNoteParamInRange(a, 4, x, 127) == 1) {
		SeMenu_ValidatePartNumber(&part);
		SeMenu_LoadPartParam(4, &y[0]);
		SeMenu_RegisterElement_Extended(part, 33, &y[0], 127);
		SeTitle_DrawField(36, 4);
		SeMenu_DrawPartRangeGraph(0, part, 1);
	}
	SeMenu_BindDialToColumn(6);
}
