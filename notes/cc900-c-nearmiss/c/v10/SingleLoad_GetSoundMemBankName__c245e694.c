/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_28r1m269a.c (2026-11-22-9-p6-r76)
   sha256 c245e694dbbfcae215700c13291504f634a02ee88c10a4de895d66ec73b6711e (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern char *SingleLoad_SoundMemBankNames[];
extern void FileIO_CopyString(char *, char *);
extern void TrimAndPadSmfFilename(char *, unsigned int);
void SingleLoad_GetSoundMemBankName(char *dst, unsigned int idx, unsigned int mark)
{
	*dst++ = mark;
	FileIO_CopyString(dst, SingleLoad_SoundMemBankNames[idx]);
	TrimAndPadSmfFilename(dst, 16);
}
