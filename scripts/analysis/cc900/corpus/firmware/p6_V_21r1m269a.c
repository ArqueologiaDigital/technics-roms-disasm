/* helper V, round 21r1, module 269 (file_io/composer_filters.s): FmmSaveFilterFunc, the SAVE filter page's
   function: eight 16-byte rows at 0x800a (RenderSaveFilterDisplay), INDEX up / down on a row (< 8) locks or unlocks
   that region (FileIO_BuildRecordPath_Done / _Return; row 1 also checks the record attribute), rows 8 / 9 / 0x0b
   select / lock / unlock all, 0x0a saves (password, confirmation, then FileIO_SaveAllRegions), 0x32 saves directly.
   The ROM keeps arg and the row counter in the frame and evt in XBC.  The switch's cases are in reverse compare
   order (BOX ID, PAINT, UP / DOWN).  Form a. */
/* cc900-module: FileIO_ValidateSignedValue InitializeOperationState RenderSaveFilterDisplay SelectPasswordMode SignalProgressUpdate */

#define EVT_SHOW                0x1c00001L
#define EVT_HIDE                0x1c00002L
#define EVT_PAINT               0x1c0000bL
#define EVT_PARA_DRAW           0x1c0000fL
#define EVT_INDEXSW_UP          0x1c00017L
#define EVT_INDEXSW_DOWN        0x1c00018L
#define EVT_NOT_PARA_DRAW       0x1c50000L
#define EVT_WAKEUP_PASSWORD     0x1c50004L
#define EVT_SET_NOT_DRAW_FLAG   0x1e0009eL
#define EVT_PS_FILE_NAME_BOX_ID 0x1e50004L
#define MD_NORMAL               1
#define TT_MESAGE               0xee

struct frow { char s[16]; };
extern struct frow __near ram_800a[];
extern long __near ram_8006;
extern int __near ram_8502;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern unsigned char __near PASSWORD_STATE;
extern unsigned char SURE_CONFIRM;
extern long ApPostEvent(long, long, long);
extern void RenderSaveFilterDisplay(char *p, unsigned char c);
extern unsigned char FileIO_GetRecordAttr_Check(void);
extern void FileIO_SetModeFlag_Reading(void);
extern void FileIO_SetModeFlag_Writing(void);
extern unsigned char FileIO_FormatName_Return(unsigned char);
extern void FileIO_BuildRecordPath_Done(unsigned char);
extern void FileIO_BuildRecordPath_Return(unsigned char);
extern unsigned int FileIO_FormatName_Done(void);
extern int SelectPasswordMode(void);
extern unsigned int CheckFileSystemStatus(void);
extern void InitializeOperationState(unsigned char);
extern int FileIO_SaveAllRegions(void);
extern unsigned char FileIO_ValidateSignedValue(int, int);
extern void FileIO_ResetCurrentRecord(void);
extern long GetEncodedFreeSpaceData(void);
extern int GetEncodedFileSizeData(void);
extern void SignalProgressUpdate(void);
extern void UI_ChangeModeByIndex(unsigned char);
extern void UI_InterruptTitleByIndex(unsigned char);

