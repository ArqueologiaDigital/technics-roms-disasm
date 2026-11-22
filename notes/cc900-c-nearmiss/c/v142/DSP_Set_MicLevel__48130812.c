/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_49b.c (2026-11-22-27-sub-r49a)
   sha256 48130812743fee02e12e02b90155f17a255034189c0d9ca04c76695c3e9e3cfa (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct slot { unsigned int type; int f2; int param[25]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
extern struct cfg __near DSP_ConfigBuffer;
extern unsigned int __near ram_45b8;
extern unsigned int __near ram_45ba;
extern unsigned int __near ram_454a;
extern void DSP_State_ApplyBuf(struct cfg *);
void DSP_Set_MicLevel(unsigned char v)
{
    ram_45b8 = v;
    if (ram_45ba == 0)
        return;
    DSP_ConfigBuffer.f0 = 0;
    ram_454a = ram_45b8;
    DSP_State_ApplyBuf(&DSP_ConfigBuffer);
}
