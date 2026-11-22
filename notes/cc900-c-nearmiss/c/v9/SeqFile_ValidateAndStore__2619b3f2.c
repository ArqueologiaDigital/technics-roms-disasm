/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/note_voice_mapping_m302_xr.c (2026-11-22-12-p6-r79)
   sha256 2619b3f28f7b0d0fe9516b16282fcd4ed36a317d1b38e98385518c77ef76251f (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern int StoreAndAdvance_LoadDRAM(void);
int StoreAndAdvance_Prologue(unsigned int n, unsigned char *buf);
extern int StoreAndAdvance_Prologue(unsigned int n, unsigned char *buf);
void SeqFile_ValidateAndStore(unsigned char *s)
{
	int n;

	if ((n = StoreAndAdvance_LoadDRAM()) < 0)
		*s = 0;
	else if (StoreAndAdvance_Prologue(n, s) < 0)
		*s = 0;
	else
		s[n] = 0;
}
