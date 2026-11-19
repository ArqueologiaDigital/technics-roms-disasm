/* Functions of file_io/single_load.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BuildSlotLabel NumToAscii_FormatNumber SingleLoadDst_DrawSongRows TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_PARA_DRAW      0x1c0000fL
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern char *NumToAscii_FormatNumber(unsigned int, unsigned int);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern char *BuildSlotLabel(unsigned int, unsigned int, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near SINGLE_LOAD_DST_ROWS[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SLOAD_DST_SONG;
extern char *StorageArea_UnitNames[];
extern char SLDstMemLabel_ColonSep[];
extern void SingleLoadDst_DrawSongRows(long obj);

void SingleLoadDst_DrawSongRows(long obj)
{
	char *p;

	p = SINGLE_LOAD_DST_ROWS;
	p[21] = 1;
	FileIO_CopyString(p + 22, StorageArea_UnitNames[SINGLE_LOAD_AREA] + 1);
	FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 22, SLDstMemLabel_ColonSep);
	FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 22, NumToAscii_FormatNumber((unsigned char)(SLOAD_DST_SONG + 1), 0));
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_DST_ROWS + 22, 16);
	FileIO_CopyString(SINGLE_LOAD_DST_ROWS + 42, BuildSlotLabel(SLOAD_DST_SONG, 2, 0));
	ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 21));
	ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 42));
}
