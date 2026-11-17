/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_8b.c (2026-11-16-82-sub-r8)
   sha256 e4643d333cc84b5363239a62ec397d2578b34ce950ddd7fbbf8f40659745ce7a (name+funcs); compiled at -Xr */
struct slot { unsigned int type; unsigned int a[1]; int param[17]; int idx; int q[1]; int r42[6]; int on; };
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };
extern unsigned int __near ram_45d4[][28];
extern int __near ram_45d6[][28];
extern int __near ram_45fa[][28];
extern int __near ram_4600;
extern struct fxflags __near EFF_SlotActiveFlags;
extern unsigned int __near ram_4942[][25];
extern unsigned int __near ram_4944[][25];
extern unsigned int __near ram_4966[][25];
void DSP_EFFParam_DiffAllAndFlag(unsigned long p)
{
    unsigned int i;
    unsigned int j;

    for (i = 0; i < 5; i++) {
        EFF_SlotActiveFlags.r[i].g[4] = 0;
        for (j = 0; j < 1; j++) {
            if (ram_45d4[i][j] != ((unsigned int *)(p + ((unsigned long)i * 56 + (unsigned long)j * 2)))[5]) {
                ram_4942[i][j] = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                ram_4942[i][j] = 0;
        }
        for (j = 0; j < 17; j++) {
            if (ram_45d6[i][j] != ((int *)(p + ((unsigned long)i * 56 + (unsigned long)j * 2)))[6]) {
                ram_4944[i][j] = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                ram_4944[i][j] = 0;
        }
        for (j = 0; j < 1; j++) {
            if (ram_45fa[i][j] != ((int *)(p + ((unsigned long)i * 56 + (unsigned long)j * 2)))[24]) {
                ram_4966[i][j] = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                ram_4966[i][j] = 0;
        }
        if (*(int *)((unsigned long)&ram_4600 + (i * 56 + 8)) != ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->on) {
            EFF_SlotActiveFlags.r[i].g[3] = 1;
            EFF_SlotActiveFlags.r[i].g[4] = 1;
        } else
            EFF_SlotActiveFlags.r[i].g[3] = 0;
        EFF_SlotActiveFlags.r[i].g[0] = 0;
        EFF_SlotActiveFlags.r[i].g[1] = 0;
        EFF_SlotActiveFlags.r[i].g[2] = 0;
    }
}
