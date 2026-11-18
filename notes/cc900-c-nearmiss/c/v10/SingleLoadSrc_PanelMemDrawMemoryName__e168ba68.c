/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/single_load_m269.c (2026-11-18-34-p6-r38-staged)
   sha256 e168ba680adc357cfaaa47aca7e53512cd67e9487e4416d46da85221f71b1972 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: SLSrc_PMemDrawMemName=SingleLoadSrc_PanelMemDrawMemoryName */
#define EVT_PARA_DRAW      0x1c0000fL
extern void FileIO_CopyString(char *, char *);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near SINGLE_LOAD_SRC_ROWS[];
extern unsigned char __near SINGLE_LOAD_ALL;
extern unsigned char __near SLOAD_SRC_PMEM_POS;
extern char *SingleLoadSrc_ReadPmtMemoryName(unsigned int);
void SLSrc_PMemDrawMemName(long obj, unsigned char n)
{
	char *p;

	if (SINGLE_LOAD_ALL != 0)
		return;
	p = SINGLE_LOAD_SRC_ROWS;
	p[63] = 3;
	FileIO_CopyString(p + 64, SingleLoadSrc_ReadPmtMemoryName(SLOAD_SRC_PMEM_POS));
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_SRC_ROWS + 64, 16);
	ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 63));
}
