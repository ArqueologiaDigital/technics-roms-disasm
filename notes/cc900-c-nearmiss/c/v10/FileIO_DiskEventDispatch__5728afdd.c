/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/file_demo_proc_m269.c (2026-11-17-19-p6-r32-staged)
   sha256 5728afddfb4a20683ad71ab2e0133aaf4c7c382d85adf99acf7e278e725c9f64 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define TT_MESAGE   0xee
#define TT_DKUTFRMT 0x7d
extern unsigned char GetDiskSizeInfo(void);
extern void UI_ChangeTitleByIndex(unsigned int);
extern void UI_InterruptTitleByIndex(unsigned int);
extern void ResetProgressIndication(void);
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
