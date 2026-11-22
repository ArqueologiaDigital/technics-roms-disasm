/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_28r1m269a.c (2026-11-22-9-p6-r76)
   sha256 c245e694dbbfcae215700c13291504f634a02ee88c10a4de895d66ec73b6711e (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
