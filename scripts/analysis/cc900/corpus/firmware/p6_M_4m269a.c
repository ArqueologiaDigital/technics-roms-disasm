/* Phase 6, lane_p6 helper M, round 4, module 269, form a: SingleLoadDst_SequencerListProc retry (run r42: +1
   @O3Xr).  The O3Xr listing hoisted SINGLE_LOAD_DST_ROWS into XDE at entry (shared by PAINT's p and INDEXSW's
   q = ROWS + 42), so par moved to XHL; the ROM keeps par in XDE and loads ROWS + 42 inside the INDEXSW case.
   Here: no q local (ROWS + 42 written as a constant address at both uses); par unsigned long (the ROM tests 5..7
   with jr c / ugt); the song stored as `++w` (the ROM increments a copy of w, not the compared w + 1). */
/* cc900-name: SLDst_SeqSongCount=SingleLoadDst_SequencerSongCount */
/* cc900-module: SingleLoadDst_DrawSongRows TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_PAINT          0x1c0000bL
#define EVT_PARA_DRAW      0x1c0000fL
#define EVT_INDEXSW_UP     0x1c00017L
#define EVT_INDEXSW_DOWN   0x1c00018L

extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern int SingleLoad_LoadSong(unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near SINGLE_LOAD_DST_ROWS[];
extern unsigned char __near SLOAD_DST_SONG;
extern unsigned char SLDst_SeqSongCount;
extern void SingleLoadDst_DrawSongRows(long obj);
extern long SingleLoadDst_SequencerListProc(long obj, long evt, unsigned long par);

long SingleLoadDst_SequencerListProc(long obj, long evt, unsigned long par)
{
	char *p;
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
		if (par == 8) {
			if (evt == EVT_INDEXSW_UP && (unsigned char)(w + 1) < SLDst_SeqSongCount) {
				SLOAD_DST_SONG = ++w;
				SingleLoadDst_DrawSongRows(obj);
			} else if (evt == EVT_INDEXSW_DOWN && w != 0) {
				SLOAD_DST_SONG = w - 1;
				SingleLoadDst_DrawSongRows(obj);
			} else
				ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 42));
		} else if (par >= 5 && par <= 7)
			ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 42));
		else if (par == 10)
			return SingleLoad_LoadSong(SLOAD_DST_SONG);
		break;
	}
	return 0;
}
