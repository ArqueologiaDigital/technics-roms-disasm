/* Functions of file_io/single_load.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SingleLoadDstFunc SingleLoadSrcFunc TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_PAINT     0x1c0000bL
#define EVT_PARA_DRAW 0x1c0000fL
extern long SingleLoadSrcFunc(long, long, long);
extern long SingleLoadDstFunc(long, long, long);
extern void SingleLoad_SyncSoundMemCursorGroup(long kind, unsigned char n, unsigned char *a, unsigned char *b);

void SingleLoad_SyncSoundMemCursorGroup(long kind, unsigned char n, unsigned char *a, unsigned char *b)
{
	unsigned char l;

	l = n + n;
	if (*a < l && *b < l)
		return;
	if (*a >= l && *b >= l)
		return;
	switch (kind) {
	case 5:
	case 6:
		*b = *a;
		SingleLoadDstFunc(0, EVT_PARA_DRAW, 0);
		break;
	case 7:
	case 8:
		*a = *b;
		SingleLoadSrcFunc(0, EVT_PAINT, 0);
		break;
	}
}

