/* Phase 6, lane_p6 helper J, round 1, module 269, form a: SingleLoad_GetComposerSectionName (file_io/wallpaper.s)
   and SmfSeqToSongNumFunc (file_io/smf_operations.s). */
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

/* A composer section name: the mark c, then the 13-character user name from RAM (sections 0..3, 0x60 bytes per
   entry, 4 per bank) or the ROM's section name, padded to 16.  The ROM: *out++ as lda (xiz+:1), the index
   (bank * 4 + sec) * 0x60 as sll / add / mul (unsigned). */
struct nm96 { char s[0x60]; };
extern struct nm96 ram_948a0[];
extern char *SingleLoad_StyleSectionNames[];

void SL_GetComposerSectionName(char *out, unsigned int bank, unsigned int sec, int c)
{
	*out++ = c;
	if (sec < 4) {
		FileIO_CopyString_WriteNull((unsigned char *)out, (unsigned char *)ram_948a0[bank * 4 + sec].s, 13);
		out[13] = 0;
	} else
		FileIO_CopyString(out, SingleLoad_StyleSectionNames[sec]);
	TrimAndPadSmfFilename((unsigned char *)out, 16);
}

/* The "TO SONG nn" name box of the SMF sequence-to-song dialog.  The ROM compares EVT_PAINT first and lays the
   name-box case first: a switch (V4.23 compares the last case first). */
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
		ApPostEvent(ram_8090, EVT_PARA_DRAW, (long)ram_8094);
		break;
	}
	return 0;
}
