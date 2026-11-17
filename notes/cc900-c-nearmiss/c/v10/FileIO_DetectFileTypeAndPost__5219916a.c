/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_21m269b.c (2026-11-17-16-p6-r31)
   sha256 5219916a363c201711e5fa61762031046cd0a6d4c7e6b02b6a4f3a4221ec8d76 (tar-sha256); compiled at -O3 -Xr */
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
void FileIO_DetectFileTypeAndPost(void)
{
	if (DISK_MEDIA_TYPE < 0) DISK_MEDIA_TYPE = GetDiskSizeInfo();
	switch (DISK_MEDIA_TYPE) {
	case 3:
		UI_ChangeTitleByIndex(TT_DKDPSMF);
		break;
	case 2:
		if (DetectFileType() >= 0) UI_ChangeTitleByIndex(TT_DKDPDOC);
		else UI_ChangeTitleByIndex(TT_DKDPSMF);
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
