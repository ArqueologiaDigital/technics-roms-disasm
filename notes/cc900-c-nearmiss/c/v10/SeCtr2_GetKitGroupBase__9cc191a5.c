/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_27r1m129b.c (2026-11-22-7-p6-r74)
   sha256 9cc191a544b2c6aac4f0da8ecbb8dec68ea21019e5b68813bac304d497dd24a0 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
void SeCtr2_GetKitGroupBase(unsigned char s, unsigned char *p)
{
	switch (s) {
	default:
		*p = 21;
		break;
	case 2:
		*p = 24;
		break;
	case 5:
		*p = 33;
		break;
	case 6:
		*p = 36;
		break;
	}
}
