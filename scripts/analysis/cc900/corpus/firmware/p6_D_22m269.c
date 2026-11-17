/* Phase 6, lane_p6 helper D, round 22, module 269 (v10 demo/file_demo_proc.s), form a (poolnew_D):
   FileIO_GetDiskCapacity, the third disk-type switch of the family that matched in run r31 (FileIO_DiskEventDispatch,
   FileIO_DetectFileTypeAndPost): the ROM compares 3, 2, 1, 0, 5, so the cases are written 5, 0, 1, 2, 3.  Form b
   (p6_D_22m269b.c) writes the shared case labels 3 then 2. */
/* cc900-module: ResetProgressIndication */   /* from scripts/analysis/cc900/module_calls.py v10 */

#define TT_MESAGE   0xee
#define TT_DKUTFRMT 0x7d

extern unsigned char GetDiskSizeInfo(void);
extern void UI_ChangeTitleByIndex(unsigned int);
extern void UI_InterruptTitleByIndex(unsigned int);
extern void ResetProgressIndication(void);

extern int __near DISK_MEDIA_TYPE;
extern unsigned char __near GLOBAL_ERROR_CODE;

void FileIO_GetDiskCapacity(unsigned char a)
{
	if (DISK_MEDIA_TYPE < 0) DISK_MEDIA_TYPE = GetDiskSizeInfo();
	switch (DISK_MEDIA_TYPE) {
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
	case 2:
	case 3:
		UI_ChangeTitleByIndex(a);
		break;
	}
}
