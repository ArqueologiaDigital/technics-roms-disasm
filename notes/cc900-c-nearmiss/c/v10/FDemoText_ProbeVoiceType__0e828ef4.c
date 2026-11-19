/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/fdemotext_routines_m265.c (2026-11-19-29-p6-r46)
   sha256 0e828ef42b46b9bb25e2e32f65919f60497077636e27a368f23a511c324d0273 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char *FDemoText_LookupTableEntry(unsigned int);
extern void SndParam_FetchOscTableEntry(unsigned char *);
unsigned char FDemoText_ProbeVoiceType(unsigned char v)
{
	unsigned char rec[6];
	unsigned char *t;
	unsigned char *p;

	t = FDemoText_LookupTableEntry(v);
	p = rec;
	p[3] = *t++;
	p[4] = *t;
	p[2] = v;
	SndParam_FetchOscTableEntry(p);
	return rec[0];
}
