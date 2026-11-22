/* lane_p6 helper J, round 27r1, form a: module 129 (audio/semenu_routines.s), the family SeCtr2_GetGroupBase /
   SeCtr2_GetKitGroupBase (families27_J, 2 x 29 B): the selection byte A (2, 5, 6, other) picks a base (26 / 35 /
   38 / 23, kit 24 / 33 / 36 / 21) stored through XBC.  V4.23 compares case labels in reverse source order (6, 5, 2).
   Form a: a switch into a byte local, one store after it; default last.
   cc900-options: -O3 -Xr
*/

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
