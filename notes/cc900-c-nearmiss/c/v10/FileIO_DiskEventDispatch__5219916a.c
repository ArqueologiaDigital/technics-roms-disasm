/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_21m269b.c (2026-11-17-16-p6-r31)
   sha256 5219916a363c201711e5fa61762031046cd0a6d4c7e6b02b6a4f3a4221ec8d76 (tar-sha256); compiled at -O3 -Xr */
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
	case 2:
	case 3:
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
