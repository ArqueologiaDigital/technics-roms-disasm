/* lane_p6 helper L, round 28r1, form a: kn5000_v10_program.s (module 0), Boot_ParseTableDataTimestamp /
   Boot_ParseSubCPUTimestamp (families28_L, 2 x 13 B): the build number in the table-data ROM's (0x9fffc4) and the
   sub-CPU payload's (0x87fff5) trailer, read by the __cdecl atoi-like ParseInt16 (one 32-bit stack argument,
   `push xwa`, removed with `inc 4, xsp`), returned.
   Form a: the trailer addresses as constant pointers.
   cc900-options: -O3 -Xr
*/

extern int __cdecl ParseInt16(char *);

int Boot_ParseTableDataTimestamp(void)
{
	return ParseInt16((char *)0x9fffc4L);
}

int Boot_ParseSubCPUTimestamp(void)
{
	return ParseInt16((char *)0x87fff5L);
}
