/* Phase 6, lane_p6 helper J, round 3, module 269, form a: refinements from run r35.
   SingleLoad_GetComposerSectionName (+1): the ROM takes out++ into its own register (lda xbc,(xiz+:1), bank moved
   to HL to free BC) before loading c -- written p = out++; *p = c -- and indexes the RAM names as
   lda base + mul hl,0x60 (an unsigned 16 x 16 -> 32 product: (unsigned long)(bank * 4 + sec) * 0x60 on a char
   array).  SmfSeqToSongNumFunc (+16, the rest matched at O3Xr): the event parameter is the literal 0x8094 (the
   ROM's ld xde,0x8094, as the matched SLDstBankList_FuncBody passes 0x89a2L). */
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

extern unsigned char ram_948a0[];
extern char *SingleLoad_StyleSectionNames[];

void SL_GetComposerSectionName(char *out, unsigned int bank, unsigned int sec, int c)
{
	char *p;

	p = out++;
	*p = c;
	if (sec < 4) {
		FileIO_CopyString_WriteNull((unsigned char *)out, ram_948a0 + (unsigned long)(bank * 4 + sec) * 0x60, 13);
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

	switch (evt) {
	case EVT_PS_FILE_NAME_BOX_ID:
		ram_8090 = par;
		break;
	case EVT_PAINT:
		p = ram_8094;
		*p = 0;
		FileIO_CopyString(p + 1, SeqToSong_Str_TO_SONG);
		FileIO_BuildFilePath(ram_8094 + 1, NumToAscii_FormatNumber((unsigned char)(ram_8948 + 1), 2));
		ApPostEvent(ram_8090, EVT_PARA_DRAW, 0x8094L);
		break;
	}
	return 0;
}
