/* Functions of file_io/medley.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -XS -Xr
*/
/* cc900-module: InitializeOperationState */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_PAINT      0x1c0000bL
#define EVT_PARA_DRAW  0x1c0000fL
extern unsigned char __near ram_86d4[];
extern long ApPostEvent(long, long, long);
extern unsigned char *FileIO_SearchAndLoadFile(void);
extern long DocDiskNameFunc(long obj, long evt, long par);

long DocDiskNameFunc(long obj, long evt, long par)
{
	unsigned char *s;
	int i;

	if (evt == EVT_PAINT) {
		s = FileIO_SearchAndLoadFile();
		for (i = 0; *s != 0 && i < 30; s++)
			if (*s != ' ')
				ram_86d4[i++] = *s;
		ram_86d4[i] = 0;
		while (ram_86d4[--i] == ' ' && i > 0)
			ram_86d4[i] = 0;
		ApPostEvent(par, EVT_PARA_DRAW, (long)ram_86d4);
	}
	return 0;
}
