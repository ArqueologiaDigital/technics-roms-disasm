/* Functions of audio/presentation_sound_nav.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: DrawTitleBar ScreenProc */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void ChangeWallPalette(int n);
extern void SetWallColor(int c);

void SetWallColor(int c)
{
	int n;

	switch (c) {
	default:
		n = 0;
		break;
	case 0xf8:
		n = 2;
		break;
	case 2:
		n = 4;
		break;
	case 0xf9:
		n = 6;
		break;
	case 1:
		n = 8;
		break;
	}
	ChangeWallPalette(n);
}
