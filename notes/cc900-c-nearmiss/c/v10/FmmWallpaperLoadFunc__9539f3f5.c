/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_23r1m269b.c (2026-11-21-27-p6-r68)
   sha256 9539f3f557961da1c857a2d8a305da8e14bd4b5e7d2ff8892d96842160f4eea2 (tar-sha256); compiled at -O3 -Xr */
#define EVT_SHOW                     0x1c00001L
#define EVT_HIDE                     0x1c00002L
#define EVT_ALL_PAINT                0x1c0000aL
#define EVT_PAINT                    0x1c0000bL
#define EVT_PARA_DRAW                0x1c0000fL
#define EVT_ACTIVATE_STATE           0x1c00013L
#define EVT_INDEXSW_UP               0x1c00017L
#define EVT_INDEXSW_DOWN             0x1c00018L
#define EVT_NOT_POST_AIC             0x1c50001L
#define EVT_SET_NOT_DRAW_FLAG        0x1e0009eL
#define EVT_SET_SELECTED_FILE_NUMBER 0x1e50002L
#define EVT_PS_FILE_NAME_BOX_ID      0x1e50004L
#define TT_CTWALLSET                 0x48
#define TT_DKUTFRMT                  0x7d
#define TT_MESAGE                    0xee
extern long __near ram_81b0;
extern int __near ram_81b4;
extern int __near ram_850a;
extern unsigned char __near ram_850c[];
extern int __near DISK_MEDIA_TYPE;
extern unsigned char __near MEDLEY_PLAY_FLAG;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern long ApPostEvent(long, long, long);
extern void InitializeOperationState(int);
extern unsigned char GetDiskSizeInfo(void);
extern void SignalProgressUpdate(void);
extern void ResetProgressIndication(void);
extern void CancelOperationCleanup(void);
extern int FileIO_InitWallpaperNav(void);
extern unsigned char *FileIO_SearchAndLoadFile(void);
extern void GetEncodedFreeSpaceData(void);
extern void UI_ChangeTitleByIndex(unsigned int);
extern void UI_InterruptTitleByIndex(unsigned int);
extern int FileIO_GetCurrentWallpaperIndex(void);
extern void DisplaySmfSequenceList(long obj, int first);
extern int LoadFromSecondaryPage(void);
extern unsigned char FileIO_ValidateSignedValue(int, int);
extern void FileIO_SelectWallpaperByIndex(int);
long FmmWallpaperLoadFunc(long obj, long ev, long p)
{
	int old;
	long w;
	int cur;
	int n;

	w = ram_81b0;
	switch (ev) {
	case EVT_ACTIVATE_STATE:
		switch (p) {
		case 2:
			MEDLEY_PLAY_FLAG = 0;
			InitializeOperationState(1);
			ApPostEvent(0x600026L, EVT_SHOW, 5);
			if (DISK_MEDIA_TYPE < 0) {
				DISK_MEDIA_TYPE = GetDiskSizeInfo();
				SignalProgressUpdate();
			}
			switch (DISK_MEDIA_TYPE) {
			default:
				if (ram_850a < 0) {
					ram_850a = FileIO_InitWallpaperNav();
					FileIO_SearchAndLoadFile();
					GetEncodedFreeSpaceData();
					SignalProgressUpdate();
				}
				ApPostEvent(0x600026L, EVT_HIDE, 0);
				ApPostEvent(0xffffffffL, EVT_ALL_PAINT, 0);
				break;
			case 5:
				ApPostEvent(0x600026L, EVT_HIDE, 0);
				ApPostEvent(0xffffffffL, EVT_SET_NOT_DRAW_FLAG, 1);
				UI_ChangeTitleByIndex(TT_CTWALLSET);
				ApPostEvent(0xffffffffL, EVT_SET_NOT_DRAW_FLAG, 0);
				GLOBAL_ERROR_CODE = 0;
				UI_InterruptTitleByIndex(TT_MESAGE);
				break;
			case 0:
				ApPostEvent(0x600026L, EVT_HIDE, 0);
				UI_ChangeTitleByIndex(TT_DKUTFRMT);
				break;
			case 1:
				ResetProgressIndication();
				ApPostEvent(0x600026L, EVT_HIDE, 0);
				ApPostEvent(0xffffffffL, EVT_SET_NOT_DRAW_FLAG, 1);
				UI_ChangeTitleByIndex(TT_CTWALLSET);
				ApPostEvent(0xffffffffL, EVT_SET_NOT_DRAW_FLAG, 0);
				GLOBAL_ERROR_CODE = 2;
				UI_InterruptTitleByIndex(TT_MESAGE);
				break;
			}
			break;
		case 3:
			CancelOperationCleanup();
			break;
		}
		break;
	case EVT_PS_FILE_NAME_BOX_ID:
		ram_81b0 = p;
		ram_81b4 = FileIO_GetCurrentWallpaperIndex();
		if (ram_81b4 < 0)
			ram_81b4 = 0;
		ApPostEvent(ram_81b0, EVT_SET_SELECTED_FILE_NUMBER, ram_81b4 % 10);
		break;
	case EVT_PAINT:
		DisplaySmfSequenceList(w, ram_81b4 / 10 * 10);
		break;
	case EVT_INDEXSW_UP:
	case EVT_INDEXSW_DOWN:
		ApPostEvent(w, EVT_NOT_POST_AIC, 1);
		cur = ram_81b4;
		old = cur;
		if (p == 0) {
			if (ev == EVT_INDEXSW_DOWN) {
				if (cur + 1 < ram_850a)
					ram_81b4 = cur + 1;
			} else if (ev == EVT_INDEXSW_UP) {
				if (cur > 0)
					ram_81b4 = cur - 1;
			}
		} else if (p == 1) {
			if (cur >= 10)
				ram_81b4 = cur - 10;
		} else if (p == 2) {
			n = ram_850a;
			if (cur + 10 < n)
				ram_81b4 = cur + 10;
			else if (cur / 10 < (n - 1) / 10 && n % 10 != 0)
				ram_81b4 = n - 1;
		} else if (p == 3) {
			ApPostEvent(0x600026L, EVT_SHOW, 5);
			InitializeOperationState(0);
			GLOBAL_ERROR_CODE = FileIO_ValidateSignedValue(LoadFromSecondaryPage(), 1);
			SignalProgressUpdate();
			ApPostEvent(0x600026L, EVT_HIDE, 0);
			ApPostEvent(0xffffffffL, EVT_SET_NOT_DRAW_FLAG, 1);
			UI_ChangeTitleByIndex(TT_CTWALLSET);
			ApPostEvent(0xffffffffL, EVT_SET_NOT_DRAW_FLAG, 0);
			UI_InterruptTitleByIndex(TT_MESAGE);
		}
		if (old != ram_81b4) {
			FileIO_SelectWallpaperByIndex(ram_81b4);
			ApPostEvent(ram_81b0, EVT_SET_SELECTED_FILE_NUMBER, ram_81b4 % 10);
			if (old / 10 == ram_81b4 / 10) {
				ApPostEvent(ram_81b0, EVT_PARA_DRAW, (long)&ram_850c[(unsigned int)(old % 10) * 32]);
				ApPostEvent(ram_81b0, EVT_PARA_DRAW, (long)&ram_850c[(unsigned int)(ram_81b4 % 10) * 32]);
			} else
				DisplaySmfSequenceList(ram_81b0, ram_81b4 / 10 * 10);
		}
		ApPostEvent(ram_81b0, EVT_NOT_POST_AIC, 0);
		break;
	}
	return 0;
}
