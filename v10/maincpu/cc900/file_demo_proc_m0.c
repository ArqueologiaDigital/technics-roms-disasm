/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ResetProgressIndication */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern void FileIO_DetectFileTypeAndPost(void);

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

/* cc900-module: Audio_WaitForReady Banner_Loop_Check Demo_PreSetup Demo_ReleaseGlidePedal Voice_CopyPreset Voice_LoadVoiceTable */
extern unsigned char __near DEMO_DEBOUNCE;
extern unsigned char __near SWBTWR_PAYLOAD_1;
extern unsigned char __near SWBTWR_PAYLOAD_2;
extern unsigned char __near SWBTWR_PAYLOAD_3;
extern void SwbtB3_CodeA9_Listener0(void);

void SwbtB3_CodeA9_Listener0(void)
{
	if (SWBTWR_PAYLOAD_1 != 32)
		return;
	if ((SWBTWR_PAYLOAD_3 & 0x13) == 0)
		return;
	if (SWBTWR_PAYLOAD_2 & 0x13)
		DEMO_DEBOUNCE = 16;
	else
		DEMO_DEBOUNCE = 0;
}

/* cc900-module: FileIO_CheckRegionSignature FileIO_ReadHeaderAt4 FileIO_ReadHeaderAtF */
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern int FileIO_CheckRegionSignature(int r);
extern void FileIO_CloseHandle(void);
extern int FileIO_LoadRcmToFlash(void);
extern char FileIO_LoadRegion6_Simple_Str_rb[];
extern int FileIO_LoadRegion6_Simple(char *src);
extern void FileIO_ReadBlock(void *, long);
extern void PreMidiLoad(void);
extern void PostMidiLoad(int);
extern void *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void *__cdecl Memset(void *, int, unsigned int);
extern void FlashWrite(int, unsigned char *, unsigned int, long);
extern char FileIO_LoadRegion7_Flash_Str_rb[];
extern int FileIO_LoadRegion7_Flash(char *src);

int FileIO_LoadRegion6_Simple(char *src)
{
	char hd[14];
	int r;

	FileIO_ReadHeader(hd, src, 6);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion6_Simple_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(6) != 0)
		r = FileIO_LoadRcmToFlash();
	else
		r = -102;
	FileIO_CloseHandle();
	return r;
}
int FileIO_LoadRegion7_Flash(char *src)
{
	char hd[14];
	unsigned char *buf;
	int r;

	FileIO_ReadHeader(hd, src, 7);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion7_Flash_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(7) != 0) {
		PreMidiLoad();
		if ((buf = (unsigned char *)Malloc(0x400)) != 0) {
			Memset(buf, 0x400, 0);
			FileIO_ReadBlock(buf, 0x400);
			FlashWrite(1, buf, 0x400, 0x3d3000);
			Free(buf);
			r = FileIO_ReturnError();
		} else
			r = -200;
		PostMidiLoad(r);
	} else
		r = -102;
	FileIO_CloseHandle();
	return r;
}
