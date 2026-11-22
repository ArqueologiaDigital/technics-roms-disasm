/* Functions of file_io/medley.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FormatMedleyNumber */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_PAINT               0x1c0000bL
#define EVT_PARA_DRAW           0x1c0000fL
#define EVT_PS_FILE_NAME_BOX_ID 0x1e50004L
struct mtxt { unsigned char s[8]; };
extern struct mtxt __near ram_8336[];
extern unsigned char __near ram_8926[];
extern long __near ram_8332;
extern void FormatMedleyNumber();
extern long ApPostEvent(long, long, void *);
extern long FmmDiskMedley1Func(long obj, long evt, long par);

long FmmDiskMedley1Func(long obj, long evt, long par)
{
	unsigned int i;

	switch (evt) {
	case EVT_PS_FILE_NAME_BOX_ID:
		ram_8332 = par;
		break;
	case EVT_PAINT:
		for (i = 0; i < 10; i++) {
			FormatMedleyNumber(ram_8336[i].s, ram_8926[i], i);
			ApPostEvent(ram_8332, EVT_PARA_DRAW, ram_8336[i].s);
		}
		break;
	}
	return 0;
}
