/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2a.c (2026-11-16-47-sub-r2)
   sha256 a5f7743e23bc8f55cc179cb7f13b9bea660c20e46906cee3cecdd47bc3068a8c (name+funcs); compiled at -Xr */
struct slot { unsigned int type; int f2; int param[25]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
extern struct cfg __near ram_448e;
extern struct slot __near ram_4496[];
extern unsigned int __near ram_454a;
extern unsigned int __near ram_45b8;
extern unsigned int __near ram_45ba;
extern void DSP_State_ApplyBuf(struct cfg *);
extern void DSP_ApplyAlgoForVoiceType(unsigned int);
void DSP_ApplyConfig(unsigned char mode, unsigned char unused, unsigned char flag)
{
    if (flag == 0xff)
        ram_448e.f0 = 1;
    else
        ram_448e.f0 = 0;
    switch (mode) {
    case 0:
        DSP_State_ApplyBuf(&ram_448e);
        DSP_ApplyAlgoForVoiceType(ram_4496[0].type);
        return;
    case 1: case 2: case 4:
        DSP_State_ApplyBuf(&ram_448e);
        return;
    case 3:
        ram_454a = ram_45ba != 0 ? ram_45b8 : 0;
        DSP_State_ApplyBuf(&ram_448e);
        break;
    }
}
