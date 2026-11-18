/* Functions of storage/flash_floppy_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Flash_InitExtMemAddrs NoteEventBuffer_Store NoteEvent_LoadSoundGenParams */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern int FileIO_LoadRcmToFlash(void);

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
