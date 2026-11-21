/* lane_p6 helper D, round 23r1, form a: module 269 (file_io/disk_operations.s, file_io/filename_password.s), from
   roots23_B's DiskInfoFunc stretch (f8c60f).
   DiskInfoFunc: EV_PAINT handler of the DISK INFO page; capacity / free space by media type (switch, compares in
   reverse source order), percentage through Math_Multiply32 / Math_DivideSigned32 (product kept in a variable,
   the ROM's XIZ), free space shifted to KB (signed /1024), then " : " / KB free ( / % used) appended to 0x87ce.
   Frame: free, pct, cap in declaration order (+4, +8, +12), p above.  ROM `ld xwa, 0x87ce` = constant, `lda` =
   the __near array (the nested strcat calls).
   FmmPasswordFunc: MT_SetPassword / MT_CheckPassword / 2 / 3 switch; PASSWORD_STATE's second byte holds two bit
   fields (bit 7 = first declared, as AUDIO_STATE's chg); the three forwarding calls are identical statements.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FmmFileNameFunc FmmSaveFilterFunc FmmSeqSongNameFunc InitializeOperationState NumToAscii_FormatNumber ResetProgressIndication */
/* cc900-name: DiStrColon=DiskInfo_RenderStrings_Str_Colon */
/* cc900-name: DiStrKbFree=DiskInfo_RenderStrings_Str_KB_free */
/* cc900-name: DiStrUsed=DiskInfo_RenderStrings_Str_Fmtu_sed */

#define EVT_PAINT            0x1c0000bL
#define EVT_PARA_DRAW        0x1c0000fL
#define EVT_INDEXSW_UP       0x1c00017L
#define EVT_SET_PASSWORD     0x1e5000dL
#define EVT_CHECK_PASSWORD   0x1e5000eL
#define EVT_CHECK_PASSWORD2  0x1e5000fL
#define EVT_CHECK_PASSWORD3  0x1e50010L
#define TT_MESAGE            0xee

struct pwstate {
	unsigned char mode;
	unsigned char load:1;
	unsigned char save:1;
	unsigned char rest:6;
};

extern int __near DISK_MEDIA_TYPE;
extern __near char ram_87ce[];
extern struct pwstate __near PASSWORD_STATE;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern char *DiskInfo_MediaTypeNames[];
extern char DiStrColon[];
extern char DiStrKbFree[];
extern char DiStrUsed[];

extern long ApPostEvent(long, long, long);
extern void InitializeOperationState(int);
extern unsigned char GetDiskSizeInfo(void);
extern long GetEncodedFreeSpaceData(void);
extern long FileIO_GetDiskRecordPtr(void);
extern void ResetProgressIndication(void);
extern long Math_Multiply32(long, long);
extern long Math_DivideSigned32(long, long);
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern char *NumToAscii_FormatNumber(long, int);
extern void UI_InterruptTitleByIndex(unsigned int);
extern unsigned char CheckAnySlotHasData(void);
extern unsigned char Composer_HasPassword(void);
extern void ClearAllSongSlots(int);
extern void Composer_SetPassword(int);
extern unsigned char CheckSlotIsSelected(int);
extern unsigned char Composer_IsPassword(int);
extern long FmmFileNameFunc(long, long, long);
extern long FmmSaveFilterFunc(long, long, unsigned long);
extern long FmmSeqSongNameFunc(long, long, long);

