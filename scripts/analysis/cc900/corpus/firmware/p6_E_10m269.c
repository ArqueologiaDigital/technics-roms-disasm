/* Phase 6, lane_p6 helper E, round 10, module 269 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): v10
   file_io/medley.s (adecl, -O3 -Xr), under the firmware names.  Form a; p6_E_10m269b.c and p6_E_10m269c.c have
   the same names.  FmmPdFileNameFunc / FmmDocFileNameFunc: see p6_E_9m269.c for what they do.
   Run 118 (round 9 form b, +12 at O3Xr) against the ROM, instruction by instruction:
   - the ROM puts GET_SELECTED_FILE_NUMBER's `return index` LAST (it falls into the epilogue) and the shared
     `return 0` block right after the PAINT case.  V4.23 puts the merged `return 0` where the last one falls through
     (round 9: at the end).  So: `if (ev != GET) { ... }  return index;`, and the switch has `default: return 0;`
     between PAINT (which falls into it) and the UP / DOWN cases (forms a and c); form b: PAINT returns 0 itself
     and there is no default.
   - the ROM keeps the index it loaded in WA and copies it to IZ (old): the page and the moves are written on the
     cell itself (`ram_8442 / 10`, `ram_8442 + 1 < count` then `ram_8442++`), not on old, which V4.23 read from IZ.
   - the redraw arguments: the ROM computes the row's offset first, loads the table's address into XHL, then
     extends the offset in DE and adds: written `(unsigned int)(old % 10) * 32 + (long)ram_850c` (forms a, b);
     form c: `(long)ram_850c + ...`, base first.
   - the page compare stays `old / 10 == index / 10` (round 9 form a's order; the ROM divides the index first). */
/* cc900-module: DocMed_FormatFileList FmmDocMedleyFunc FmmPdMedleyFunc PdMed_FormatFileList */

#define EVT_PAINT                     0x1c0000bL
#define EVT_PARA_DRAW                 0x1c0000fL
#define EVT_INDEXSW_UP                0x1c00017L
#define EVT_INDEXSW_DOWN              0x1c00018L
#define EVT_SET_SELECTED_FILE_NUMBER  0x1e50002L
#define EVT_GET_SELECTED_FILE_NUMBER  0x1e50003L
#define EVT_PS_FILE_NAME_BOX_ID       0x1e50004L

extern unsigned char __near MEDLEY_PLAY_FLAG;
extern char __near ram_850c[];
extern int __near ram_8442;
extern long __near ram_843e;
extern int __near ram_8506;
extern int __near ram_84a2;
extern long __near ram_849e;
extern int __near ram_8508;

extern long ApPostEvent(long, long, long);
extern int GetCurrentFileIndexAlt(void);
extern void SetCurrentFileIndex(int);
extern int FileIO_GetCurrentFileIndex_Alt(void);
extern void FileIO_SelectFileByIndex(int);
extern void PdMed_FormatFileList(long, int);
extern void DocMed_FormatFileList(long, int);
extern long FmmPdMedleyFunc(long, long, long);
extern long FmmDocMedleyFunc(long, long, long);

