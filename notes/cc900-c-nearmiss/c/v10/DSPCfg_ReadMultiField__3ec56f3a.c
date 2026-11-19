/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/dsp_config_sysex_m293.c (2026-11-19-15-p6-r42)
   sha256 3ec56f3aa2b4e61ba5aa9458553fb07b11dc7019f84c21c3b5a19e2775795af7 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
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
