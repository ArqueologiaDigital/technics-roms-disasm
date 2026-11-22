/* lane_p6 helper L, round 28r1, form b: kn5000_v10_program.s (module 0), Boot_ParseTableDataTimestamp /
   Boot_ParseSubCPUTimestamp (see p6_L_28r1m0a.c).
   Form b: the constant pointer in a local first (the ROM loads XWA, then pushes it), the result in an int local.
   cc900-options: -O3 -Xr
*/

extern int __cdecl ParseInt16(char *);

int Boot_ParseTableDataTimestamp(void)
{
	char *p;
	int r;

	p = (char *)0x9fffc4L;
	r = ParseInt16(p);
	return r;
}

int Boot_ParseSubCPUTimestamp(void)
{
	char *p;
	int r;

	p = (char *)0x87fff5L;
	r = ParseInt16(p);
	return r;
}
