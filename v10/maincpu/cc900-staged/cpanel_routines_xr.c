/* Functions of ui/cpanel_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char __near ram_8e5e;
extern unsigned char __near ram_8e4b;
extern unsigned char __near ram_8e60;
extern unsigned char __near ram_8e50;

int CPanel_CheckSpecialCombos(void)
{
	int r;

	if (ram_8e5e == 108) r = 3;
	else if (ram_8e4b == 112) r = 2;
	else if (ram_8e60 == 56) r = 1;
	else if (ram_8e50 == 15) r = 4;
	else r = 0;
	return r;
}
