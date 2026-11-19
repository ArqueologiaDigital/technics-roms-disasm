/* lane_p6 round 4 (2026-11-19), module 293: DSPCfg_ReadMultiField / DSPCfg_WriteMultiField from p6_J_4m293a.c (r37:
   +41 both, O3Xr).  At the loop's DSPCfg_ReadField call the ROM loads &w into XDE before it pushes &a; V4.23 pushed
   first.  The same spot as DrawStringCentered's (r39: matched once the address went through a variable assigned
   just before the call), so here &w goes through a pointer local assigned before each call (form a). */
/* cc900-module: DSPCfg_PackAddress DSPCfg_ReadField DSPCfg_WriteParam */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void DSPCfg_ReadField(unsigned char *, unsigned char *, unsigned int *, unsigned int *);
extern unsigned char *DSPCfg_PackAddress(unsigned char *);
extern void DSPCfg_WriteParam(unsigned char *, unsigned char *, int, unsigned int *, unsigned char *);
extern void DSPCfg_ReadMultiField(unsigned char *p, unsigned char *addr, unsigned int n);
extern void DSPCfg_WriteMultiField(unsigned char *data, unsigned char *addr, unsigned int n, int v, unsigned char *pa,
                                   unsigned char *pu);

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
