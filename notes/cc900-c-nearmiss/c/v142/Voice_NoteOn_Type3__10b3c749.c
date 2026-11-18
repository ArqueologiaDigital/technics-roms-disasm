/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AH_20a.c (2026-11-18-18-sub-r21a)
   sha256 10b3c749d6f16af1459c1b1cb990f1b3d6b5060e4fbd7f40a3bce8193e36ef5d (tar-sha256); compiled at -Xr */
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
#define SLOT(part, k) (&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 37 + 0x6e])
extern unsigned char ram_41368[];
extern unsigned char ram_4136a[];
extern unsigned char ram_4136e[];
extern unsigned char __near ram_2942[];
extern void Voice_Pitch_Compute(unsigned char *v);
void Voice_NoteOn_Type3(unsigned char *p, unsigned char part, unsigned int mask, unsigned char k,
                        unsigned char key, unsigned char vel, unsigned char flag)
{
    unsigned char *v;
    unsigned char *zone;
    unsigned char *a2;
    unsigned char *s;
    unsigned char *a1;

    if (*(unsigned int *)&ram_4136a[part * 0x11f] & mask) {
        a1 = *(unsigned char **)(SLOT(part, k) + 4);
        zone = *(unsigned char **)SLOT(part, k);
        a2 = *(unsigned char **)(SLOT(part, k) + 8);
        s = SLOT(part, k);
        v = &ram_2942[(int)k * 71];
        W(v, 1) = 8;
        if (vel & 0x80) W(v, 1) |= 0x800;
        v[3] = k;
        v[4] = part;
        v[5] = key | 0x80;
        v[12] = vel & 0x7f;
        P(v, 35) = ram_41368 + part * 0x11f;
        P(v, 19) = *(unsigned char **)&ram_4136e[part * 0x11f];
        P(v, 23) = zone;
        P(v, 27) = a1;
        P(v, 31) = a2;
        P(v, 39) = s;
        Voice_Pitch_Compute(v);
        W(v, 47) = 0;
        W(v, 49) = 0xff;
        v[53] = 0;
        W(v, 54) = 0;
        W(v, 58) = 0;
        W(v, 56) = 0;
        p[(int)k + 2] = flag | 0x80;
    } else p[(int)k + 2] = 0;
    p[(int)k + 6] = 0;
}
