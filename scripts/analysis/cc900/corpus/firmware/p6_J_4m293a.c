/* Phase 6, lane_p6 helper J, round 4, module 293 (audio/dsp_config_sysex.s), form a: DSPCfg_ReadMultiField and
   DSPCfg_WriteMultiField, a twin pair.  n fields are read (DSPCfg_ReadField) at successive packed addresses, the
   bit offset a accumulating each field width w; the data pointer advances by w bytes per field; the last field
   is read (Read) or written with DSPCfg_WriteParam (Write, which also returns a byte u), and Write stores a and u
   through its last two stack parameters.  Frame: i lowest, then the address-taken locals in reverse declaration
   order (w highest). */
/* cc900-module: DSPCfg_PackAddress DSPCfg_ReadField DSPCfg_WriteParam */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void DSPCfg_ReadField(unsigned char *, unsigned char *, unsigned int *, unsigned int *);
extern unsigned char *DSPCfg_PackAddress(unsigned char *);
extern void DSPCfg_WriteParam(unsigned char *, unsigned char *, int, unsigned int *, unsigned char *);

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

void DSPCfg_WriteMultiField(unsigned char *data, unsigned char *addr, unsigned int n, int v, unsigned char *pa,
                            unsigned char *pu)
{
	unsigned int i;
	unsigned int w;
	unsigned int a;
	unsigned char u;
	unsigned int j;

	w = 0;
	a = 0;
	for (i = 0; i < n; i++) {
		a += w;
		DSPCfg_ReadField(data, addr, &w, &a);
		for (j = 0; j < w; j++)
			data += 1;
		addr = DSPCfg_PackAddress(addr);
	}
	a += w;
	DSPCfg_WriteParam(data, addr, v, &a, &u);
	*pa = a;
	*pu = u;
}