long DiskInfoFunc(long obj, long evt, long p)
{
	long free;
	long pct;
	long cap;
	long t;

	if (evt == EVT_PAINT) {
		InitializeOperationState(0);
		if (DISK_MEDIA_TYPE < 0) DISK_MEDIA_TYPE = GetDiskSizeInfo();
		switch (DISK_MEDIA_TYPE) {
		case 3:
		case 2:
			free = GetEncodedFreeSpaceData();
			cap = FileIO_GetDiskRecordPtr();
			break;
		case 0:
		case 1:
			ResetProgressIndication();
		default:
			cap = 0;
			free = 0;
			break;
		}
		if (cap > 0) {
			t = Math_Multiply32(cap - free, 100);
			pct = Math_DivideSigned32(t, cap);
		} else {
			pct = 0;
		}
		free /= 1024;
		FileIO_CopyString((char *)0x87ceL, DiskInfo_MediaTypeNames[DISK_MEDIA_TYPE]);
		FileIO_BuildFilePath((char *)0x87ceL, DiStrColon);
		FileIO_BuildFilePath(ram_87ce, NumToAscii_FormatNumber(free, 4));
		FileIO_BuildFilePath((char *)0x87ceL, DiStrKbFree);
		FileIO_BuildFilePath(ram_87ce, NumToAscii_FormatNumber(pct, 3));
		FileIO_BuildFilePath((char *)0x87ceL, DiStrUsed);
		ApPostEvent(p, EVT_PARA_DRAW, 0x87ceL);
	}
	return 0;
}

long FmmPasswordFunc(long obj, long evt, long p)
{
	switch (evt) {
	case EVT_SET_PASSWORD:
		if (CheckAnySlotHasData() != 0 || Composer_HasPassword() != 0) {
			GLOBAL_ERROR_CODE = 10;
			UI_InterruptTitleByIndex(TT_MESAGE);
		} else {
			ClearAllSongSlots((int)p);
			Composer_SetPassword((int)p);
			PASSWORD_STATE.load = 1;
			PASSWORD_STATE.save = 1;
		}
		break;
	case EVT_CHECK_PASSWORD:
		if (PASSWORD_STATE.mode == 3 && CheckSlotIsSelected((int)p) != 0 && Composer_IsPassword((int)p) != 0) {
			PASSWORD_STATE.load = 1;
			PASSWORD_STATE.save = 1;
			FmmFileNameFunc(obj, EVT_INDEXSW_UP, 4);
		} else if (PASSWORD_STATE.mode == 1 && CheckSlotIsSelected((int)p) != 0) {
			PASSWORD_STATE.load = 1;
			FmmFileNameFunc(obj, EVT_INDEXSW_UP, 4);
		} else if (PASSWORD_STATE.mode == 2 && Composer_IsPassword((int)p) != 0) {
			PASSWORD_STATE.save = 1;
			FmmFileNameFunc(obj, EVT_INDEXSW_UP, 4);
		} else {
			GLOBAL_ERROR_CODE = 11;
			UI_InterruptTitleByIndex(TT_MESAGE);
		}
		break;
	case EVT_CHECK_PASSWORD2:
		if (PASSWORD_STATE.mode == 3 && CheckSlotIsSelected((int)p) != 0 && Composer_IsPassword((int)p) != 0) {
			PASSWORD_STATE.load = 1;
			PASSWORD_STATE.save = 1;
			FmmSaveFilterFunc(obj, EVT_INDEXSW_UP, 10);
		} else if (PASSWORD_STATE.mode == 1 && CheckSlotIsSelected((int)p) != 0) {
			PASSWORD_STATE.load = 1;
			FmmSaveFilterFunc(obj, EVT_INDEXSW_UP, 10);
		} else if (PASSWORD_STATE.mode == 2 && Composer_IsPassword((int)p) != 0) {
			PASSWORD_STATE.save = 1;
			FmmSaveFilterFunc(obj, EVT_INDEXSW_UP, 10);
		} else {
			GLOBAL_ERROR_CODE = 11;
			UI_InterruptTitleByIndex(TT_MESAGE);
		}
		break;
	case EVT_CHECK_PASSWORD3:
		if (CheckSlotIsSelected((int)p) != 0) {
			PASSWORD_STATE.load = 1;
			FmmSeqSongNameFunc(obj, EVT_INDEXSW_UP, 4);
		} else {
			GLOBAL_ERROR_CODE = 11;
			UI_InterruptTitleByIndex(TT_MESAGE);
		}
		break;
	}
	return 0;
}
