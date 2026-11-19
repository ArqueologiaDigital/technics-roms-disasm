/* Functions of audio/dsp_config_sysex.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Fade_SetLevel */   /* staged module names, repair_module_lines.py */

extern unsigned char DspFxParamCountTable[], DspCfg_Data002_ByteTable[];

unsigned int DSPCfg_GetSlotCount(unsigned int i)
{
	return DspFxParamCountTable[i];
}

extern unsigned char __near ram_c1f0;
extern void SoundParam_NotifyChange(long, int, int);
extern void CtrlPanel_SetIndicatorLED(int);
extern void Fade_SetLevel(int);
extern void Fade_Cancel(void);

void Fade_Cancel(void)
{
    ram_c1f0 &= 0xf3;
    ram_c1f0 &= 0xfc;
    SoundParam_NotifyChange(0x40c0, 0, 1);
    CtrlPanel_SetIndicatorLED(0x4d);
    SoundParam_NotifyChange(0x40c1, 0, 1);
    CtrlPanel_SetIndicatorLED(0x4e);
    Fade_SetLevel(0x7f);
}

/* cc900-module: DSPCfg_PackAddress DSPCfg_ReadField DSPCfg_WriteParam */
extern void DSPCfg_ReadField(unsigned char *, unsigned char *, unsigned int *, unsigned int *);
extern unsigned char *DSPCfg_PackAddress(unsigned char *);
extern void DSPCfg_ReadMultiField(unsigned char *p, unsigned char *addr, unsigned int n);
extern void DSPCfg_WriteParam(unsigned char *, unsigned char *, int, unsigned int *, unsigned char *);
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
