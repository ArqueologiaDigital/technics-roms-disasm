/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_32r1m269a.c (2026-11-22-17-p6-r84)
   sha256 5cc2684e3b89efdbd50ea6ae4d5e77946d04b13c1e80398e9c4bcfd1ef6b1241 (tar-sha256); compiled at -O3 -Xr */
#define EVT_PAINT               0x1c0000bL
#define EVT_PARA_DRAW           0x1c0000fL
#define EVT_PS_FILE_NAME_BOX_ID 0x1e50004L
struct mtxt { unsigned char s[8]; };
extern struct mtxt __near ram_8336[];
extern unsigned char __near ram_8926[];
extern long __near ram_8332;
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
