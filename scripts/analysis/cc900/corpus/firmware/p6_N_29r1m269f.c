/* lane_p6 helper N, round 29r1, form f: module 269 (file_io/wallpaper.s), SingleLoad_GetUserKitName /
   SingleLoad_GetUserKitEntryName / SingleLoad_GetFileBankName.  One-spot retries of helper L's p6_L_28r1m269b
   (run r76, Xr, +1 / +7 / +13: the ROM builds the source address in ONE local, in place in its register --
   `lda xhl, (base:24)`, then the scaled index added, then +16 -- where L's base local and source local went
   through XWA and summed the offset first).  Form f: form d with the entry offset an unsigned int product idx * 80 (the ROM's `mul bc, 0x50`).
   cc900-options: -Xr
*/
/* cc900-module: TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char ram_1ed350[];
extern unsigned char ram_1e4980[];
extern unsigned char ram_1e4aa7[];
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
	char *src;

	src = (char *)ram_1e4aa7 + idx * 80;
	*dst++ = mark;
	*dst++ = ' ';
	FileIO_CopyString_WriteNull(dst, src, 13);
	dst[13] = 0;
	TrimAndPadSmfFilename(dst, 15);
}
