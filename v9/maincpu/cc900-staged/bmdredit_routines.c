/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_2742;
extern unsigned char __near NOTEEDIT_BASE_KEY;
extern unsigned int __near ram_279e;
extern unsigned char WidgetData_DrawbarPositionTable[];

void BmDrEdit_SetupScrollRegion(unsigned char *a, unsigned char *b)
{
	if (ram_2742 & 1) {
		*a = ram_279e;
		*b = ram_279e;
		*b += 11;
		return;
	}
	*a = WidgetData_DrawbarPositionTable[(int)NOTEEDIT_BASE_KEY * 2];
	*b = WidgetData_DrawbarPositionTable[(int)NOTEEDIT_BASE_KEY * 2 + 1];
}

extern unsigned int __near ram_281e;
extern unsigned int __near ram_27c2;
extern unsigned int __near ram_27c4;
extern unsigned int __near ram_27c6;
extern unsigned int __near ram_27c8;
extern unsigned int ram_210b2;
extern unsigned char ram_210b0;
extern unsigned int BmDrEdit_RenderVertical_Table[];

void BmDrEdit_RenderSecondaryVert(void)
{
	ram_27c2 = (ram_281e >> 2) + 0x5b;
	ram_27c4 = (ram_210b2 >> 2) + ram_27c2;
	ram_27c8 = (ram_27c6 = BmDrEdit_RenderVertical_Table[ram_210b0]) + 3;
	ram_27c6 -= 2;
	ram_27c8 += 2;
}
