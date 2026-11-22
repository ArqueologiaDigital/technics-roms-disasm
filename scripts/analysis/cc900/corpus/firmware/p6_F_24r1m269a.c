/* lane_p6 helper F, round 24r1, form a: module 269 (file_io/single_load.s), the SOUND MEMORY list procs of the
   single-load source and destination lists (roots23_B's stretches at f8fafd and f90935):
   SingleLoadSrc_SoundMemListProc (f8fb5b, 748 B) and SingleLoadDst_SoundMemListProc (f90a91, 722 B).
   Parameter 5 / 7 moves the cursor a column (20 sounds), 6 / 8 one row; the other list's two parameters only
   redraw the rows when the parameter changed; 40 (Src) redraws pending rows, 10 (Dst) loads the selection.
   The ROM compares DOWN, UP, PAINT and runs PAINT's body first: a switch with PAINT the first case (V4.23 compares
   the case labels last first).  Each parameter branch has its own copy of the "parameter changed" redraw (the ROM
   holds three, tail-merged at the second post).  The page size is read from its ROM constant at every use (V4.23
   hoists the first read to the entry, as in helper J's ComposerListProc listing).
   Char arguments go without extz: the callees' `n` is declared plain char here (lane_sub's spelling (c)).
   Form a: the cursor and the page size read straight from their cells; switch on the event.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SingleLoadDst_DrawSoundMemBankRows SingleLoadDst_DrawSoundMemItemRows SingleLoadSrc_DrawSoundMemBankRows SingleLoadSrc_DrawSoundMemItemName SingleLoadSrc_DrawSoundMemItemNumber SingleLoadSrc_DrawUserKitName SingleLoad_SyncSoundMemCursorGroup */
/* cc900-name: SLSrc_DrawSoundMemBankRows=SingleLoadSrc_DrawSoundMemBankRows */
/* cc900-name: SLSrc_DrawSoundMemItemNumber=SingleLoadSrc_DrawSoundMemItemNumber */
/* cc900-name: SLSrc_DrawSoundMemItemName=SingleLoadSrc_DrawSoundMemItemName */
/* cc900-name: SL_SyncSoundMemCursorGroup=SingleLoad_SyncSoundMemCursorGroup */
/* cc900-name: SLSrc_SoundMemEntryCount=SingleLoadSrc_SoundMemEntryCount */
/* cc900-name: SLDst_DrawSoundMemBankRows=SingleLoadDst_DrawSoundMemBankRows */
/* cc900-name: SLDst_DrawSoundMemItemRows=SingleLoadDst_DrawSoundMemItemRows */
/* cc900-name: SLDst_SoundMemEntryCount=SingleLoadDst_SoundMemEntryCount */

#define EVT_PAINT          0x1c0000bL
#define EVT_PARA_DRAW      0x1c0000fL
#define EVT_INDEXSW_UP     0x1c00017L
#define EVT_INDEXSW_DOWN   0x1c00018L

extern char __near SINGLE_LOAD_SRC_ROWS[];
extern char __near SINGLE_LOAD_DST_ROWS[];
extern unsigned char __near SINGLE_LOAD_ALL;
extern unsigned char __near SLOAD_SRC_SOUND_POS;
extern unsigned char __near SLOAD_DST_SOUND_POS;
extern long __near ram_81d8;
extern unsigned char __near ram_81dc;
extern unsigned char __near ram_81de;
extern long __near ram_81ec;
extern unsigned char SingleLoadSrc_SoundMemPageSize;
extern unsigned char SLSrc_SoundMemEntryCount;
extern unsigned char SLDstSoundMem_RowsPerColumn;
extern unsigned char SLDst_SoundMemEntryCount;

extern long ApPostEvent(long, long, long);
extern void SLSrc_DrawSoundMemBankRows(long obj, char n);
extern void SLSrc_DrawSoundMemItemNumber(long obj, char n);
extern void SingleLoadSrc_DrawUserKitName(long obj, char n);
extern void SLSrc_DrawSoundMemItemName(long obj, char n);
extern void SLDst_DrawSoundMemBankRows(long obj, char n);
extern void SLDst_DrawSoundMemItemRows(long obj, char n);
extern void SL_SyncSoundMemCursorGroup(long kind, char n, unsigned char *a, unsigned char *b);
extern int SingleLoad_LoadSoundMemBank(unsigned int, unsigned int);
extern int SingleLoad_LoadSoundMemEntry(unsigned int, unsigned int);

