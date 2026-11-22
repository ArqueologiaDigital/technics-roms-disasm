/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_27r1m129b.c (2026-11-22-7-p6-r74)
   sha256 9cc191a544b2c6aac4f0da8ecbb8dec68ea21019e5b68813bac304d497dd24a0 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
void SeCtr2_GetGroupBase(unsigned char s, unsigned char *p)
{
	switch (s) {
	default:
		*p = 23;
		break;
	case 2:
		*p = 26;
		break;
	case 5:
		*p = 35;
		break;
	case 6:
		*p = 38;
		break;
	}
}