long FmmSaveFilterFunc(long obj, long evt, unsigned long arg)
{
	int i;

	switch (evt) {
	case EVT_PS_FILE_NAME_BOX_ID:
		ram_8006 = arg;
		break;
	case EVT_PAINT:
		for (i = 0; i < 8; i++) {
			RenderSaveFilterDisplay(ram_800a[i].s, i);
			ApPostEvent(ram_8006, EVT_PARA_DRAW, (long)ram_800a[i].s);
		}
		break;
	case EVT_INDEXSW_UP:
	case EVT_INDEXSW_DOWN:
		if (arg < 8) {
			if (arg == 1) {
				if (evt == EVT_INDEXSW_UP) {
					if (FileIO_GetRecordAttr_Check() != 0) {
						FileIO_SetModeFlag_Reading();
						FileIO_BuildRecordPath_Return(arg);
					} else
						FileIO_BuildRecordPath_Done(arg);
				} else if (FileIO_FormatName_Return(arg) != 0) {
					if (FileIO_GetRecordAttr_Check() == 0)
						FileIO_BuildRecordPath_Return(arg);
				} else if (FileIO_GetRecordAttr_Check() == 0) {
					FileIO_SetModeFlag_Writing();
					FileIO_BuildRecordPath_Done(arg);
				}
			} else if (evt == EVT_INDEXSW_UP)
				FileIO_BuildRecordPath_Done(arg);
			else
				FileIO_BuildRecordPath_Return(arg);
			RenderSaveFilterDisplay(ram_800a[(unsigned char)arg].s, arg);
			ApPostEvent(ram_8006, EVT_PARA_DRAW, (long)ram_800a[(unsigned char)arg].s);
		} else if (arg == 8) {
			FileIO_SetModeFlag_Reading();
			for (i = 0; i < 8; i++) {
				if (i < 6)
					FileIO_BuildRecordPath_Done(i);
				else
					FileIO_BuildRecordPath_Return(i);
				RenderSaveFilterDisplay(ram_800a[i].s, i);
				ApPostEvent(ram_8006, EVT_PARA_DRAW, (long)ram_800a[i].s);
			}
		} else if (arg == 9) {
			FileIO_SetModeFlag_Reading();
			for (i = 0; i < 8; i++) {
				FileIO_BuildRecordPath_Done(i);
				RenderSaveFilterDisplay(ram_800a[i].s, i);
				ApPostEvent(ram_8006, EVT_PARA_DRAW, (long)ram_800a[i].s);
			}
		} else if (arg == 0xa && FileIO_FormatName_Done() != 0) {
			if (SelectPasswordMode() != 0)
				ApPostEvent(-1L, EVT_WAKEUP_PASSWORD, PASSWORD_STATE);
			else if (CheckFileSystemStatus() != 0 && SURE_CONFIRM != 0) {
				ApPostEvent(-1L, EVT_NOT_PARA_DRAW, 1);
				ApPostEvent(0x600037L, EVT_SHOW, 0);
			} else {
				ApPostEvent(0x600026L, EVT_SHOW, 5);
				InitializeOperationState(0);
				GLOBAL_ERROR_CODE = FileIO_ValidateSignedValue(FileIO_SaveAllRegions(), 5);
				FileIO_ResetCurrentRecord();
				GetEncodedFreeSpaceData();
				ram_8502 = GetEncodedFileSizeData();
				SignalProgressUpdate();
				ApPostEvent(0x600026L, EVT_HIDE, 0);
				ApPostEvent(-1L, EVT_SET_NOT_DRAW_FLAG, 1);
				UI_ChangeModeByIndex(MD_NORMAL);
				ApPostEvent(-1L, EVT_SET_NOT_DRAW_FLAG, 0);
				UI_InterruptTitleByIndex(TT_MESAGE);
			}
		} else if (arg == 0x32) {
			ApPostEvent(0x600026L, EVT_SHOW, 5);
			InitializeOperationState(0);
			GLOBAL_ERROR_CODE = FileIO_ValidateSignedValue(FileIO_SaveAllRegions(), 5);
			FileIO_ResetCurrentRecord();
			GetEncodedFreeSpaceData();
			ram_8502 = GetEncodedFileSizeData();
			SignalProgressUpdate();
			ApPostEvent(0x600026L, EVT_HIDE, 0);
			ApPostEvent(-1L, EVT_SET_NOT_DRAW_FLAG, 1);
			UI_ChangeModeByIndex(MD_NORMAL);
			ApPostEvent(-1L, EVT_SET_NOT_DRAW_FLAG, 0);
			UI_InterruptTitleByIndex(TT_MESAGE);
		} else if (arg == 0xb) {
			FileIO_SetModeFlag_Reading();
			for (i = 0; i < 8; i++) {
				FileIO_BuildRecordPath_Return(i);
				RenderSaveFilterDisplay(ram_800a[i].s, i);
				ApPostEvent(ram_8006, EVT_PARA_DRAW, (long)ram_800a[i].s);
			}
		}
		break;
	}
	return 0;
}
