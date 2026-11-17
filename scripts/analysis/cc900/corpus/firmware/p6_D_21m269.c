/* Phase 6, lane_p6 helper D, round 21, module 269 (v10 demo/file_demo_proc.s), form a (poolnew_D):
   FileIO_DiskEventDispatch and FileIO_DetectFileTypeAndPost (the 199-byte label distance covers both).  Each
   fetches the disk type once (DISK_MEDIA_TYPE < 0: GetDiskSizeInfo) and switches on it; the cases are written
   last-first against the ROM's compare order (1, 0, 5, 2, 3).  The title calls the ROM shares between cases
   (one call / one tail jump) come from V4.23's tail merging.  TT_MESAGE 0xee, TT_DKUTFRMT 0x7d, TT_DKDPSMF 0x6c,
   TT_DKDPDOC 0x6d, TT_DKDPPD 0x6e.  Form b (p6_D_21m269b.c) swaps the shared case labels and the
   DetectFileType test. */
/* cc900-module: ResetProgressIndication */   /* from scripts/analysis/cc900/module_calls.py v10 */

#define TT_MESAGE   0xee
#define TT_DKUTFRMT 0x7d
#define TT_DKDPSMF  0x6c
#define TT_DKDPDOC  0x6d
#define TT_DKDPPD   0x6e

extern unsigned char GetDiskSizeInfo(void);
extern void UI_ChangeTitleByIndex(unsigned int);
extern void UI_InterruptTitleByIndex(unsigned int);
extern void ResetProgressIndication(void);
extern int DetectFileType(void);

extern int __near DISK_MEDIA_TYPE;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern unsigned char ram_340f4;

void FileIO_DiskEventDispatch(unsigned char a, unsigned char c)
{
	if (DISK_MEDIA_TYPE < 0) DISK_MEDIA_TYPE = GetDiskSizeInfo();
	switch (DISK_MEDIA_TYPE) {
	case 3:
	case 2:
		if (ram_340f4 & 1) UI_ChangeTitleByIndex(c);
		else UI_ChangeTitleByIndex(a);
		break;
	case 5:
		GLOBAL_ERROR_CODE = 0;
		UI_InterruptTitleByIndex(TT_MESAGE);
		break;
	case 0:
		UI_ChangeTitleByIndex(TT_DKUTFRMT);
		break;
	case 1:
		ResetProgressIndication();
		GLOBAL_ERROR_CODE = 2;
		UI_InterruptTitleByIndex(TT_MESAGE);
		break;
	}
}

void FileIO_DetectFileTypeAndPost(void)
{
	if (DISK_MEDIA_TYPE < 0) DISK_MEDIA_TYPE = GetDiskSizeInfo();
	switch (DISK_MEDIA_TYPE) {
	case 3:
		UI_ChangeTitleByIndex(TT_DKDPSMF);
		break;
	case 2:
		if (DetectFileType() < 0) UI_ChangeTitleByIndex(TT_DKDPSMF);
		else UI_ChangeTitleByIndex(TT_DKDPDOC);
		break;
	case 5:
		UI_ChangeTitleByIndex(TT_DKDPPD);
		break;
	case 0:
		UI_ChangeTitleByIndex(TT_DKUTFRMT);
		break;
	case 1:
		ResetProgressIndication();
		GLOBAL_ERROR_CODE = 2;
		UI_InterruptTitleByIndex(TT_MESAGE);
		break;
	}
}
