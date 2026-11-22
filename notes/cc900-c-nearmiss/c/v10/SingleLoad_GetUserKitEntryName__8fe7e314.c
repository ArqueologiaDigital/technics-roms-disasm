/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_30r1m269a.c (2026-11-22-13-p6-r80)
   sha256 8fe7e314f113e77a9aa45b3f74b8697e35f91e73dc32c6a3ab2c848d924309dc (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned char ram_1e4aa7[];
extern void FileIO_CopyString_WriteNull(char *, char *, int);
extern void TrimAndPadSmfFilename(char *, unsigned int);
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
