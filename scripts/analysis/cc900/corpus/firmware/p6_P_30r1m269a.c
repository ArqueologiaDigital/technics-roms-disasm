/* lane_p6 helper P, round 30r1, form a: module 269 (file_io/wallpaper.s), SingleLoad_GetFileBankName /
   SingleLoad_GetUserKitName / SingleLoad_GetUserKitEntryName.  One-spot retries of helper N's p6_N_29r1m269f
   (run r78, Xr, +3 / +1 / +3).  The ROM builds the source address in its own register, base first
   (`lda xhl, (base:24)`), then adds the scaled index, scaled in the index's own register (`extz xbc; sll xbc, 4` /
   `mul bc, 0x50`), then +16 as `lda xhl, (xhl+16)`; V4.23 scaled first and added the base last.  Form a: the
   address built statement by statement (src = base; src += scaled index; src += 16), the marker an unsigned char
   (the ROM stores E; GetUserKitName moves its BC argument to DE first).
   cc900-options: -Xr
*/
/* cc900-module: TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char ram_1ed350[];
extern unsigned char ram_1e4980[];
extern unsigned char ram_1e4aa7[];
extern void FileIO_CopyString_WriteNull(char *, char *, int);
extern void TrimAndPadSmfFilename(char *, unsigned int);

void SingleLoad_GetFileBankName(char *dst, unsigned int idx, unsigned char mark)
{
	char *src;

	src = (char *)ram_1ed350;
	src += (unsigned long)idx << 4;
	src += 16;
	*dst++ = mark;
	FileIO_CopyString_WriteNull(dst, src, 16);
	dst[16] = 0;
	TrimAndPadSmfFilename(dst, 16);
}

void SingleLoad_GetUserKitName(char *dst, unsigned char mark)
{
	char *src;

	src = (char *)ram_1e4980;
	*dst++ = mark;
	FileIO_CopyString_WriteNull(dst, src, 16);
	dst[16] = 0;
	TrimAndPadSmfFilename(dst, 16);
}

void SingleLoad_GetUserKitEntryName(char *dst, unsigned int idx, unsigned char mark)
{
	char *src;

	src = (char *)ram_1e4aa7;
	src += (unsigned long)idx * 80;
	*dst++ = mark;
	*dst++ = ' ';
	FileIO_CopyString_WriteNull(dst, src, 13);
	dst[13] = 0;
	TrimAndPadSmfFilename(dst, 15);
}
