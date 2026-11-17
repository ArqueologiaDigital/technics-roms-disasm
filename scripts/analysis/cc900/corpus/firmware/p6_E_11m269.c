/* Phase 6, lane_p6 helper E, round 11, module 269 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): v10
   file_io/medley.s (adecl, -O3 -Xr), under the firmware names.  Form a; p6_E_11m269b.c and p6_E_11m269c.c have the same names.
   FmmPdFileNameFunc / FmmDocFileNameFunc: see p6_E_9m269.c.  Run 123 (round 10, +13 at O3Xr) differs from the ROM
   in two things only:
   - WHERE THE SHARED `return 0` SITS.  V4.23 merges all `return 0` copies into the textually last one (AcListBoxProc's
     listing, run 100: the block follows the last case that ends in `return 0`).  The ROM's block follows the PAINT
     case, so nothing after PAINT may have its own `return 0`: the UP / DOWN case and the SET branch now leave with
     `goto ret0`, a label on the default between PAINT and UP / DOWN (`default: ret0: return 0;`).
   - the redraw row's address: the ROM loads the table into XHL / XBC and builds the address in DE.  Form a:
     `(long)ram_850c[i % 10]` over a __near char[][32]; form b: `(long)&ram_850c[(unsigned int)(i % 10) * 32]`;
     form c: `(long)(ram_850c + (unsigned int)(i % 10) * 32)` (b and c over a flat __near char array). */
/* cc900-module: DocMed_FormatFileList FmmDocMedleyFunc FmmPdMedleyFunc PdMed_FormatFileList */

#define EVT_PAINT                     0x1c0000bL
#define EVT_PARA_DRAW                 0x1c0000fL
#define EVT_INDEXSW_UP                0x1c00017L
#define EVT_INDEXSW_DOWN              0x1c00018L
#define EVT_SET_SELECTED_FILE_NUMBER  0x1e50002L
#define EVT_GET_SELECTED_FILE_NUMBER  0x1e50003L
#define EVT_PS_FILE_NAME_BOX_ID       0x1e50004L

extern unsigned char __near MEDLEY_PLAY_FLAG;
extern char __near ram_850c[][32];
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
			ret0:
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
					goto ret0;
				SetCurrentFileIndex(ram_8442);
				ApPostEvent(ram_843e, EVT_SET_SELECTED_FILE_NUMBER, ram_8442 % 10);
				if (old / 10 == ram_8442 / 10) {
					ApPostEvent(ram_843e, EVT_PARA_DRAW, (long)ram_850c[old % 10]);
					ApPostEvent(ram_843e, EVT_PARA_DRAW, (long)ram_850c[ram_8442 % 10]);
				} else {
					PdMed_FormatFileList(ram_843e, ram_8442 / 10 * 10);
					FmmPdMedleyFunc(obj, EVT_PAINT, 0);
				}
				goto ret0;
			}
		}
		if (MEDLEY_PLAY_FLAG == 0)
			goto ret0;
		ram_8442 = arg;
		SetCurrentFileIndex(arg);
		ApPostEvent(ram_843e, EVT_SET_SELECTED_FILE_NUMBER, ram_8442 % 10);
		goto ret0;
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
			ret0:
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
					goto ret0;
				FileIO_SelectFileByIndex(ram_84a2);
				ApPostEvent(ram_849e, EVT_SET_SELECTED_FILE_NUMBER, ram_84a2 % 10);
				if (old / 10 == ram_84a2 / 10) {
					ApPostEvent(ram_849e, EVT_PARA_DRAW, (long)ram_850c[old % 10]);
					ApPostEvent(ram_849e, EVT_PARA_DRAW, (long)ram_850c[ram_84a2 % 10]);
				} else {
					DocMed_FormatFileList(ram_849e, ram_84a2 / 10 * 10);
					FmmDocMedleyFunc(obj, EVT_PAINT, 0);
				}
				goto ret0;
			}
		}
		if (MEDLEY_PLAY_FLAG == 0)
			goto ret0;
		ram_84a2 = arg;
		FileIO_SelectFileByIndex(arg);
		ApPostEvent(ram_849e, EVT_SET_SELECTED_FILE_NUMBER, ram_84a2 % 10);
		goto ret0;
	}
	return ram_84a2;
}
