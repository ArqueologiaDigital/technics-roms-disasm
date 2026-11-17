/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_E_12m269c.c (2026-11-17-2-p6-r29)
   sha256 dfe97e08ba848e9ea0164de55653102945038d040a3b567b3f126e4d1b42fcc9 (tar-sha256); compiled at -O3 -Xr */
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
extern long ApPostEvent(long, long, long);
extern int GetCurrentFileIndexAlt(void);
extern void SetCurrentFileIndex(int);
extern void PdMed_FormatFileList(long, int);
extern long FmmPdMedleyFunc(long, long, long);
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
					ApPostEvent(ram_843e, EVT_PARA_DRAW, (long)(unsigned int)((old % 10) << 5) + (long)ram_850c);
					ApPostEvent(ram_843e, EVT_PARA_DRAW, (long)(unsigned int)((ram_8442 % 10) << 5) + (long)ram_850c);
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
