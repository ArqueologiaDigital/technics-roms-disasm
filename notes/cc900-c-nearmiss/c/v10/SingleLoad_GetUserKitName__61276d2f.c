/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_29r1m269f.c (2026-11-22-11-p6-r78)
   sha256 61276d2fe0ab4827af52600884062e4999df80cd50c85d26cbc238f38c0e4535 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
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
