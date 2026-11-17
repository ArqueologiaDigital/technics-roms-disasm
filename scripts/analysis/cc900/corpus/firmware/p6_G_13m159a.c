/* Phase 6, lane_p6 helper G, round 13, module 159 (notes/cc900-phase6-2026-11-16/modules_v10.tsv), form a:
   FileIO_LoadRcmToFlash (storage/flash_floppy_handlers.s), new.  Loads an "H\0K" RCM file into flash:
   - reads its 1024-byte header to the frame and checks the three signature bytes ('H', 0, 'K'; else -102);
   - for each of the seven blocks: NoteEvent_LoadSoundGenParams, read the block (the header's long sizes from +68)
     into the style work image, then NoteEventBuffer_Store(1..7).  The last block's call is followed by the 64 KB
     word copy of flash section 7 into the sector image (ldirw, 0x8000 words: a struct copy here);
   - reads 0xf400 bytes over the sector image, writes it with Flash_EraseSectorAndWrite(1, image, section 7) and
     calls TmFlash_CopyToExtMem.
   Every read is followed by FileIO_ReturnError, kept in IZ (pushw iz); a negative result is returned at once,
   otherwise the last one is.  Read from the hand assembly: the seven blocks are unrolled (written out here); the
   signature tests go through the header's address (lda once).  Form b writes the error tests as
   `r = ...; if (r < 0) return r;`. */
/* cc900-module: Flash_InitExtMemAddrs NoteEventBuffer_Store NoteEvent_LoadSoundGenParams */

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
	if (hdr.id[0] != 'H' || hdr.id[1] != 0 || hdr.id[2] != 'K') return -102;
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
