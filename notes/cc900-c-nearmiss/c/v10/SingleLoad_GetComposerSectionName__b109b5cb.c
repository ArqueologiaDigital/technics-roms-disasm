/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_3m269b.c (2026-11-18-28-p6-r36)
   sha256 b109b5cb6b1484b4fee883865bc261366e91620592af0c389a0e7596e5b70e2f (tar-sha256); compiled at -O3 -Xr
   cc900-name: SL_GetComposerSectionName=SingleLoad_GetComposerSectionName */
extern void FileIO_CopyString(char *, char *);
extern void FileIO_CopyString_WriteNull(unsigned char *, unsigned char *, int);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern unsigned char ram_948a0[];
extern char *SingleLoad_StyleSectionNames[];
void SL_GetComposerSectionName(char *out, unsigned int bank, unsigned int sec, int c)
{
	char *p;
	unsigned int k;

	*(p = out++) = c;
	if (sec < 4) {
		k = bank * 4 + sec;
		FileIO_CopyString_WriteNull((unsigned char *)out, &ram_948a0[(unsigned long)k * 0x60], 13);
		out[13] = 0;
	} else
		FileIO_CopyString(out, SingleLoad_StyleSectionNames[sec]);
	TrimAndPadSmfFilename((unsigned char *)out, 16);
}
