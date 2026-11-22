/* lane_p6 helper J, round 27r1, form b: module 129 (audio/semenu_routines.s), the family SeCtr2_GetGroupBase /
   SeCtr2_GetKitGroupBase (families27_J, 2 x 29 B): the selection byte A (2, 5, 6, other) picks a base (26 / 35 /
   38 / 23, kit 24 / 33 / 36 / 21) stored through XBC.  V4.23 compares case labels in reverse source order (6, 5, 2).
   Form b: the store `*p = K` in every case (the ROM's shared `ld (xbc),a` would be V4.23's tail merge), default
   first.
   cc900-options: -O3 -Xr
*/

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
