/* Functions of file_io/single_load.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_PARA_DRAW 0x1c0000fL
extern char __near SINGLE_LOAD_SRC_ROWS[];
extern unsigned char __near SLOAD_SRC_SOUND_POS;
extern char *SingleLoadSrc_ReadTmUserKitName(void);
extern void FileIO_CopyString(char *, char *);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
extern void SingleLoadSrc_DrawUserKitName(long obj, unsigned char n);

void SingleLoadSrc_DrawUserKitName(long obj, unsigned char n)
{
	char *p;

	if (SLOAD_SRC_SOUND_POS < (unsigned char)(n + n))
		return;
	SINGLE_LOAD_SRC_ROWS[21] = 1;
	p = &SINGLE_LOAD_SRC_ROWS[22];
	FileIO_CopyString(p, SingleLoadSrc_ReadTmUserKitName());
	TrimAndPadSmfFilename((unsigned char *)&SINGLE_LOAD_SRC_ROWS[22], 16);
	ApPostEvent(obj, EVT_PARA_DRAW, (long)&SINGLE_LOAD_SRC_ROWS[21]);
}
