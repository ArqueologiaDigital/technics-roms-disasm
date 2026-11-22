/* lane_p6 helper L, round 28r1, form a: module 269 (file_io/wallpaper.s), the single-load name getters
   SingleLoad_GetComposerBankName / SingleLoad_GetSoundMemBankName (families28_L, 2 x 38 B) and their unprobed
   neighbours SingleLoad_GetFileBankName, _GetFileMemoryName, _GetSoundRamName, _GetUserKitName and
   _GetUserKitEntryName: each writes the marker (third argument, the caller's `ld de, N`; GetUserKitName's second)
   through the destination pointer kept in XIZ, then a name (a table string, or 13 / 16 bytes of a loaded file or
   of sound RAM) after it, terminates it and pads it with TrimAndPadSmfFilename.
   Form a: the natural spelling: table strings indexed as arrays, the file / RAM addresses as `base + ...` sums in
   the ROM's order (FileBank: base + 16 * idx + 16; SoundRam: base + 16 + 470 * idx), the products widened to
   unsigned long (the ROM's `mul rr, ...` and `extz; sll` feed a 32-bit add); the source address in a local computed
   before the marker store where the ROM computes it first.
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
	char *src;

	src = (char *)ram_1ed350 + ((unsigned long)idx << 4) + 16;
	*dst++ = mark;
	FileIO_CopyString_WriteNull(dst, src, 16);
	dst[16] = 0;
	TrimAndPadSmfFilename(dst, 16);
}

void SingleLoad_GetFileMemoryName(char *dst, unsigned int idx, unsigned int mark)
{
	char *src;

	src = (char *)ram_1ed350 + (unsigned long)*(unsigned int *)(ram_1ed350 + 13) * idx + 178;
	*dst++ = mark;
	FileIO_CopyString_WriteNull(dst, src, 16);
	dst[16] = 0;
	TrimAndPadSmfFilename(dst, 16);
}

void SingleLoad_GetComposerBankName(char *dst, unsigned int idx, unsigned int mark)
{
	*dst++ = mark;
	FileIO_CopyString(dst, SingleLoad_MemoryBankNames[idx]);
	TrimAndPadSmfFilename(dst, 16);
}

void SingleLoad_GetSoundMemBankName(char *dst, unsigned int idx, unsigned int mark)
{
	*dst++ = mark;
	FileIO_CopyString(dst, SingleLoad_SoundMemBankNames[idx]);
	TrimAndPadSmfFilename(dst, 16);
}

void SingleLoad_GetSoundRamName(char *dst, unsigned int idx, unsigned int mark)
{
	char *src;

	src = (char *)ram_1e0000 + 16 + (unsigned long)idx * 470;
	*dst++ = mark;
	FileIO_CopyString_WriteNull(dst, src, 16);
	dst[16] = 0;
	TrimAndPadSmfFilename(dst, 16);
}

void SingleLoad_GetUserKitName(char *dst, unsigned int mark)
{
	*dst++ = mark;
	FileIO_CopyString_WriteNull(dst, (char *)ram_1e4980, 16);
	dst[16] = 0;
	TrimAndPadSmfFilename(dst, 16);
}

void SingleLoad_GetUserKitEntryName(char *dst, unsigned int idx, unsigned int mark)
{
	char *src;

	src = (char *)ram_1e4aa7 + (unsigned long)idx * 80;
	*dst++ = mark;
	*dst++ = ' ';
	FileIO_CopyString_WriteNull(dst, src, 13);
	dst[13] = 0;
	TrimAndPadSmfFilename(dst, 15);
}
