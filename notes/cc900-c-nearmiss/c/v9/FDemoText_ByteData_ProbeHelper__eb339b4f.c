/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/fdemotext_routines_m0.c (2026-11-19-29-p6-r46)
   sha256 eb339b4fe01d88950ebfac2eace200138eb3425131c85e4688083365dc81abe5 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char *FDemoText_LookupTableEntry(unsigned int);
extern void SndParam_FetchOscTableEntry(unsigned char *);
unsigned char FDemoText_ByteData_ProbeHelper(unsigned char v)
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
	return rec[1];
}
