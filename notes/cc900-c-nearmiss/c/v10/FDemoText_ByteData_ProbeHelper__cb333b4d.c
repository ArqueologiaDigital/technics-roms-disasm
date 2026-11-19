/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_2m265a.c (2026-11-19-15-p6-r42)
   sha256 cb333b4da18c69fc52e6b9d447d2a0500ad4dca02560a7a1c169a5e53fb7c1e1 (tar-sha256); compiled at -Xr */
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
