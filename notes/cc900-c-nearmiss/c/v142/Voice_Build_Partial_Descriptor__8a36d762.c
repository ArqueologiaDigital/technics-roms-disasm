/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AL_34c.c (2026-11-19-57-sub-r34a)
   sha256 8a36d7624f046aa069bdd508b451e41e3005facce4d62e08d89285b9f5db4d40 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_4136a[];
extern unsigned char ram_4136e[];
extern unsigned char __near ram_2942[];
extern unsigned int ram_41343;
extern unsigned char Voice_SecondaryParam_Curve[];
extern unsigned int Voice_SecondaryParam_WordCurveA[];
extern unsigned int Voice_SecondaryParam_WordCurveB[];
extern unsigned char Velocity_Select_Split_Zone(unsigned char a, unsigned char *t);
extern void Voice_Pitch_Compute(unsigned char *v);
extern unsigned char Algo_SubTable_Bit15Dispatch(unsigned char part, unsigned char k);
extern unsigned char Voice_SecondaryParam_Fetch(unsigned char part);
int Voice_Pitch_ClampRange(int a, int hi, int lo);
void Voice_Allocate_Typed(unsigned char *p, unsigned char part, unsigned int mask, unsigned char k,
                          unsigned char key, unsigned char vel, unsigned char flag, unsigned int tone);
#define ZFIELD(z)       ((z) << 6 | 4)
void Voice_Build_Partial_Descriptor(unsigned char *req, unsigned char part, unsigned int mask, unsigned char tgt,
                                    unsigned char src, unsigned char key, unsigned char vel, unsigned char sel)
{
    unsigned char *blk;
    unsigned char *zone;
    unsigned char *pblk;
    unsigned char *lblk;
    unsigned char z;
    register unsigned char *v;

    if (*(unsigned int *)&ram_4136a[part * 0x11f] & mask) {
        zone = *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f)
                                                                     + ((int)src * 37 + 0x6e)))[4];
        z = Velocity_Select_Split_Zone(vel, zone);
        blk = *(unsigned char **)((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f) + ((int)src * 37 + 0x6e));
        pblk = *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f)
                                                                     + ((int)src * 37 + (int)z * 4)))[118];
        lblk = &((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287))[(int)tgt * 37 + 0x6e];
        if (key >= 0x78) {
            if (pblk[0] & 2)
                Voice_Allocate_Typed(req, part, 1, 0, (unsigned char)(key - 0x78 + pblk[11]), vel, 3,
                                     *(unsigned int *)(pblk + 12));
            else {
                req[(int)tgt + 2] = 0;
                req[(int)tgt + 6] = 0;
            }
        } else {
            v = ram_2942 + (int)tgt * 71;
            *(unsigned int *)(v + 1) = ZFIELD(z);
            v[3] = tgt;
            v[4] = part;
            v[5] = key | 0x80;
            if (ram_41343 & 2) {
                if (part == 0)
                    vel = Voice_Pitch_ClampRange(vel + 0x28, 0x7f, 0);
                else if (part == 1)
                    vel = Voice_Pitch_ClampRange(vel + 0x0c, 0x7f, 0);
            }
            v[12] = vel;
            *(unsigned char **)(v + 35) = (unsigned char *)(unsigned long)(ram_41368 + part * 0x11f);
            *(unsigned char **)(v + 19) = *(unsigned char **)(ram_4136e + part * 0x11f);
            *(unsigned char **)(v + 23) = blk;
            *(unsigned char **)(v + 39) = lblk;
            *(unsigned char **)(v + 27) = zone;
            *(unsigned char **)(v + 31) = pblk;
            Voice_Pitch_Compute(v);
            *(unsigned int *)(v + 47) = Algo_SubTable_Bit15Dispatch(part, tgt);
            *(unsigned int *)(v + 49) = Voice_SecondaryParam_Fetch(part);
            v[53] = Voice_SecondaryParam_Curve[(*(unsigned char **)(v + 19))[94]];
            *(unsigned int *)(v + 54) = Voice_SecondaryParam_WordCurveA[(*(unsigned char **)(v + 19))[95]];
            *(unsigned int *)(v + 58) = Voice_SecondaryParam_WordCurveB[(*(unsigned char **)(v + 19))[96]];
            *(unsigned int *)(v + 56) = Voice_SecondaryParam_WordCurveA[(*(unsigned char **)(v + 19))[97]];
            req[(int)tgt + 2] = sel | 0x80;
            if (*(unsigned int *)(v + 47) != 0 || *(unsigned int *)(v + 49) != 0xff
                || (*(unsigned int *)(lblk + 24) & 0x8000L))
                req[(int)tgt + 6] = 0x80;
            else
                req[(int)tgt + 6] = 0;
        }
    } else {
        req[(int)tgt + 2] = 0;
        req[(int)tgt + 6] = 0;
    }
}
