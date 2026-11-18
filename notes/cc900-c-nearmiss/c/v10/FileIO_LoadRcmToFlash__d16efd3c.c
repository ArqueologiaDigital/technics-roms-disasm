/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/flash_floppy_handlers_m159.c (2026-11-18-12-p6-r35)
   sha256 d16efd3c36f0c258209d617c0d9b2543f56a5367c2c3df52807225e1a8659e15 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
	if ((r = FileIO_ReturnError()) < 0) return r;
	if (hdr.id[0] == 'H' && hdr.id[1] == 0 && hdr.id[2] == 'K') {
	NoteEvent_LoadSoundGenParams();
	FileIO_ReadBlock(STYLE_WORK_IMAGE_PTR, hdr.size[0]);
	if ((r = FileIO_ReturnError()) < 0) return r;
	NoteEventBuffer_Store(1);
	NoteEvent_LoadSoundGenParams();
	FileIO_ReadBlock(STYLE_WORK_IMAGE_PTR, hdr.size[1]);
	if ((r = FileIO_ReturnError()) < 0) return r;
	NoteEventBuffer_Store(2);
	NoteEvent_LoadSoundGenParams();
	FileIO_ReadBlock(STYLE_WORK_IMAGE_PTR, hdr.size[2]);
	if ((r = FileIO_ReturnError()) < 0) return r;
	NoteEventBuffer_Store(3);
	NoteEvent_LoadSoundGenParams();
	FileIO_ReadBlock(STYLE_WORK_IMAGE_PTR, hdr.size[3]);
	if ((r = FileIO_ReturnError()) < 0) return r;
	NoteEventBuffer_Store(4);
	NoteEvent_LoadSoundGenParams();
	FileIO_ReadBlock(STYLE_WORK_IMAGE_PTR, hdr.size[4]);
	if ((r = FileIO_ReturnError()) < 0) return r;
	NoteEventBuffer_Store(5);
	NoteEvent_LoadSoundGenParams();
	FileIO_ReadBlock(STYLE_WORK_IMAGE_PTR, hdr.size[5]);
	if ((r = FileIO_ReturnError()) < 0) return r;
	NoteEventBuffer_Store(6);
	NoteEvent_LoadSoundGenParams();
	FileIO_ReadBlock(STYLE_WORK_IMAGE_PTR, hdr.size[6]);
	if ((r = FileIO_ReturnError()) < 0) return r;
	NoteEventBuffer_Store(7);
	*(struct blk64k *)FLASH_SECTOR_IMAGE_PTR = *(struct blk64k *)FLASH_SECTION_PTR_7;
	FileIO_ReadBlock(FLASH_SECTOR_IMAGE_PTR, 0xf400);
	if ((r = FileIO_ReturnError()) < 0) return r;
	Flash_EraseSectorAndWrite(1, FLASH_SECTOR_IMAGE_PTR, FLASH_SECTION_PTR_7);
	TmFlash_CopyToExtMem();
	return r;
	}
	return -102;
}
