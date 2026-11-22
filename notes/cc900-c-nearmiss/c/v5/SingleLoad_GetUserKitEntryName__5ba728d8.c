/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/wallpaper_m269.c (2026-11-22-14-p6-r81)
   sha256 5ba728d81795e11ef34e2ada45ec4d3769978bbfc3d19984365c5635e8fe21aa (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void FileIO_CopyString_WriteNull(char *, char *, int);
extern void TrimAndPadSmfFilename(char *, unsigned int);
extern unsigned char ram_1e4aa7[];
void SingleLoad_GetUserKitEntryName(char *dst, unsigned int idx, unsigned int mark)
{
	char *src;

	src = (char *)ram_1e4aa7;
	src += idx * 80;
	*dst++ = mark;
	*dst++ = ' ';
	FileIO_CopyString_WriteNull(dst, src, 13);
	dst[13] = 0;
	TrimAndPadSmfFilename(dst, 15);
}
