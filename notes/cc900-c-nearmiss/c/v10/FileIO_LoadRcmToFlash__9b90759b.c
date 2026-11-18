/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_14m159b.c (2026-11-18-1-p6-r33)
   sha256 9b90759b5da134cd3805db3eb3a0f1a0afaa5b593e65fbdab4e0c9fe0d137d04 (tar-sha256); compiled at -Xr */
struct rcmhdr { unsigned char id[68]; long size[7]; unsigned char rest[928]; };
struct blk64k { unsigned int w[0x8000]; };
extern void Flash_InitExtMemAddrs(void);
extern void NoteEvent_LoadSoundGenParams(void);
extern void NoteEventBuffer_Store(int);
extern void FileIO_ReadBlock(void *, long);
extern int FileIO_ReturnError(void);
extern void Flash_EraseSectorAndWrite(int, unsigned char *, unsigned char *);
extern void TmFlash_CopyToExtMem(void);
extern unsigned char *__near STYLE_WORK_IMAGE_PTR;
extern unsigned char *__near FLASH_SECTOR_IMAGE_PTR;
extern unsigned char *__near FLASH_SECTION_PTR_7;
int FileIO_LoadRcmToFlash(void)
{
	struct rcmhdr hdr;
	int r;

	Flash_InitExtMemAddrs();
	FileIO_ReadBlock(&hdr, 1024);
	r = FileIO_ReturnError();
	if (r < 0) return r;
	if (hdr.id[0] != 'H' || hdr.id[1] != 0 || hdr.id[2] != 'K') goto bad;
	NoteEvent_LoadSoundGenParams();
	FileIO_ReadBlock(STYLE_WORK_IMAGE_PTR, hdr.size[0]);
	r = FileIO_ReturnError();
	if (r < 0) return r;
	NoteEventBuffer_Store(1);
	NoteEvent_LoadSoundGenParams();
	FileIO_ReadBlock(STYLE_WORK_IMAGE_PTR, hdr.size[1]);
	r = FileIO_ReturnError();
	if (r < 0) return r;
	NoteEventBuffer_Store(2);
	NoteEvent_LoadSoundGenParams();
	FileIO_ReadBlock(STYLE_WORK_IMAGE_PTR, hdr.size[2]);
	r = FileIO_ReturnError();
	if (r < 0) return r;
	NoteEventBuffer_Store(3);
	NoteEvent_LoadSoundGenParams();
	FileIO_ReadBlock(STYLE_WORK_IMAGE_PTR, hdr.size[3]);
	r = FileIO_ReturnError();
	if (r < 0) return r;
	NoteEventBuffer_Store(4);
	NoteEvent_LoadSoundGenParams();
	FileIO_ReadBlock(STYLE_WORK_IMAGE_PTR, hdr.size[4]);
	r = FileIO_ReturnError();
	if (r < 0) return r;
	NoteEventBuffer_Store(5);
	NoteEvent_LoadSoundGenParams();
	FileIO_ReadBlock(STYLE_WORK_IMAGE_PTR, hdr.size[5]);
	r = FileIO_ReturnError();
	if (r < 0) return r;
	NoteEventBuffer_Store(6);
	NoteEvent_LoadSoundGenParams();
	FileIO_ReadBlock(STYLE_WORK_IMAGE_PTR, hdr.size[6]);
	r = FileIO_ReturnError();
	if (r < 0) return r;
	NoteEventBuffer_Store(7);
	*(struct blk64k *)FLASH_SECTOR_IMAGE_PTR = *(struct blk64k *)FLASH_SECTION_PTR_7;
	FileIO_ReadBlock(FLASH_SECTOR_IMAGE_PTR, 0xf400);
	r = FileIO_ReturnError();
	if (r < 0) return r;
	Flash_EraseSectorAndWrite(1, FLASH_SECTOR_IMAGE_PTR, FLASH_SECTION_PTR_7);
	TmFlash_CopyToExtMem();
	return r;
bad:
	return -102;
}
