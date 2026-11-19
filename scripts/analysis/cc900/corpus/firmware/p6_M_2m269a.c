/* Phase 6, lane_p6 helper M, round 2, module 269 (file_io/single_load.s), form a.
   SingleLoadDst_DrawSongRows: the SEQUENCER destination rows (sibling of the built
   SingleLoadSrc_PanelMemDrawMemoryNumber).  SingleLoadDst_SequencerListProc: its list proc.  The event test chain
   (DOWN, UP, PAINT) is a switch written PAINT, UP, DOWN (V4.23 compares the last case first); INDEXSW: par 8 steps
   the song (byte compare against the ROM's song count), par 5..7 repaints the name row, par 10 loads the song. */
/* cc900-name: SLDst_SeqSongCount=SingleLoadDst_SequencerSongCount */
/* cc900-module: BuildSlotLabel NumToAscii_FormatNumber SingleLoadDst_DrawSongRows TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_PAINT          0x1c0000bL
#define EVT_PARA_DRAW      0x1c0000fL
#define EVT_INDEXSW_UP     0x1c00017L
#define EVT_INDEXSW_DOWN   0x1c00018L

extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern char *NumToAscii_FormatNumber(unsigned int, unsigned int);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern char *BuildSlotLabel(unsigned int, unsigned int, unsigned int);
extern int SingleLoad_LoadSong(unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near SINGLE_LOAD_DST_ROWS[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SLOAD_DST_SONG;
extern char *StorageArea_UnitNames[];
extern char SLDstMemLabel_ColonSep[];
extern unsigned char SLDst_SeqSongCount;
extern void SingleLoadDst_DrawSongRows(long obj);
extern long SingleLoadDst_SequencerListProc(long obj, long evt, long par);

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

long SingleLoadDst_SequencerListProc(long obj, long evt, long par)
{
	char *p;
	char *q;
	unsigned char w;

	switch (evt) {
	case EVT_PAINT:
		p = SINGLE_LOAD_DST_ROWS;
		*p++ = 0;
		*p = 0;
		TrimAndPadSmfFilename((unsigned char *)p, 16);
		p = SINGLE_LOAD_DST_ROWS;
		p[63] = 3;
		p += 64;
		*p = 0;
		TrimAndPadSmfFilename((unsigned char *)p, 16);
		ApPostEvent(obj, EVT_PARA_DRAW, 0x89a2L);
		ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 63));
		SingleLoadDst_DrawSongRows(obj);
		break;
	case EVT_INDEXSW_UP:
	case EVT_INDEXSW_DOWN:
		w = SLOAD_DST_SONG;
		q = SINGLE_LOAD_DST_ROWS + 42;
		if (par == 8) {
			if (evt == EVT_INDEXSW_UP && (unsigned char)(w + 1) < SLDst_SeqSongCount) {
				SLOAD_DST_SONG = w + 1;
				SingleLoadDst_DrawSongRows(obj);
			} else if (evt == EVT_INDEXSW_DOWN && w != 0) {
				SLOAD_DST_SONG = w - 1;
				SingleLoadDst_DrawSongRows(obj);
			} else
				ApPostEvent(obj, EVT_PARA_DRAW, (long)q);
		} else if (par >= 5 && par <= 7)
			ApPostEvent(obj, EVT_PARA_DRAW, (long)q);
		else if (par == 10)
			return SingleLoad_LoadSong(SLOAD_DST_SONG);
		break;
	}
	return 0;
}
