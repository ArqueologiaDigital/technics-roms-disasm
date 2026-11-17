/* Phase 6, lane_p6 helper D, round 22, module 268 (v10 demo/file_demo_proc.s), form b of p6_D_22m268.c (the cached
   type read once into a char local).  Form a's notes:
   DetectFileType -- returns the cached disk-document type (0x25db6: 6 = MUSIC_DIR document, 7 = PIANODIR.FIL)
   or, when the cache says 2, opens one of the two index files, caches its type, reads its title block into the
   buffer at 0x25d74 (and, for type 6, 60 bytes to 0x27200), trims the title and returns the type; -1 when neither
   file opens.  The ROM's second trim call is cross-jumped into the first.  Form b (p6_D_22m268b.c) reads the
   cached type through a local. */
/* cc900-module: TrimAndFormatFilename */   /* from scripts/analysis/cc900/module_calls.py v10 */

extern int FileIO_OpenWithMode(char *, char *);
extern int FileIO_SeekAndReadBlock(unsigned long, unsigned int);
extern void FileIO_ReadBlock(unsigned char *, unsigned long);
extern void FileIO_CloseHandle(void);
extern void TrimAndFormatFilename(unsigned int, unsigned char *, unsigned int);

extern unsigned char ram_25db6;
extern unsigned char ram_25d74[];
extern char DetectType_TryOpen_Str_MUSIC_DIR[], DetectType_TryOpen_Str_rb[];
extern char DetectType_TryExtended_Str_PIANODIR_FIL[], DetectType_TryExtended_Str_rb[];

int DetectFileType(void)
{
	unsigned char t;

	t = ram_25db6;
	if (t == 6 || t == 7) return t;
	if (t != 2) return -1;
	if (FileIO_OpenWithMode(DetectType_TryOpen_Str_MUSIC_DIR, DetectType_TryOpen_Str_rb) >= 0) {
		ram_25db6 = 6;
		FileIO_SeekAndReadBlock(0x10, 0);
		FileIO_ReadBlock(ram_25d74, 0x40);
		FileIO_SeekAndReadBlock(0x60, 0);
		FileIO_ReadBlock((unsigned char *)0x27200L, 0x3c);
		FileIO_CloseHandle();
		TrimAndFormatFilename(0x40, ram_25d74, 0);
		return ram_25db6;
	}
	if (FileIO_OpenWithMode(DetectType_TryExtended_Str_PIANODIR_FIL, DetectType_TryExtended_Str_rb) >= 0) {
		ram_25db6 = 7;
		FileIO_SeekAndReadBlock(0x12d8, 0);
		FileIO_ReadBlock(ram_25d74, 0x38);
		FileIO_CloseHandle();
		TrimAndFormatFilename(0x38, ram_25d74, 0);
		return ram_25db6;
	}
	return -1;
}
