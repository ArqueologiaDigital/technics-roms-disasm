/* Phase 6, lane_p6 helper E, round 12, module 269 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): v10
   file_io/medley.s (adecl; the ROM's code is -O3 -Xr's: run 128 at O3Xr differs only in the spots below, while
   O3XSXr differs from +18 on in many), under the firmware names.  Form a; p6_E_12m269b.c and p6_E_12m269c.c have the same names.
   FmmPdFileNameFunc / FmmDocFileNameFunc: see p6_E_9m269.c.  Round 11 put the shared `return 0` where the ROM has it
   (after the PAINT case).  Left at O3Xr (run 128):
   - TAIL MERGING: the ROM ends the PS_FILE_NAME_BOX_ID case by jumping into the SET branch's identical tail (its
     last ApPostEvent call and the jump to `return 0`), but keeps the UP / DOWN case's last ApPostEvent call
     separate.  V4.23 merged the other way round: BOX's `return 0` and SET's `goto ret0` differed, UP / DOWN's
     `goto ret0` equalled SET's.  So now BOX and SET both leave with `goto ret0`, and UP / DOWN with `break`
     (to a `goto ret0` after the if / else).
   - the redraw row's address: the ROM loads the table into XHL (XBC) and builds the address in DE from the index
     (`ld de,bc` / `extz xde` / `add xde,xhl`); V4.23 built it in the index's register and moved it.  Form a:
     `(unsigned long)((unsigned int)(i % 10) * 32) + (unsigned long)ram_850c`; form b: round 9's
     `(long)ram_850c[i % 10]` over a __near char[][32]; form c: `(long)(unsigned int)((i % 10) << 5) +
     (long)ram_850c`. */
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
				goto ret0;
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
					break;
				SetCurrentFileIndex(ram_8442);
				ApPostEvent(ram_843e, EVT_SET_SELECTED_FILE_NUMBER, ram_8442 % 10);
				if (old / 10 == ram_8442 / 10) {
					ApPostEvent(ram_843e, EVT_PARA_DRAW, (unsigned long)((unsigned int)(old % 10) * 32) + (unsigned long)ram_850c);
					ApPostEvent(ram_843e, EVT_PARA_DRAW, (unsigned long)((unsigned int)(ram_8442 % 10) * 32) + (unsigned long)ram_850c);
				} else {
					PdMed_FormatFileList(ram_843e, ram_8442 / 10 * 10);
					FmmPdMedleyFunc(obj, EVT_PAINT, 0);
				}
				break;
			}
		} else {
			if (MEDLEY_PLAY_FLAG == 0)
				goto ret0;
			ram_8442 = arg;
			SetCurrentFileIndex(arg);
			ApPostEvent(ram_843e, EVT_SET_SELECTED_FILE_NUMBER, ram_8442 % 10);
			goto ret0;
		}
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
				goto ret0;
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
					break;
				FileIO_SelectFileByIndex(ram_84a2);
				ApPostEvent(ram_849e, EVT_SET_SELECTED_FILE_NUMBER, ram_84a2 % 10);
				if (old / 10 == ram_84a2 / 10) {
					ApPostEvent(ram_849e, EVT_PARA_DRAW, (unsigned long)((unsigned int)(old % 10) * 32) + (unsigned long)ram_850c);
					ApPostEvent(ram_849e, EVT_PARA_DRAW, (unsigned long)((unsigned int)(ram_84a2 % 10) * 32) + (unsigned long)ram_850c);
				} else {
					DocMed_FormatFileList(ram_849e, ram_84a2 / 10 * 10);
					FmmDocMedleyFunc(obj, EVT_PAINT, 0);
				}
				break;
			}
		} else {
			if (MEDLEY_PLAY_FLAG == 0)
				goto ret0;
			ram_84a2 = arg;
			FileIO_SelectFileByIndex(arg);
			ApPostEvent(ram_849e, EVT_SET_SELECTED_FILE_NUMBER, ram_84a2 % 10);
			goto ret0;
		}
		goto ret0;
	}
	return ram_84a2;
}
