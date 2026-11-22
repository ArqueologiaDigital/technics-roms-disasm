/* lane_p6 helper U, round 32r1: roots of file_io/medley.s, module 269 (-O3 -Xr).  FmmDiskMedley1Func is
   FmmDiskMedley2Func's twin (slots 0-9 and 10-19 of the disk medley list). */
/* cc900-module: FormatMedleyNumber */

#define EVT_PAINT               0x1c0000bL
#define EVT_PARA_DRAW           0x1c0000fL
#define EVT_PS_FILE_NAME_BOX_ID 0x1e50004L
struct mtxt { unsigned char s[8]; };
extern struct mtxt __near ram_8336[];
extern struct mtxt ram_833a[];
extern unsigned char __near ram_8926[];
extern long __near ram_8332;
extern long __near ram_8386;
extern void FormatMedleyNumber();
extern long ApPostEvent(long, long, void *);

long FmmDiskMedley1Func(long obj, long evt, long par)
{
	unsigned int i;

	if (evt == EVT_PAINT) {
		for (i = 0; i < 10; i++) {
			FormatMedleyNumber(ram_8336[i].s, ram_8926[i], i);
			ApPostEvent(ram_8332, EVT_PARA_DRAW, ram_8336[i].s);
		}
	} else if (evt == EVT_PS_FILE_NAME_BOX_ID) {
		ram_8332 = par;
	}
	return 0;
}

long FmmDiskMedley2Func(long obj, long evt, long par)
{
	unsigned int i;

	if (evt == EVT_PAINT) {
		for (i = 10; i < 20; i++) {
			FormatMedleyNumber(ram_833a[i].s, ram_8926[i], i - 10);
			ApPostEvent(ram_8386, EVT_PARA_DRAW, ram_833a[i].s);
		}
	} else if (evt == EVT_PS_FILE_NAME_BOX_ID) {
		ram_8386 = par;
	}
	return 0;
}
