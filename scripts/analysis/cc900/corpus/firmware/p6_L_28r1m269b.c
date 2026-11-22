/* lane_p6 helper L, round 28r1, form b: module 269 (file_io/wallpaper.s), the single-load name getters
   SingleLoad_GetComposerBankName / SingleLoad_GetSoundMemBankName (families28_L, 2 x 38 B) and their neighbours
   SingleLoad_GetFileBankName, _GetFileMemoryName, _GetSoundRamName, _GetUserKitName, _GetUserKitEntryName
   (see p6_L_28r1m269a.c).
   Form b: the RAM base through a pointer local (V4.23 keeps `lda` of an object's address in a register instead of
   folding the offsets, as in the slot-table fills of round 27r1), every source address in a local before the
   marker store (GetUserKitName too: the ROM moves the marker to DE before loading XBC); the table getters in the
   built SingleLoad_GetVariationName's cast form ((unsigned long)i << 2 added to the table's address).
   cc900-options: -O3 -Xr
*/
/* cc900-module: TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

extern char *SingleLoad_MemoryBankNames[];
extern char *SingleLoad_SoundMemBankNames[];
extern unsigned char ram_1ed350[];
extern unsigned char ram_1e0000[];
extern unsigned char ram_1e4980[];
extern unsigned char ram_1e4aa7[];
extern void FileIO_CopyString(char *, char *);
extern void FileIO_CopyString_WriteNull(char *, char *, int);
extern void TrimAndPadSmfFilename(char *, unsigned int);

void SingleLoad_GetFileBankName(char *dst, unsigned int idx, unsigned int mark)
{
	char *b;
	char *src;

	b = (char *)ram_1ed350;
	src = b + ((unsigned long)idx << 4) + 16;
	*dst++ = mark;
	FileIO_CopyString_WriteNull(dst, src, 16);
	dst[16] = 0;
	TrimAndPadSmfFilename(dst, 16);
}

void SingleLoad_GetFileMemoryName(char *dst, unsigned int idx, unsigned int mark)
{
	char *b;
	char *src;

	b = (char *)ram_1ed350;
	src = b + (unsigned long)*(unsigned int *)(b + 13) * idx + 178;
	*dst++ = mark;
	FileIO_CopyString_WriteNull(dst, src, 16);
	dst[16] = 0;
	TrimAndPadSmfFilename(dst, 16);
}

void SingleLoad_GetComposerBankName(char *dst, unsigned int idx, unsigned int mark)
{
	*dst++ = mark;
	FileIO_CopyString(dst, *(char **)((unsigned long)SingleLoad_MemoryBankNames + ((unsigned long)idx << 2)));
	TrimAndPadSmfFilename(dst, 16);
}

void SingleLoad_GetSoundMemBankName(char *dst, unsigned int idx, unsigned int mark)
{
	*dst++ = mark;
	FileIO_CopyString(dst, *(char **)((unsigned long)SingleLoad_SoundMemBankNames + ((unsigned long)idx << 2)));
	TrimAndPadSmfFilename(dst, 16);
}

void SingleLoad_GetSoundRamName(char *dst, unsigned int idx, unsigned int mark)
{
	char *b;
	char *src;

	b = (char *)ram_1e0000;
	src = b + 16 + (unsigned long)idx * 470;
	*dst++ = mark;
	FileIO_CopyString_WriteNull(dst, src, 16);
	dst[16] = 0;
	TrimAndPadSmfFilename(dst, 16);
}

void SingleLoad_GetUserKitName(char *dst, unsigned int mark)
{
	char *src;

	src = (char *)ram_1e4980;
	*dst++ = mark;
	FileIO_CopyString_WriteNull(dst, src, 16);
	dst[16] = 0;
	TrimAndPadSmfFilename(dst, 16);
}

void SingleLoad_GetUserKitEntryName(char *dst, unsigned int idx, unsigned int mark)
{
	char *b;
	char *src;

	b = (char *)ram_1e4aa7;
	src = b + (unsigned long)idx * 80;
	*dst++ = mark;
	*dst++ = ' ';
	FileIO_CopyString_WriteNull(dst, src, 13);
	dst[13] = 0;
	TrimAndPadSmfFilename(dst, 15);
}