long FmmPdFileNameFunc(long obj, long ev, long arg)
{
	int old;
	int page;

	if (ev != EVT_GET_SELECTED_FILE_NUMBER) {
		old = ram_8442;
		if (ev != EVT_SET_SELECTED_FILE_NUMBER) {
			page = ram_8442 / 10;
			switch (ev) {
			case EVT_PS_FILE_NAME_BOX_ID:
				ram_843e = arg;
				ram_8442 = GetCurrentFileIndexAlt();
				if (ram_8442 < 0)
					ram_8442 = 0;
				ApPostEvent(ram_843e, EVT_SET_SELECTED_FILE_NUMBER, ram_8442 % 10);
				return 0;
			case EVT_PAINT:
				PdMed_FormatFileList(ram_843e, page * 10);
			default:
				return 0;
			case EVT_INDEXSW_UP:
			case EVT_INDEXSW_DOWN:
				if (arg == 0 && MEDLEY_PLAY_FLAG == 0) {
					if (ev == EVT_INDEXSW_DOWN) {
						if (ram_8442 + 1 < ram_8506)
							ram_8442++;
					} else if (ev == EVT_INDEXSW_UP) {
						if (ram_8442 > 0)
							ram_8442--;
					}
				} else if (arg == 1 && MEDLEY_PLAY_FLAG == 0) {
					if (ram_8442 >= 10)
						ram_8442 -= 10;
				} else if (arg == 2 && MEDLEY_PLAY_FLAG == 0) {
					if (ram_8442 + 10 < ram_8506)
						ram_8442 += 10;
					else if (page < (ram_8506 - 1) / 10 && ram_8506 % 10 != 0)
						ram_8442 = ram_8506 - 1;
				}
				if (old == ram_8442)
					return 0;
				SetCurrentFileIndex(ram_8442);
				ApPostEvent(ram_843e, EVT_SET_SELECTED_FILE_NUMBER, ram_8442 % 10);
				if (old / 10 == ram_8442 / 10) {
					ApPostEvent(ram_843e, EVT_PARA_DRAW, (unsigned int)(old % 10) * 32 + (long)ram_850c);
					ApPostEvent(ram_843e, EVT_PARA_DRAW,
						(unsigned int)(ram_8442 % 10) * 32 + (long)ram_850c);
				} else {
					PdMed_FormatFileList(ram_843e, ram_8442 / 10 * 10);
					FmmPdMedleyFunc(obj, EVT_PAINT, 0);
				}
				return 0;
			}
		}
		if (MEDLEY_PLAY_FLAG == 0)
			return 0;
		ram_8442 = arg;
		SetCurrentFileIndex(arg);
		ApPostEvent(ram_843e, EVT_SET_SELECTED_FILE_NUMBER, ram_8442 % 10);
		return 0;
	}
	return ram_8442;
}

long FmmDocFileNameFunc(long obj, long ev, long arg)
{
	int old;
	int page;

	if (ev != EVT_GET_SELECTED_FILE_NUMBER) {
		old = ram_84a2;
		if (ev != EVT_SET_SELECTED_FILE_NUMBER) {
			page = ram_84a2 / 10;
			switch (ev) {
			case EVT_PS_FILE_NAME_BOX_ID:
				ram_849e = arg;
				ram_84a2 = FileIO_GetCurrentFileIndex_Alt();
				if (ram_84a2 < 0)
					ram_84a2 = 0;
				ApPostEvent(ram_849e, EVT_SET_SELECTED_FILE_NUMBER, ram_84a2 % 10);
				return 0;
			case EVT_PAINT:
				DocMed_FormatFileList(ram_849e, page * 10);
			default:
				return 0;
			case EVT_INDEXSW_UP:
			case EVT_INDEXSW_DOWN:
				if (arg == 0 && MEDLEY_PLAY_FLAG == 0) {
					if (ev == EVT_INDEXSW_DOWN) {
						if (ram_84a2 + 1 < ram_8508)
							ram_84a2++;
					} else if (ev == EVT_INDEXSW_UP) {
						if (ram_84a2 > 0)
							ram_84a2--;
					}
				} else if (arg == 1 && MEDLEY_PLAY_FLAG == 0) {
					if (ram_84a2 >= 10)
						ram_84a2 -= 10;
				} else if (arg == 2 && MEDLEY_PLAY_FLAG == 0) {
					if (ram_84a2 + 10 < ram_8508)
						ram_84a2 += 10;
					else if (page < (ram_8508 - 1) / 10 && ram_8508 % 10 != 0)
						ram_84a2 = ram_8508 - 1;
				}
				if (old == ram_84a2)
					return 0;
				FileIO_SelectFileByIndex(ram_84a2);
				ApPostEvent(ram_849e, EVT_SET_SELECTED_FILE_NUMBER, ram_84a2 % 10);
				if (old / 10 == ram_84a2 / 10) {
					ApPostEvent(ram_849e, EVT_PARA_DRAW, (unsigned int)(old % 10) * 32 + (long)ram_850c);
					ApPostEvent(ram_849e, EVT_PARA_DRAW,
						(unsigned int)(ram_84a2 % 10) * 32 + (long)ram_850c);
				} else {
					DocMed_FormatFileList(ram_849e, ram_84a2 / 10 * 10);
					FmmDocMedleyFunc(obj, EVT_PAINT, 0);
				}
				return 0;
			}
		}
		if (MEDLEY_PLAY_FLAG == 0)
			return 0;
		ram_84a2 = arg;
		FileIO_SelectFileByIndex(arg);
		ApPostEvent(ram_849e, EVT_SET_SELECTED_FILE_NUMBER, ram_84a2 % 10);
		return 0;
	}
	return ram_84a2;
}
