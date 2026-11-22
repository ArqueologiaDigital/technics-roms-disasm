/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_30r1m269b.c (2026-11-22-13-p6-r80)
   sha256 55f193451c4b93c484575e35ae0569d77bffb8deef5e947ee94e79febb6ac841 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned char ram_1e4980[];
extern void FileIO_CopyString_WriteNull(char *, char *, int);
extern void TrimAndPadSmfFilename(char *, unsigned int);
void SingleLoad_GetUserKitName(char *dst, unsigned int mark)
{
	*dst++ = mark;
	FileIO_CopyString_WriteNull(dst, (char *)ram_1e4980, 16);
	dst[16] = 0;
	TrimAndPadSmfFilename(dst, 16);
}
