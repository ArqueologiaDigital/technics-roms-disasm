/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_7c.c (2026-11-16-79-sub-r7)
   sha256 650eeae51d68d405c677a408096d7d6e93bb8d1452054784e0988350f0418cdb (name+funcs); compiled at -Xr */
struct slot { unsigned int type; unsigned int a[1]; int param[17]; int idx; int q[1]; int r42[6]; int on; };
struct e50 { unsigned int f0; char pad[48]; };
extern struct slot __near ram_45d2[];
extern struct e50 __near ram_4940[];
void DSP_SlotParam_DiffAndFlag(unsigned long p)
{
    unsigned int i;

    for (i = 0; i < 5; i++) {
        if (ram_45d2[i].type != ((struct slot *)(p + (unsigned long)i * 56 + 8))->type)
            ram_4940[i].f0 = 1;
        else
            ram_4940[i].f0 = 0;
    }
}
