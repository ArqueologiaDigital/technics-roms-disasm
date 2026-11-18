/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_1m269a.c (2026-11-18-12-p6-r35)
   sha256 ca398c0e95273c982a2ee0fef30d2dd4f5cd1ebf3978c018fc9c99f259654dcd (tar-sha256); compiled at -O3 -Xr
   cc900-name: SL_GetComposerSectionName=SingleLoad_GetComposerSectionName */
extern void FileIO_CopyString(char *, char *);
extern void FileIO_CopyString_WriteNull(unsigned char *, unsigned char *, int);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
struct nm96 { char s[0x60]; };
extern struct nm96 ram_948a0[];
extern char *SingleLoad_StyleSectionNames[];
void SL_GetComposerSectionName(char *out, unsigned int bank, unsigned int sec, int c)
{
	*out++ = c;
	if (sec < 4) {
		FileIO_CopyString_WriteNull((unsigned char *)out, (unsigned char *)ram_948a0[bank * 4 + sec].s, 13);
		out[13] = 0;
	} else
		FileIO_CopyString(out, SingleLoad_StyleSectionNames[sec]);
	TrimAndPadSmfFilename((unsigned char *)out, 16);
}
