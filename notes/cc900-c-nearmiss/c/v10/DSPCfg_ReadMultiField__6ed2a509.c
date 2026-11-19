/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_4m293a.c (2026-11-19-13-p6-r41)
   sha256 6ed2a50955f118e2e41451f84ddfc95213d9e91129b0a4d78b04a08e428cc68e (tar-sha256); compiled at -O3 -XS -Xr */
extern void DSPCfg_ReadField(unsigned char *, unsigned char *, unsigned int *, unsigned int *);
extern unsigned char *DSPCfg_PackAddress(unsigned char *);
void DSPCfg_ReadMultiField(unsigned char *p, unsigned char *addr, unsigned int n)
{
	unsigned int i;
	unsigned int w;
	unsigned int a;
	unsigned int j;
	unsigned int *pw;

	w = 0;
	a = 0;
	for (i = 0; i < n; i++) {
		a += w;
		pw = &w;
		DSPCfg_ReadField(p, addr, pw, &a);
		for (j = 0; j < w; j++)
			p++;
		addr = DSPCfg_PackAddress(addr);
	}
	a += w;
	pw = &w;
	DSPCfg_ReadField(p, addr, pw, &a);
}
