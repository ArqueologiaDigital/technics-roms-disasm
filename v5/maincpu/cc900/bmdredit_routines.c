/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_2728;
extern unsigned char __near NOTEEDIT_BASE_KEY;
extern unsigned int __near ram_2784;
extern unsigned char WidgetData_DrawbarPositionTable[];

void BmDrEdit_SetupScrollRegion(unsigned char *a, unsigned char *b)
{
	if (ram_2728 & 1) {
		*a = ram_2784;
		*b = ram_2784;
		*b += 11;
		return;
	}
	*a = WidgetData_DrawbarPositionTable[(int)NOTEEDIT_BASE_KEY * 2];
	*b = WidgetData_DrawbarPositionTable[(int)NOTEEDIT_BASE_KEY * 2 + 1];
}

extern unsigned int __near ram_2804;
extern unsigned int __near ram_27a8;
extern unsigned int __near ram_27aa;
extern unsigned int __near ram_27ac;
extern unsigned int __near ram_27ae;
extern unsigned int ram_210b2;
extern unsigned char ram_210b0;
extern unsigned int BmDrEdit_RenderVertical_Table[];

void BmDrEdit_RenderSecondaryVert(void)
{
	ram_27a8 = (ram_2804 >> 2) + 0x5b;
	ram_27aa = (ram_210b2 >> 2) + ram_27a8;
	ram_27ae = (ram_27ac = BmDrEdit_RenderVertical_Table[ram_210b0]) + 3;
	ram_27ac -= 2;
	ram_27ae += 2;
}
