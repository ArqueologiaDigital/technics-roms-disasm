/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AR_41a.c (2026-11-19-95-sub-r41r)
   sha256 beff07a2b522ff312dc0bfa5e9fbf36c7b583b10afa066a455ac0ee4d0e20e26 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
struct slot { unsigned int type; unsigned int a[1]; int param[17]; unsigned int idx; int q[1]; int r42[6]; int on; };
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };
extern unsigned char __near ram_45d4[];
extern unsigned char __near ram_45d6[];
extern unsigned char __near ram_45fa[];
extern unsigned char __near ram_4600[];
extern struct fxflags __near EFF_SlotActiveFlags;
extern unsigned char __near ram_4942[];
extern unsigned char __near ram_4944[];
extern unsigned char __near ram_4966[];
void DSP_EFFParam_DiffAllAndFlag(unsigned long p)
{
    unsigned int i;
    unsigned int j;
    for (i = 0; i < 5; i++) {
        EFF_SlotActiveFlags.r[i].g[4] = 0;
        for (j = 0; j < 1; j++) {
            if ((*(unsigned int *)&(ram_45d4)[(unsigned int)((i) * 56 + (j) * 2)]) != ((unsigned int *)(((unsigned long)i * 56 + (unsigned long)j * 2) + p))[5]) {
                (*(unsigned int *)&(ram_4942)[(unsigned int)((i) * 50 + (j) * 2)]) = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                (*(unsigned int *)&(ram_4942)[(unsigned int)((i) * 50 + (j) * 2)]) = 0;
        }
        for (j = 0; j < 17; j++) {
            if ((*(int *)&(ram_45d6)[(unsigned int)((i) * 56 + (j) * 2)]) != ((int *)(((unsigned long)i * 56 + (unsigned long)j * 2) + p))[6]) {
                (*(unsigned int *)&(ram_4944)[(unsigned int)((i) * 50 + (j) * 2)]) = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                (*(unsigned int *)&(ram_4944)[(unsigned int)((i) * 50 + (j) * 2)]) = 0;
        }
        for (j = 0; j < 1; j++) {
            if ((*(int *)&(ram_45fa)[(unsigned int)((i) * 56 + (j) * 2)]) != ((int *)(((unsigned long)i * 56 + (unsigned long)j * 2) + p))[24]) {
                (*(unsigned int *)&(ram_4966)[(unsigned int)((i) * 50 + (j) * 2)]) = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                (*(unsigned int *)&(ram_4966)[(unsigned int)((i) * 50 + (j) * 2)]) = 0;
        }
        if (*(int *)&ram_4600[(int)(i * 56 + 8)] != ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->on) {
            EFF_SlotActiveFlags.r[i].g[3] = 1;
            EFF_SlotActiveFlags.r[i].g[4] = 1;
        } else
            EFF_SlotActiveFlags.r[i].g[3] = 0;
        EFF_SlotActiveFlags.r[i].g[0] = 0;
        EFF_SlotActiveFlags.r[i].g[1] = 0;
        EFF_SlotActiveFlags.r[i].g[2] = 0;
    }
}
