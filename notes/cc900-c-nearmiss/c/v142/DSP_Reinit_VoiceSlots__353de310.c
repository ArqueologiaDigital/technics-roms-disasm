/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_33b.c (2026-11-19-54-sub-r33a)
   sha256 353de3109ed4bc25091e721ae8da17be92aed4b91c32684f4eaae95d2cf347ba (name+funcs); compiled at -Xr
   cc900-options: -Xr */
struct s426 { unsigned int w[0xd5]; };
extern unsigned char *ram_4531c;
extern unsigned char ram_7800[];
unsigned char *DSP1_ResolveStreamPtr(unsigned int n);
unsigned int DSP_WriteCount_Compute(void);
void DSP_ResetAlgoDefaults(void);
void DSP_FlushAllSlots(int a, int c);
void DSP_InitChannelSlot(unsigned char *rec, unsigned int n);
extern void InterCPU_E1_DMA_Transfer(unsigned char *src, unsigned int n, unsigned char *dst);
#define EB (*(unsigned long *)&ram_4531c)
#define DST(x) ((unsigned long)((unsigned long)(x) * 0x1d6 + 0x10) + EB)
void DSP_Reinit_VoiceSlots(unsigned char a, unsigned char c)
{
    unsigned char *p;
    unsigned int n;
    unsigned int i;
    if (a < 0x40) {
        if (c != 0xff) {
            i = (unsigned int)a * 0x14 + (unsigned int)c;
            p = DSP1_ResolveStreamPtr(i);
            *(struct s426 *)DST(i) = *(struct s426 *)p;
        } else {
            n = (unsigned int)a * 0x14;
            for (i = n; i < n + 0x14; i++) {
                p = DSP1_ResolveStreamPtr(i);
                *(struct s426 *)DST(i) = *(struct s426 *)p;
            }
        }
        *(unsigned int *)(ram_4531c + 29352) = DSP_WriteCount_Compute();
    } else if (a != 0xff) {
        if (c != 0xff) DSP_InitChannelSlot(ram_4531c + 18816, c);
        else {
            for (i = n; i < 0x80; i++)
                DSP_InitChannelSlot(ram_4531c + 18816, i);
        }
        *(unsigned int *)(ram_4531c + 29352) = DSP_WriteCount_Compute();
    } else {
        DSP_ResetAlgoDefaults();
        for (n = 0; n < 0x28; n++) {
            p = DSP1_ResolveStreamPtr(n);
            *(struct s426 *)DST(n) = *(struct s426 *)p;
        }
        DSP_FlushAllSlots(0, 0x40);
        *(unsigned int *)(ram_4531c + 29352) = DSP_WriteCount_Compute();
    }
    InterCPU_E1_DMA_Transfer(ram_7800, 0x72aa, (unsigned char *)0x1e0000);
}
