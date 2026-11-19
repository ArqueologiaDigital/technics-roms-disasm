/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/dsp_config_sysex_m293.c (2026-11-19-15-p6-r42)
   sha256 3ec56f3aa2b4e61ba5aa9458553fb07b11dc7019f84c21c3b5a19e2775795af7 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void DSPCfg_ReadField(unsigned char *, unsigned char *, unsigned int *, unsigned int *);
extern unsigned char *DSPCfg_PackAddress(unsigned char *);
extern void DSPCfg_WriteParam(unsigned char *, unsigned char *, int, unsigned int *, unsigned char *);
void DSPCfg_WriteMultiField(unsigned char *data, unsigned char *addr, unsigned int n, int v, unsigned char *pa,
                            unsigned char *pu)
{
	unsigned int i;
	unsigned int w;
	unsigned int a;
	unsigned char u;
	unsigned int j;
	unsigned int *pw;

	w = 0;
	a = 0;
	for (i = 0; i < n; i++) {
		a += w;
		pw = &w;
		DSPCfg_ReadField(data, addr, pw, &a);
		for (j = 0; j < w; j++)
			data += 1;
		addr = DSPCfg_PackAddress(addr);
	}
	a += w;
	DSPCfg_WriteParam(data, addr, v, &a, &u);
	*pa = a;
	*pu = u;
}
