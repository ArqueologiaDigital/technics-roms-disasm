/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_4m269a.c (2026-11-18-33-p6-r37)
   sha256 d64c4365a3d346024fb9f5f2e2700751068239e4ec21970bcafacff496096774 (tar-sha256); compiled at -O3 -Xr
   cc900-name: SLSrc_CmpDrawPatternName=SingleLoadSrc_ComposerDrawPatternName
   cc900-name: SLSrc_ReadCmpPatternName=SingleLoadSrc_ReadCmpPatternName */
#define EVT_PARA_DRAW      0x1c0000fL
extern void FileIO_CopyString(char *, char *);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near SINGLE_LOAD_SRC_ROWS[];
extern unsigned char __near SINGLE_LOAD_ALL;
extern unsigned char __near SLOAD_SRC_CMP_POS;
extern char *SLSrc_ReadCmpPatternName(unsigned int);
void SLSrc_CmpDrawPatternName(long obj, unsigned char n)
{
	unsigned int b;
	char *p;

	b = SLOAD_SRC_CMP_POS % n;
	if (SINGLE_LOAD_ALL != 0)
		return;
	if (b >= 4)
		return;
	p = SINGLE_LOAD_SRC_ROWS;
	p[63] = 3;
	FileIO_CopyString(p + 64, SLSrc_ReadCmpPatternName((unsigned char)(SLOAD_SRC_CMP_POS / n)));
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_SRC_ROWS + 64, 16);
	ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 63));
}
