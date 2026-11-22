/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_28r1m269b.c (2026-11-22-9-p6-r76)
   sha256 30620ca8a33f4a5600d1105ca5d2865acfdef5dd43fca96c0426fb7fe78c61f7 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char ram_1e4980[];
extern void FileIO_CopyString_WriteNull(char *, char *, int);
extern void TrimAndPadSmfFilename(char *, unsigned int);
void SingleLoad_GetUserKitName(char *dst, unsigned int mark)
{
	char *src;

	src = (char *)ram_1e4980;
	*dst++ = mark;
	FileIO_CopyString_WriteNull(dst, src, 16);
	dst[16] = 0;
	TrimAndPadSmfFilename(dst, 16);
}
