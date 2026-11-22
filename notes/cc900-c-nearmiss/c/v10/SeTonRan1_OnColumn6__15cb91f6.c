/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_20r1m152a.c (2026-11-21-2-p6-r58)
   sha256 15cb91f6fd3951502c81a691421d35ccb014fe5fc18e5b59d174705e839cea90 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern unsigned char SeMenu_StepNoteParamInRange(int, int, int, int);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_DrawPartRangeGraph(int, int, int);
extern void SeMenu_BindDialToColumn(int col);
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
