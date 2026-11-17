/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_8b.c (2026-11-16-82-sub-r8)
   sha256 e4643d333cc84b5363239a62ec397d2578b34ce950ddd7fbbf8f40659745ce7a (name+funcs); compiled at -Xr */
struct slot { unsigned int type; unsigned int a[1]; int param[17]; int idx; int q[1]; int r42[6]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
extern unsigned char __near ram_436d;
extern unsigned char __near ram_436e;
extern int DSP_RingBuf_Read(struct ring2k *);
extern void DSP_RingBuf_Skip(struct ring2k *);
extern struct cfg *DSP_GetConfigBuffer(void);
extern struct slot *EFF_GetSlotBuffer(unsigned int);
int DSP_Cmd_LoadEffectPreset(struct ring2k *r)
{
    unsigned int i;
    unsigned int s;
    unsigned int n;
    unsigned char *d;
    unsigned int t;

    t = ram_436d;
    t <<= 7;
    if (ram_436e + t == 0x122) {
        d = (unsigned char *)DSP_GetConfigBuffer();
        n = 8;
        for (i = 0; i < n; i++)
            *d++ = DSP_RingBuf_Read(r);
        n = 0x38;
        for (s = 0; s < 5; s++) {
            d = (unsigned char *)EFF_GetSlotBuffer(s);
            for (i = 0; i < n; i++)
                *d++ = DSP_RingBuf_Read(r);
        }
        DSP_RingBuf_Read(r);
        DSP_RingBuf_Read(r);
        return 0;
    }
    DSP_RingBuf_Skip(r);
    return -1;
}
