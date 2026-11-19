/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_1m303a.c (2026-11-19-15-p6-r42)
   sha256 69cff9267a116db8e7434204048a8572252c14b182afa3185a0a6c8d2e57aee8 (tar-sha256); compiled at -O3 -XS -Xr */
extern int SndParam_LookupReadOnly(long);
extern void ApplyProgramChangeAs_LoadReg(unsigned char *p);
extern void ApplyProgramChangeAs_LoadReg2(unsigned char *p);
void SndParam_FetchOscTableEntry(unsigned char *p)
{
	if (SndParam_LookupReadOnly(192) == 1)
		ApplyProgramChangeAs_LoadReg2(p);
	else
		ApplyProgramChangeAs_LoadReg(p);
}
