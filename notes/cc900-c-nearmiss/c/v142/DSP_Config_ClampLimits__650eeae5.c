/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_7c.c (2026-11-16-79-sub-r7)
   sha256 650eeae51d68d405c677a408096d7d6e93bb8d1452054784e0988350f0418cdb (name+funcs); compiled at -Xr */
struct slot { unsigned int type; unsigned int a[1]; int param[17]; int idx; int q[1]; int r42[6]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
void DSP_Config_ClampLimits(unsigned long p)
{
    unsigned int i;

    if (((struct cfg *)p)->f6 > 1)
        ((struct cfg *)p)->f6 = 0;
    for (i = 0; i < 5; i++)
        if (((struct slot *)(p + (unsigned long)i * 56 + 8))->type > 0x63)
            ((struct slot *)(p + (unsigned long)i * 56 + 8))->type = 0x63;
}