long SingleLoadSrc_SoundMemListProc(long obj, long evt, long par)
{
	switch (evt) {
	case EVT_PAINT:
		SLSrc_DrawSoundMemBankRows(obj, SingleLoadSrc_SoundMemPageSize);
		SLSrc_DrawSoundMemItemNumber(obj, SingleLoadSrc_SoundMemPageSize);
		SingleLoadSrc_DrawUserKitName(obj, SingleLoadSrc_SoundMemPageSize);
		SLSrc_DrawSoundMemItemName(obj, SingleLoadSrc_SoundMemPageSize);
		ram_81d8 = 0;
		ram_81dc = 0;
		ram_81de = 0;
		break;
	case EVT_INDEXSW_UP:
	case EVT_INDEXSW_DOWN:
		if (par == 5) {
			if (evt == EVT_INDEXSW_UP
			    && SLOAD_SRC_SOUND_POS < (unsigned char)(SingleLoadSrc_SoundMemPageSize + SingleLoadSrc_SoundMemPageSize)) {
				if (SLOAD_SRC_SOUND_POS < SingleLoadSrc_SoundMemPageSize)
					SLOAD_SRC_SOUND_POS = SLOAD_SRC_SOUND_POS + SingleLoadSrc_SoundMemPageSize;
				else
					SLOAD_SRC_SOUND_POS = SingleLoadSrc_SoundMemPageSize + SingleLoadSrc_SoundMemPageSize;
				SLSrc_DrawSoundMemBankRows(obj, SingleLoadSrc_SoundMemPageSize);
				SLSrc_DrawSoundMemItemNumber(obj, SingleLoadSrc_SoundMemPageSize);
				SL_SyncSoundMemCursorGroup(par, SingleLoadSrc_SoundMemPageSize, &SLOAD_SRC_SOUND_POS, &SLOAD_DST_SOUND_POS);
				ram_81de = 1;
				ram_81dc = 1;
			} else if (evt == EVT_INDEXSW_DOWN && SLOAD_SRC_SOUND_POS >= SingleLoadSrc_SoundMemPageSize) {
				if (SLOAD_SRC_SOUND_POS < (unsigned char)(SingleLoadSrc_SoundMemPageSize + SingleLoadSrc_SoundMemPageSize))
					SLOAD_SRC_SOUND_POS = SLOAD_SRC_SOUND_POS - SingleLoadSrc_SoundMemPageSize;
				else
					SLOAD_SRC_SOUND_POS = SingleLoadSrc_SoundMemPageSize;
				SLSrc_DrawSoundMemBankRows(obj, SingleLoadSrc_SoundMemPageSize);
				SLSrc_DrawSoundMemItemNumber(obj, SingleLoadSrc_SoundMemPageSize);
				SL_SyncSoundMemCursorGroup(par, SingleLoadSrc_SoundMemPageSize, &SLOAD_SRC_SOUND_POS, &SLOAD_DST_SOUND_POS);
				ram_81de = 1;
				ram_81dc = 1;
			}
			if (ram_81d8 != par) {
				ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 21));
				ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 63));
				ram_81d8 = par;
			}
		} else if (par == 6) {
			if (evt == EVT_INDEXSW_UP && (unsigned char)(SLOAD_SRC_SOUND_POS + 1) < SLSrc_SoundMemEntryCount) {
				if (SLOAD_SRC_SOUND_POS < (unsigned char)(SingleLoadSrc_SoundMemPageSize + SingleLoadSrc_SoundMemPageSize)) {
					if ((unsigned char)(SLOAD_SRC_SOUND_POS % SingleLoadSrc_SoundMemPageSize + 1) < SingleLoadSrc_SoundMemPageSize) {
						SLOAD_SRC_SOUND_POS = SLOAD_SRC_SOUND_POS + 1;
						SLSrc_DrawSoundMemItemNumber(obj, SingleLoadSrc_SoundMemPageSize);
						SL_SyncSoundMemCursorGroup(par, SingleLoadSrc_SoundMemPageSize, &SLOAD_SRC_SOUND_POS, &SLOAD_DST_SOUND_POS);
						ram_81dc = 1;
					}
				} else {
					SLOAD_SRC_SOUND_POS = SLOAD_SRC_SOUND_POS + 1;
					SLSrc_DrawSoundMemItemNumber(obj, SingleLoadSrc_SoundMemPageSize);
					SL_SyncSoundMemCursorGroup(par, SingleLoadSrc_SoundMemPageSize, &SLOAD_SRC_SOUND_POS, &SLOAD_DST_SOUND_POS);
					ram_81dc = 1;
				}
			} else if (evt == EVT_INDEXSW_DOWN && SLOAD_SRC_SOUND_POS != 0) {
				if (SLOAD_SRC_SOUND_POS < (unsigned char)(SingleLoadSrc_SoundMemPageSize + SingleLoadSrc_SoundMemPageSize)) {
					if (SLOAD_SRC_SOUND_POS % SingleLoadSrc_SoundMemPageSize != 0) {
						SLOAD_SRC_SOUND_POS = SLOAD_SRC_SOUND_POS - 1;
						SLSrc_DrawSoundMemItemNumber(obj, SingleLoadSrc_SoundMemPageSize);
						SL_SyncSoundMemCursorGroup(par, SingleLoadSrc_SoundMemPageSize, &SLOAD_SRC_SOUND_POS, &SLOAD_DST_SOUND_POS);
						ram_81dc = 1;
					}
				} else if (SLOAD_SRC_SOUND_POS > (unsigned char)(SingleLoadSrc_SoundMemPageSize + SingleLoadSrc_SoundMemPageSize)) {
					SLOAD_SRC_SOUND_POS = SLOAD_SRC_SOUND_POS - 1;
					SLSrc_DrawSoundMemItemNumber(obj, SingleLoadSrc_SoundMemPageSize);
					SL_SyncSoundMemCursorGroup(par, SingleLoadSrc_SoundMemPageSize, &SLOAD_SRC_SOUND_POS, &SLOAD_DST_SOUND_POS);
					ram_81dc = 1;
				}
			}
			if (ram_81d8 != par) {
				ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 21));
				ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 63));
				ram_81d8 = par;
			}
		} else if (par == 7 || par == 8) {
			if (ram_81d8 != par) {
				ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 21));
				ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 63));
				ram_81d8 = par;
			}
		} else if (par == 40) {
			if (ram_81de != 0) {
				SingleLoadSrc_DrawUserKitName(obj, SingleLoadSrc_SoundMemPageSize);
				ram_81de = 0;
			}
			if (ram_81dc != 0) {
				SLSrc_DrawSoundMemItemName(obj, SingleLoadSrc_SoundMemPageSize);
				ram_81dc = 0;
			}
		}
		break;
	}
	return 0;
}

