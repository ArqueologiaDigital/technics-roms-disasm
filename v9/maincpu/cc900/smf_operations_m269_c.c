/* Functions of file_io/smf_operations.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: NumToAscii_FormatNumber SingleLoad_GetComposerBankName SingleLoad_GetSoundMemBankName TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_PAINT               0x1c0000bL
#define EVT_PARA_DRAW           0x1c0000fL
#define EVT_PS_FILE_NAME_BOX_ID 0x1e50004L
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern char *NumToAscii_FormatNumber(unsigned int, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near ram_8118[];
extern long __near ram_8114;
extern unsigned char __near ram_8948;
extern char SeqFromSong_Str_FROM_SONG[];
extern long SmfSeqFromSongNumFunc(long obj, long evt, long par);

/* cc900-name: SeqFromSong_Str_FROM_SONG=SeqFromSong_BuildEntry_Str_FROM_SONG */
long SmfSeqFromSongNumFunc(long obj, long evt, long par)
{
	char *p;

	switch (evt) {
	case EVT_PS_FILE_NAME_BOX_ID:
		ram_8114 = par;
		break;
	case EVT_PAINT:
		p = ram_8118;
		*p = 0;
		FileIO_CopyString(p + 1, SeqFromSong_Str_FROM_SONG);
		FileIO_BuildFilePath(ram_8118 + 1, NumToAscii_FormatNumber((unsigned char)(ram_8948 + 1), 2));
		ApPostEvent(ram_8114, EVT_PARA_DRAW, 0x8118L);
		break;
	}
	return 0;
}
