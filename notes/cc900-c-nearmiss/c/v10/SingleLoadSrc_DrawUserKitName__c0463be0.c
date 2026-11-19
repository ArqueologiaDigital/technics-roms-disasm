/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_7m269a.c (2026-11-19-56-p6-r51)
   sha256 c0463be020c0ea54b2c7bbbee3840cdb39dda9416a3f7e5e112bdf0940295508 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define EVT_PARA_DRAW 0x1c0000fL
extern char __near SINGLE_LOAD_SRC_ROWS[];
extern unsigned char __near SLOAD_SRC_SOUND_POS;
extern char *SingleLoadSrc_ReadTmUserKitName(void);
extern void FileIO_CopyString(char *, char *);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
void SingleLoadSrc_DrawUserKitName(long obj, unsigned char n)
{
	char *p;

	if (SLOAD_SRC_SOUND_POS < (unsigned char)(n + n))
		return;
	SINGLE_LOAD_SRC_ROWS[21] = 1;
	p = &SINGLE_LOAD_SRC_ROWS[22];
	FileIO_CopyString(p, SingleLoadSrc_ReadTmUserKitName());
	TrimAndPadSmfFilename((unsigned char *)&SINGLE_LOAD_SRC_ROWS[22], 16);
	ApPostEvent(obj, EVT_PARA_DRAW, (long)&SINGLE_LOAD_SRC_ROWS[21]);
}
