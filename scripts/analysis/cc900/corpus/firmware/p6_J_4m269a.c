/* Phase 6, lane_p6 helper J, round 4, module 269 (file_io/single_load.s, -O3 -Xr like single_load_m269.c), form a:
   the single-load source list's composer, panel-memory and sequencer pages --
   SingleLoadSrc_ComposerDrawPatternName, SingleLoadSrc_ComposerListProc, SingleLoadSrc_PanelMemDrawMemoryName,
   SingleLoadSrc_PanelMemListProc, SingleLoadSrc_SequencerListProc.
   NOTE for staging: SingleLoadSrc_PanelMemDrawMemoryName and the matched SingleLoadSrc_PanelMemDrawMemoryNumber
   share their first 31 characters, so both go through short cc900-name aliases here; a staged file holding this
   C and single_load_m269.c's DrawMemoryNumber needs the same alias there. */
/* cc900-name: SLSrc_CmpDrawPatternName=SingleLoadSrc_ComposerDrawPatternName */
/* cc900-name: SLSrc_ComposerDrawPatternSlot=SingleLoadSrc_ComposerDrawPatternSlot */
/* cc900-name: SLSrc_ComposerDrawBankName=SingleLoadSrc_ComposerDrawBankName */
/* cc900-name: SLSrc_PMemDrawMemName=SingleLoadSrc_PanelMemDrawMemoryName */
/* cc900-name: SLSrc_PMemDrawMemNumber=SingleLoadSrc_PanelMemDrawMemoryNumber */
/* cc900-name: SLSrc_PMemDrawBankName=SingleLoadSrc_PanelMemDrawBankName */
/* cc900-name: SLSrc_ReadCmpPatternName=SingleLoadSrc_ReadCmpPatternName */
/* cc900-name: SLSrc_PMemEntryCount=SingleLoadSrc_PanelMemEntryCount */
/* cc900-name: SLSrc_CmpEntryCount=SingleLoadSrc_ComposerEntryCount */
/* cc900-name: SlSrcEntry_Str_Colon=SLSrcBankList_FuncBody_Entry_Str_Colon */
/* cc900-module: SLSrcBankList_FuncBody SingleLoadSrc_ComposerDrawBankName SingleLoadSrc_ComposerDrawPatternName SingleLoadSrc_ComposerDrawPatternSlot SingleLoadSrc_PanelMemDrawBankName SingleLoadSrc_PanelMemDrawMemoryName SingleLoadSrc_PanelMemDrawMemoryNumber TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_PAINT          0x1c0000bL
#define EVT_PARA_DRAW      0x1c0000fL
#define EVT_INDEXSW_UP     0x1c00017L
#define EVT_INDEXSW_DOWN   0x1c00018L

extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near SINGLE_LOAD_SRC_ROWS[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SINGLE_LOAD_ALL;
extern unsigned char __near SLOAD_SRC_CMP_POS;
extern unsigned char __near SLOAD_SRC_PMEM_POS;
extern long __near ram_81ca;
extern unsigned char __near ram_81ce;
extern unsigned char __near ram_81d0;
extern long __near ram_81d2;
extern unsigned char __near ram_81d6;
extern unsigned char __near ram_8a0a;
extern unsigned char SLSrcComposer_RowsPerColumn;
extern unsigned char SLSrc_CmpEntryCount;
extern unsigned char SingleLoadSrc_PanelMemBankSize;
extern unsigned char SLSrc_PMemEntryCount;
extern char *StorageArea_UnitNames[];
extern char SlSrcEntry_Str_Colon[];
extern char *SLSrc_ReadCmpPatternName(unsigned int);
extern char *SingleLoadSrc_ReadPmtMemoryName(unsigned int);
extern char *SingleLoadSrc_ReadSqtSongName(unsigned int);
extern void SLSrc_ComposerDrawPatternSlot(long obj, unsigned char n);
extern void SLSrc_ComposerDrawBankName(long obj, unsigned char n);
extern void SLSrc_CmpDrawPatternName(long obj, unsigned char n);
extern void SLSrcBankList_FuncBody(long obj, unsigned char n);
extern void SLSrc_PMemDrawMemNumber(long obj, unsigned char n);
extern void SLSrc_PMemDrawBankName(long obj, unsigned char n);
extern void SLSrc_PMemDrawMemName(long obj, unsigned char n);

void SLSrc_CmpDrawPatternName(long obj, unsigned char n)
{
	unsigned int b;
	char *p;

	b = SLOAD_SRC_CMP_POS % n;
	if (SINGLE_LOAD_ALL != 0)
		return;
	if (b >= 4)
		return;
	p = SINGLE_LOAD_SRC_ROWS;
	p[63] = 3;
	FileIO_CopyString(p + 64, SLSrc_ReadCmpPatternName((unsigned char)(SLOAD_SRC_CMP_POS / n)));
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_SRC_ROWS + 64, 16);
	ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 63));
}

long SingleLoadSrc_ComposerListProc(long obj, long evt, long par)
{
	unsigned char l;

	if (evt == EVT_INDEXSW_DOWN || evt == EVT_INDEXSW_UP) {
		l = SLOAD_SRC_CMP_POS;
		if (par == 5) {
			if (evt == EVT_INDEXSW_UP && (unsigned char)(SLSrcComposer_RowsPerColumn + l) < SLSrc_CmpEntryCount) {
				SLOAD_SRC_CMP_POS = l + SLSrcComposer_RowsPerColumn;
				SLSrc_ComposerDrawBankName(obj, SLSrcComposer_RowsPerColumn);
				SLSrc_ComposerDrawPatternSlot(obj, SLSrcComposer_RowsPerColumn);
				ram_81d6 = 1;
			} else if (evt == EVT_INDEXSW_DOWN && l >= SLSrcComposer_RowsPerColumn) {
				SLOAD_SRC_CMP_POS = l - SLSrcComposer_RowsPerColumn;
				SLSrc_ComposerDrawBankName(obj, SLSrcComposer_RowsPerColumn);
				SLSrc_ComposerDrawPatternSlot(obj, SLSrcComposer_RowsPerColumn);
				ram_81d6 = 1;
			}
		} else if (par == 6) {
			if (evt == EVT_INDEXSW_UP && (unsigned char)(l + 1) < SLSrc_CmpEntryCount) {
				if ((unsigned char)(l % SLSrcComposer_RowsPerColumn + 1) < SLSrcComposer_RowsPerColumn) {
					SLOAD_SRC_CMP_POS = l + 1;
					SLSrc_ComposerDrawPatternSlot(obj, SLSrcComposer_RowsPerColumn);
					ram_81d6 = 1;
				}
			} else if (evt == EVT_INDEXSW_DOWN && l != 0) {
				if (l % SLSrcComposer_RowsPerColumn != 0) {
					SLOAD_SRC_CMP_POS = l - 1;
					SLSrc_ComposerDrawPatternSlot(obj, SLSrcComposer_RowsPerColumn);
					ram_81d6 = 1;
				}
			}
		} else if (par != 7 && par != 8) {
			if (par == 40 && ram_81d6 != 0) {
				SLSrc_CmpDrawPatternName(obj, SLSrcComposer_RowsPerColumn);
				ram_81d6 = 0;
			}
			return 0;
		}
		if (ram_81d2 != par) {
			ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 21));
			ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 63));
			ram_81d2 = par;
		}
	} else if (evt == EVT_PAINT) {
		SLSrc_ComposerDrawPatternSlot(obj, SLSrcComposer_RowsPerColumn);
		SLSrc_ComposerDrawBankName(obj, SLSrcComposer_RowsPerColumn);
		SLSrc_CmpDrawPatternName(obj, SLSrcComposer_RowsPerColumn);
		ram_81d2 = 0;
		ram_81d6 = 0;
	}
	return 0;
}

void SLSrc_PMemDrawMemName(long obj, unsigned char n)
{
	char *p;

	if (SINGLE_LOAD_ALL != 0)
		return;
	p = SINGLE_LOAD_SRC_ROWS;
	p[63] = 3;
	FileIO_CopyString(p + 64, SingleLoadSrc_ReadPmtMemoryName(SLOAD_SRC_PMEM_POS));
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_SRC_ROWS + 64, 16);
	ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 63));
}

long SingleLoadSrc_PanelMemListProc(long obj, long evt, long par)
{
	unsigned char e;

	if (evt == EVT_INDEXSW_DOWN || evt == EVT_INDEXSW_UP) {
		e = SLOAD_SRC_PMEM_POS;
		if (par == 5) {
			if (ram_8a0a == 0) {
				if (evt == EVT_INDEXSW_UP && (unsigned char)(SingleLoadSrc_PanelMemBankSize + e) < SLSrc_PMemEntryCount) {
					SLOAD_SRC_PMEM_POS = e + SingleLoadSrc_PanelMemBankSize;
					SLSrcBankList_FuncBody(obj, SingleLoadSrc_PanelMemBankSize);
					SLSrc_PMemDrawMemNumber(obj, SingleLoadSrc_PanelMemBankSize);
					ram_81d0 = 1;
					ram_81ce = 1;
				} else if (evt == EVT_INDEXSW_DOWN && e >= SingleLoadSrc_PanelMemBankSize) {
					SLOAD_SRC_PMEM_POS = e - SingleLoadSrc_PanelMemBankSize;
					SLSrcBankList_FuncBody(obj, SingleLoadSrc_PanelMemBankSize);
					SLSrc_PMemDrawMemNumber(obj, SingleLoadSrc_PanelMemBankSize);
					ram_81d0 = 1;
					ram_81ce = 1;
				}
			}
		} else if (par == 6) {
			if (evt == EVT_INDEXSW_UP && (unsigned char)(e + 1) < SLSrc_PMemEntryCount) {
				if ((unsigned char)(e % SingleLoadSrc_PanelMemBankSize + 1) < SingleLoadSrc_PanelMemBankSize) {
					SLOAD_SRC_PMEM_POS = e + 1;
					SLSrc_PMemDrawMemNumber(obj, SingleLoadSrc_PanelMemBankSize);
					ram_81ce = 1;
				}
			} else if (evt == EVT_INDEXSW_DOWN && e != 0) {
				if (e % SingleLoadSrc_PanelMemBankSize != 0) {
					SLOAD_SRC_PMEM_POS = e - 1;
					SLSrc_PMemDrawMemNumber(obj, SingleLoadSrc_PanelMemBankSize);
					ram_81ce = 1;
				}
			}
		} else if (par != 7 && par != 8) {
			if (par == 40) {
				if (ram_81d0 != 0) {
					SLSrc_PMemDrawBankName(obj, SingleLoadSrc_PanelMemBankSize);
					ram_81d0 = 0;
				}
				if (ram_81ce != 0) {
					SLSrc_PMemDrawMemName(obj, SingleLoadSrc_PanelMemBankSize);
					ram_81ce = 0;
				}
			}
			return 0;
		}
		if (ram_81ca != par) {
			ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 21));
			ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 63));
			ram_81ca = par;
		}
	} else if (evt == EVT_PAINT) {
		if (ram_8a0a != 0)
			SLOAD_SRC_PMEM_POS = SLOAD_SRC_PMEM_POS % SingleLoadSrc_PanelMemBankSize;
		SLSrcBankList_FuncBody(obj, SingleLoadSrc_PanelMemBankSize);
		SLSrc_PMemDrawMemNumber(obj, SingleLoadSrc_PanelMemBankSize);
		SLSrc_PMemDrawBankName(obj, SingleLoadSrc_PanelMemBankSize);
		SLSrc_PMemDrawMemName(obj, SingleLoadSrc_PanelMemBankSize);
		ram_81ca = 0;
		ram_81ce = 0;
		ram_81d0 = 0;
	}
	return 0;
}

long SingleLoadSrc_SequencerListProc(long obj, long evt, long par)
{
	char *p;
	char *q;

	if (evt == EVT_PAINT) {
		p = SINGLE_LOAD_SRC_ROWS;
		*p++ = 0;
		*p = 0;
		TrimAndPadSmfFilename((unsigned char *)p, 16);
		p = SINGLE_LOAD_SRC_ROWS;
		p[21] = 1;
		FileIO_CopyString(p + 22, StorageArea_UnitNames[SINGLE_LOAD_AREA] + 1);
		FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 22, SlSrcEntry_Str_Colon);
		TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_SRC_ROWS + 22, 16);
		p = SINGLE_LOAD_SRC_ROWS;
		p[42] = 2;
		FileIO_CopyString(p + 43, SingleLoadSrc_ReadSqtSongName(0));
		TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_SRC_ROWS + 43, 16);
		p = SINGLE_LOAD_SRC_ROWS;
		p[63] = 3;
		q = p + 64;
		*q = 0;
		TrimAndPadSmfFilename((unsigned char *)q, 16);
		ApPostEvent(obj, EVT_PARA_DRAW, 0x894eL);
		ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 21));
		ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 42));
		ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 63));
	}
	return 0;
}
