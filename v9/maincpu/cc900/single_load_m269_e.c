/* Functions of file_io/single_load.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_PARA_DRAW 0x1c0000fL
extern unsigned char __near SINGLE_LOAD_ALL;
extern unsigned char __near SLOAD_SRC_SOUND_POS;
extern char __near SINGLE_LOAD_SRC_ROWS[];
extern char *SingleLoadSrc_ReadTmUserKitEntryName(unsigned int);
extern char *SingleLoadSrc_ReadTmSoundName(unsigned int);
extern void FileIO_CopyString(char *, char *);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
extern void SingleLoadSrc_DrawSoundMemItemName(long obj, unsigned char n);

void SingleLoadSrc_DrawSoundMemItemName(long obj, unsigned char n)
{
	char *p;
	unsigned char l;

	if (SINGLE_LOAD_ALL != 0)
		return;
	SINGLE_LOAD_SRC_ROWS[63] = 3;
	l = n + n;
	p = &SINGLE_LOAD_SRC_ROWS[64];
	if (SLOAD_SRC_SOUND_POS >= l)
		FileIO_CopyString(p, SingleLoadSrc_ReadTmUserKitEntryName((unsigned char)(SLOAD_SRC_SOUND_POS - l)));
	else
		FileIO_CopyString(p, SingleLoadSrc_ReadTmSoundName(SLOAD_SRC_SOUND_POS));
	TrimAndPadSmfFilename((unsigned char *)&SINGLE_LOAD_SRC_ROWS[64], 16);
	ApPostEvent(obj, EVT_PARA_DRAW, (long)&SINGLE_LOAD_SRC_ROWS[63]);
}
