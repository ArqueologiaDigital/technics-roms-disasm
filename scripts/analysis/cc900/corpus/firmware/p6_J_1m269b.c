/* Phase 6, lane_p6 helper J, round 1, module 269, form b: SingleLoad_GetComposerSectionName with the RAM names as a
   [][4][0x60] array; SmfSeqToSongNumFunc as an if / else-if chain and `*p++ = 0` (the ROM's ld (xwa+),0). */
/* cc900-name: SL_GetComposerSectionName=SingleLoad_GetComposerSectionName */
/* cc900-name: SeqToSong_Str_TO_SONG=SeqToSong_BuildEntry_Str_TO_SONG */
/* cc900-module: NumToAscii_FormatNumber TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_PAINT               0x1c0000bL
#define EVT_PARA_DRAW           0x1c0000fL
#define EVT_PS_FILE_NAME_BOX_ID 0x1e50004L

extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern void FileIO_CopyString_WriteNull(unsigned char *, unsigned char *, int);
extern char *NumToAscii_FormatNumber(unsigned int, unsigned int);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);

extern unsigned char ram_948a0[][4][0x60];
extern char *SingleLoad_StyleSectionNames[];

void SL_GetComposerSectionName(char *out, unsigned int bank, unsigned int sec, int c)
{
	*out++ = c;
	if (sec < 4) {
		FileIO_CopyString_WriteNull((unsigned char *)out, ram_948a0[bank][sec], 13);
		out[13] = 0;
	} else
		FileIO_CopyString(out, SingleLoad_StyleSectionNames[sec]);
	TrimAndPadSmfFilename((unsigned char *)out, 16);
}

extern char __near ram_8094[];
extern long __near ram_8090;
extern unsigned char __near ram_8948;
extern char SeqToSong_Str_TO_SONG[];

long SmfSeqToSongNumFunc(long obj, long evt, long par)
{
	char *p;

	if (evt == EVT_PAINT) {
		p = ram_8094;
		*p++ = 0;
		FileIO_CopyString(p, SeqToSong_Str_TO_SONG);
		FileIO_BuildFilePath(ram_8094 + 1, NumToAscii_FormatNumber((unsigned char)(ram_8948 + 1), 2));
		ApPostEvent(ram_8090, EVT_PARA_DRAW, (long)ram_8094);
	} else if (evt == EVT_PS_FILE_NAME_BOX_ID)
		ram_8090 = par;
	return 0;
}
