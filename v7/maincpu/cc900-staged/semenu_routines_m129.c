/* Functions of audio/semenu_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void SeCtr2_GetGroupBase(unsigned char s, unsigned char *p);
extern void SeCtr2_GetKitGroupBase(unsigned char s, unsigned char *p);

void SeCtr2_GetGroupBase(unsigned char s, unsigned char *p)
{
	unsigned char v;

	switch (s) {
	case 2:
		v = 26;
		break;
	case 5:
		v = 35;
		break;
	case 6:
		v = 38;
		break;
	default:
		v = 23;
		break;
	}
	*p = v;
}

void SeCtr2_GetKitGroupBase(unsigned char s, unsigned char *p)
{
	unsigned char v;

	switch (s) {
	case 2:
		v = 24;
		break;
	case 5:
		v = 33;
		break;
	case 6:
		v = 36;
		break;
	default:
		v = 21;
		break;
	}
	*p = v;
}
