/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_22m269b.c (2026-11-18-1-p6-r33)
   sha256 8dcc8994fc576ae42a736faa6556de0e7505281e85cb92fdb31c326dc2b522de (tar-sha256); compiled at -O3 -Xr */
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
	case 3:
	case 2:
		UI_ChangeTitleByIndex(a);
		break;
	}
}
