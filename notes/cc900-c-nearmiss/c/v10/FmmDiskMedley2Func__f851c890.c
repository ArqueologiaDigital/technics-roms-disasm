/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_32r1m269b.c (2026-11-22-17-p6-r84)
   sha256 f851c890832445d67da5375925bebaa1b62f9ed5504435265dd10e0dec71d1f4 (tar-sha256); compiled at -O3 -Xr */
#define EVT_PAINT               0x1c0000bL
#define EVT_PARA_DRAW           0x1c0000fL
#define EVT_PS_FILE_NAME_BOX_ID 0x1e50004L
struct mtxt { unsigned char s[8]; };
extern struct mtxt ram_833a[];
extern unsigned char __near ram_8926[];
extern long __near ram_8386;
extern void FormatMedleyNumber();
extern long ApPostEvent(long, long, void *);
long FmmDiskMedley2Func(long obj, long evt, long par)
{
	unsigned int i;

	switch (evt) {
	case EVT_PS_FILE_NAME_BOX_ID:
		ram_8386 = par;
		break;
	case EVT_PAINT:
		for (i = 10; i < 20; i++) {
			FormatMedleyNumber(ram_833a[i].s, ram_8926[i], i - 10);
			ApPostEvent(ram_8386, EVT_PARA_DRAW, ram_833a[i].s);
		}
		break;
	}
	return 0;
}
