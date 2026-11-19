/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/note_voice_mapping_m303.c (2026-11-19-29-p6-r46)
   sha256 d69abdc82347defa9bf190abfa4fb5a87e2d46aedadb2d57c0ea4120f2127051 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
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
