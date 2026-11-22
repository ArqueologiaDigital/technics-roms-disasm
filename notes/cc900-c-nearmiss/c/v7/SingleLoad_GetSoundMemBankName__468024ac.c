/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/wallpaper_m269.c (2026-11-22-10-p6-r77)
   sha256 468024ac916f6574cda0fa7bba415a9ba56d4a8815cb85eded5ae5ed36b118ea (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void FileIO_CopyString(char *, char *);
extern void TrimAndPadSmfFilename(char *, unsigned int);
extern char *SingleLoad_SoundMemBankNames[];
void SingleLoad_GetSoundMemBankName(char *dst, unsigned int idx, unsigned int mark)
{
	*dst++ = mark;
	FileIO_CopyString(dst, SingleLoad_SoundMemBankNames[idx]);
	TrimAndPadSmfFilename(dst, 16);
}
