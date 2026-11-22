/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Y_22r1m232c.c (2026-11-21-21-p6-r66)
   sha256 1e6567c08c715fc9d94212fe454b41a0e7eaab4abc9ab89cfa1ba7c7391bfba7 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define EVT_GET_STRING               0x1e0003aL
#define EVT_GET_STRING_LENGTH        0x1e0007cL
#define EVT_GET_NAMING_MODE          0x1e00084L
extern char ram_20ca2[];
extern char ram_f280[];
extern char *__cdecl Strcpy(char *, char *);
extern char *__cdecl Strncpy(char *, char *, unsigned int);
long SeqNamingCheck(long obj, long evt, long p)
{
	switch (evt) {
	case EVT_GET_STRING:
		Strncpy(ram_20ca2, ram_f280, 16);
		ram_20ca2[16] = 0;
		Strcpy((char *)p, ram_20ca2);
		return obj;
	case EVT_GET_NAMING_MODE:
		return 0;
	case EVT_GET_STRING_LENGTH:
		return 16;
	}
	return 0;
}