long SingleLoadDst_SoundMemListProc(long obj, long evt, long par)
{
	switch (evt) {
	case EVT_PAINT:
		SLDst_DrawSoundMemBankRows(obj, SLDstSoundMem_RowsPerColumn);
		SLDst_DrawSoundMemItemRows(obj, SLDstSoundMem_RowsPerColumn);
		ram_81ec = 0;
		break;
	case EVT_INDEXSW_UP:
	case EVT_INDEXSW_DOWN:
		if (par == 7) {
			if (evt == EVT_INDEXSW_UP
			    && SLOAD_DST_SOUND_POS < (unsigned char)(SLDstSoundMem_RowsPerColumn + SLDstSoundMem_RowsPerColumn)) {
				if (SLOAD_DST_SOUND_POS < SLDstSoundMem_RowsPerColumn)
					SLOAD_DST_SOUND_POS = SLOAD_DST_SOUND_POS + SLDstSoundMem_RowsPerColumn;
				else
					SLOAD_DST_SOUND_POS = SLDstSoundMem_RowsPerColumn + SLDstSoundMem_RowsPerColumn;
				SLDst_DrawSoundMemBankRows(obj, SLDstSoundMem_RowsPerColumn);
				SLDst_DrawSoundMemItemRows(obj, SLDstSoundMem_RowsPerColumn);
				SL_SyncSoundMemCursorGroup(par, SLDstSoundMem_RowsPerColumn, &SLOAD_SRC_SOUND_POS, &SLOAD_DST_SOUND_POS);
			} else if (evt == EVT_INDEXSW_DOWN && SLOAD_DST_SOUND_POS >= SLDstSoundMem_RowsPerColumn) {
				if (SLOAD_DST_SOUND_POS < (unsigned char)(SLDstSoundMem_RowsPerColumn + SLDstSoundMem_RowsPerColumn))
					SLOAD_DST_SOUND_POS = SLOAD_DST_SOUND_POS - SLDstSoundMem_RowsPerColumn;
				else if (SLOAD_DST_SOUND_POS >= (unsigned char)(SLDstSoundMem_RowsPerColumn + SLDstSoundMem_RowsPerColumn))
					SLOAD_DST_SOUND_POS = SLDstSoundMem_RowsPerColumn;
				SLDst_DrawSoundMemBankRows(obj, SLDstSoundMem_RowsPerColumn);
				SLDst_DrawSoundMemItemRows(obj, SLDstSoundMem_RowsPerColumn);
				SL_SyncSoundMemCursorGroup(par, SLDstSoundMem_RowsPerColumn, &SLOAD_SRC_SOUND_POS, &SLOAD_DST_SOUND_POS);
			}
			if (ram_81ec != par) {
				ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 21));
				ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 63));
				ram_81ec = par;
			}
		} else if (par == 8) {
			if (evt == EVT_INDEXSW_UP && (unsigned char)(SLOAD_DST_SOUND_POS + 1) < SLDst_SoundMemEntryCount) {
				if (SLOAD_DST_SOUND_POS < (unsigned char)(SLDstSoundMem_RowsPerColumn + SLDstSoundMem_RowsPerColumn)) {
					if ((unsigned char)(SLOAD_DST_SOUND_POS % SLDstSoundMem_RowsPerColumn + 1) < SLDstSoundMem_RowsPerColumn) {
						SLOAD_DST_SOUND_POS = SLOAD_DST_SOUND_POS + 1;
						SLDst_DrawSoundMemItemRows(obj, SLDstSoundMem_RowsPerColumn);
						SL_SyncSoundMemCursorGroup(par, SLDstSoundMem_RowsPerColumn, &SLOAD_SRC_SOUND_POS, &SLOAD_DST_SOUND_POS);
					}
				} else {
					SLOAD_DST_SOUND_POS = SLOAD_DST_SOUND_POS + 1;
					SLDst_DrawSoundMemItemRows(obj, SLDstSoundMem_RowsPerColumn);
					SL_SyncSoundMemCursorGroup(par, SLDstSoundMem_RowsPerColumn, &SLOAD_SRC_SOUND_POS, &SLOAD_DST_SOUND_POS);
				}
			} else if (evt == EVT_INDEXSW_DOWN && SLOAD_DST_SOUND_POS != 0) {
				if (SLOAD_DST_SOUND_POS < (unsigned char)(SLDstSoundMem_RowsPerColumn + SLDstSoundMem_RowsPerColumn)) {
					if (SLOAD_DST_SOUND_POS % SLDstSoundMem_RowsPerColumn != 0) {
						SLOAD_DST_SOUND_POS = SLOAD_DST_SOUND_POS - 1;
						SLDst_DrawSoundMemItemRows(obj, SLDstSoundMem_RowsPerColumn);
						SL_SyncSoundMemCursorGroup(par, SLDstSoundMem_RowsPerColumn, &SLOAD_SRC_SOUND_POS, &SLOAD_DST_SOUND_POS);
					}
				} else if (SLOAD_DST_SOUND_POS > (unsigned char)(SLDstSoundMem_RowsPerColumn + SLDstSoundMem_RowsPerColumn)) {
					SLOAD_DST_SOUND_POS = SLOAD_DST_SOUND_POS - 1;
					SLDst_DrawSoundMemItemRows(obj, SLDstSoundMem_RowsPerColumn);
					SL_SyncSoundMemCursorGroup(par, SLDstSoundMem_RowsPerColumn, &SLOAD_SRC_SOUND_POS, &SLOAD_DST_SOUND_POS);
				}
			}
			if (ram_81ec != par) {
				ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 21));
				ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 63));
				ram_81ec = par;
			}
		} else if (par == 5 || par == 6) {
			if (ram_81ec != par) {
				ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 21));
				ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 63));
				ram_81ec = par;
			}
		} else if (par == 10) {
			if (SINGLE_LOAD_ALL != 0)
				return SingleLoad_LoadSoundMemBank(SLOAD_SRC_SOUND_POS / SLDstSoundMem_RowsPerColumn,
					SLOAD_DST_SOUND_POS / SLDstSoundMem_RowsPerColumn);
			return SingleLoad_LoadSoundMemEntry(SLOAD_SRC_SOUND_POS, SLOAD_DST_SOUND_POS);
		}
		break;
	}
	return 0;
}
