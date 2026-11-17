/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_E_9m269.c (2026-11-16-118-p6-r23)
   sha256 c0457747951175576fcc341162481c51f04eaabe898c682abd9c473af27eb29a (tar-sha256); compiled at -O3 -Xr */
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
extern long ApPostEvent(long, long, long);
extern int GetCurrentFileIndexAlt(void);
extern void SetCurrentFileIndex(int);
extern void PdMed_FormatFileList(long, int);
extern long FmmPdMedleyFunc(long, long, long);
long FmmPdFileNameFunc(long obj, long ev, long arg)
{
	int old;
	int page;

	if (ev == EVT_GET_SELECTED_FILE_NUMBER)
		return ram_8442;
	old = ram_8442;
	if (ev == EVT_SET_SELECTED_FILE_NUMBER) {
		if (MEDLEY_PLAY_FLAG == 0)
			return 0;
		ram_8442 = arg;
		SetCurrentFileIndex(arg);
		ApPostEvent(ram_843e, EVT_SET_SELECTED_FILE_NUMBER, ram_8442 % 10);
		return 0;
	}
	page = old / 10;
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
		return 0;
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
			return 0;
		SetCurrentFileIndex(ram_8442);
		ApPostEvent(ram_843e, EVT_SET_SELECTED_FILE_NUMBER, ram_8442 % 10);
		if (old / 10 == ram_8442 / 10) {
			ApPostEvent(ram_843e, EVT_PARA_DRAW, (long)ram_850c[old % 10]);
			ApPostEvent(ram_843e, EVT_PARA_DRAW, (long)ram_850c[ram_8442 % 10]);
		} else {
			PdMed_FormatFileList(ram_843e, ram_8442 / 10 * 10);
			FmmPdMedleyFunc(obj, EVT_PAINT, 0);
		}
		return 0;
	}
	return 0;
}
