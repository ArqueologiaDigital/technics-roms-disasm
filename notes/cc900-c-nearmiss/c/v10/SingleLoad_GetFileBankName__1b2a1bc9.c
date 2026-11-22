/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_29r1m269e.c (2026-11-22-11-p6-r78)
   sha256 1b2a1bc9575d92313aaeb7cc86d9c4646ef9cf6368c57d59676673bfdc6c0577 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned char ram_1ed350[];
extern void FileIO_CopyString_WriteNull(char *, char *, int);
extern void TrimAndPadSmfFilename(char *, unsigned int);
void SingleLoad_GetFileBankName(char *dst, unsigned int idx, unsigned int mark)
{
	register char *src;

	src = (char *)ram_1ed350 + ((unsigned long)idx << 4) + 16;
	*dst++ = mark;
	FileIO_CopyString_WriteNull(dst, src, 16);
	dst[16] = 0;
	TrimAndPadSmfFilename(dst, 16);
}
