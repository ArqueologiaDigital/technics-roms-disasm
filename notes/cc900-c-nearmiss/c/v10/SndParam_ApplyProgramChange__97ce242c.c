/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_7m303a.c (2026-11-19-56-p6-r51)
   sha256 97ce242c2695356d5234b8df831b1bd75d700adbd6df040db8516224771a97f3 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern int SndParam_LookupReadOnly(long);
extern void FetchOscTableEntry_LoadReg(unsigned char *);
extern void FetchOscTableEntry_LoadReg2(unsigned char *);
void SndParam_ApplyProgramChange(unsigned char *p)
{
	if (SndParam_LookupReadOnly(0xc0L) == 1)
		FetchOscTableEntry_LoadReg2(p);
	else
		FetchOscTableEntry_LoadReg(p);
}
