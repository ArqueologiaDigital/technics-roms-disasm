/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_4m293a.c (2026-11-18-33-p6-r37)
   sha256 a0700d8af32ec077c12748c23f5b7d0c217d714d71d59552156696807ac568a4 (tar-sha256); compiled at -O3 -Xr */
extern void DSPCfg_ReadField(unsigned char *, unsigned char *, unsigned int *, unsigned int *);
extern unsigned char *DSPCfg_PackAddress(unsigned char *);
void DSPCfg_ReadMultiField(unsigned char *p, unsigned char *addr, unsigned int n)
{
	unsigned int i;
	unsigned int w;
	unsigned int a;
	unsigned int j;

	w = 0;
	a = 0;
	for (i = 0; i < n; i++) {
		a += w;
		DSPCfg_ReadField(p, addr, &w, &a);
		for (j = 0; j < w; j++)
			p++;
		addr = DSPCfg_PackAddress(addr);
	}
	a += w;
	DSPCfg_ReadField(p, addr, &w, &a);
}
