/* Phase 6, lane_p6 helper E, round 9, module 269: v10 file_io/medley.s, under the firmware names.  FORM B of
   p6_E_9m269.c (form a, whose comment describes the routines): the SET_SELECTED_FILE_NUMBER case as the else of
   `if (ev != SET)` (the ROM lays its body out after the switch, near the end), and the page compare written
   `new / 10 == old / 10` (the ROM divides the new index first). */
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

	if (ev == EVT_GET_SELECTED_FILE_NUMBER)
		return ram_8442;
	old = ram_8442;
	if (ev != EVT_SET_SELECTED_FILE_NUMBER) {
		page = old / 10;
		switch (ev) {
		case EVT_PS_FILE_NAME_BOX_ID:
			ram_843e = arg;
			ram_8442 = GetCurrentFileIndexAlt();
			if (ram_8442 < 0)
				ram_8442 = 0;
			ApPostEvent(ram_843e, EVT_SET_SELECTED_FILE_NUMBER, ram_8442 % 10);
			break;
		case EVT_PAINT:
			PdMed_FormatFileList(ram_843e, page * 10);
			break;
		case EVT_INDEXSW_UP:
		case EVT_INDEXSW_DOWN:
			if (arg == 0 && MEDLEY_PLAY_FLAG == 0) {
				if (ev == EVT_INDEXSW_DOWN) {
					if (old + 1 < ram_8506)
						ram_8442 = old + 1;
				} else if (ev == EVT_INDEXSW_UP) {
					if (old > 0)
						ram_8442 = old - 1;
				}
			} else if (arg == 1 && MEDLEY_PLAY_FLAG == 0) {
				if (old >= 10)
					ram_8442 = old - 10;
			} else if (arg == 2 && MEDLEY_PLAY_FLAG == 0) {
				if (old + 10 < ram_8506)
					ram_8442 = old + 10;
				else if (page < (ram_8506 - 1) / 10 && ram_8506 % 10 != 0)
					ram_8442 = ram_8506 - 1;
			}
			if (old == ram_8442)
				break;
			SetCurrentFileIndex(ram_8442);
			ApPostEvent(ram_843e, EVT_SET_SELECTED_FILE_NUMBER, ram_8442 % 10);
			if (ram_8442 / 10 == old / 10) {
				ApPostEvent(ram_843e, EVT_PARA_DRAW, (long)ram_850c[old % 10]);
				ApPostEvent(ram_843e, EVT_PARA_DRAW, (long)ram_850c[ram_8442 % 10]);
			} else {
				PdMed_FormatFileList(ram_843e, ram_8442 / 10 * 10);
				FmmPdMedleyFunc(obj, EVT_PAINT, 0);
			}
			break;
		}
	} else if (MEDLEY_PLAY_FLAG != 0) {
		ram_8442 = arg;
		SetCurrentFileIndex(arg);
		ApPostEvent(ram_843e, EVT_SET_SELECTED_FILE_NUMBER, ram_8442 % 10);
	}
	return 0;
}

long FmmDocFileNameFunc(long obj, long ev, long arg)
{
	int old;
	int page;

	if (ev == EVT_GET_SELECTED_FILE_NUMBER)
		return ram_84a2;
	old = ram_84a2;
	if (ev != EVT_SET_SELECTED_FILE_NUMBER) {
		page = old / 10;
		switch (ev) {
		case EVT_PS_FILE_NAME_BOX_ID:
			ram_849e = arg;
			ram_84a2 = FileIO_GetCurrentFileIndex_Alt();
			if (ram_84a2 < 0)
				ram_84a2 = 0;
			ApPostEvent(ram_849e, EVT_SET_SELECTED_FILE_NUMBER, ram_84a2 % 10);
			break;
		case EVT_PAINT:
			DocMed_FormatFileList(ram_849e, page * 10);
			break;
		case EVT_INDEXSW_UP:
		case EVT_INDEXSW_DOWN:
			if (arg == 0 && MEDLEY_PLAY_FLAG == 0) {
				if (ev == EVT_INDEXSW_DOWN) {
					if (old + 1 < ram_8508)
						ram_84a2 = old + 1;
				} else if (ev == EVT_INDEXSW_UP) {
					if (old > 0)
						ram_84a2 = old - 1;
				}
			} else if (arg == 1 && MEDLEY_PLAY_FLAG == 0) {
				if (old >= 10)
					ram_84a2 = old - 10;
			} else if (arg == 2 && MEDLEY_PLAY_FLAG == 0) {
				if (old + 10 < ram_8508)
					ram_84a2 = old + 10;
				else if (page < (ram_8508 - 1) / 10 && ram_8508 % 10 != 0)
					ram_84a2 = ram_8508 - 1;
			}
			if (old == ram_84a2)
				break;
			FileIO_SelectFileByIndex(ram_84a2);
			ApPostEvent(ram_849e, EVT_SET_SELECTED_FILE_NUMBER, ram_84a2 % 10);
			if (ram_84a2 / 10 == old / 10) {
				ApPostEvent(ram_849e, EVT_PARA_DRAW, (long)ram_850c[old % 10]);
				ApPostEvent(ram_849e, EVT_PARA_DRAW, (long)ram_850c[ram_84a2 % 10]);
			} else {
				DocMed_FormatFileList(ram_849e, ram_84a2 / 10 * 10);
				FmmDocMedleyFunc(obj, EVT_PAINT, 0);
			}
			break;
		}
	} else if (MEDLEY_PLAY_FLAG != 0) {
		ram_84a2 = arg;
		FileIO_SelectFileByIndex(arg);
		ApPostEvent(ram_849e, EVT_SET_SELECTED_FILE_NUMBER, ram_84a2 % 10);
	}
	return 0;
}
