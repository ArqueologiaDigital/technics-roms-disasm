/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_3m269a.c (2026-11-18-28-p6-r36)
   sha256 c5be958de9f7730989d827202cb18fc5452599a06f7fe615e426a15a7ffca205 (tar-sha256); compiled at -O3 -Xr
   cc900-name: SL_GetComposerSectionName=SingleLoad_GetComposerSectionName */
extern void FileIO_CopyString(char *, char *);
extern void FileIO_CopyString_WriteNull(unsigned char *, unsigned char *, int);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern unsigned char ram_948a0[];
extern char *SingleLoad_StyleSectionNames[];
void SL_GetComposerSectionName(char *out, unsigned int bank, unsigned int sec, int c)
{
	char *p;

	p = out++;
	*p = c;
	if (sec < 4) {
		FileIO_CopyString_WriteNull((unsigned char *)out, ram_948a0 + (unsigned long)(bank * 4 + sec) * 0x60, 13);
		out[13] = 0;
	} else
		FileIO_CopyString(out, SingleLoad_StyleSectionNames[sec]);
	TrimAndPadSmfFilename((unsigned char *)out, 16);
}
