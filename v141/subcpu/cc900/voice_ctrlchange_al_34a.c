/* Functions of core/07_voice_ctrlchange.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41350[];
extern unsigned char ram_41352[];
extern unsigned char ram_41356[];
extern unsigned char __near ram_2942[];
extern unsigned int ram_4132b;
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

/* cc900-module: Voice_Allocate_Typed Voice_Pitch_ClampRange */
void Voice_Build_Partial_Descriptor(unsigned char *req, unsigned char part, unsigned int mask, unsigned char tgt,
                                    unsigned char src, unsigned char key, unsigned char vel, unsigned char sel)
{
    unsigned char *blk;
    unsigned char *zone;
    unsigned char *pblk;
    unsigned char *lblk;
    unsigned char z;
    register unsigned char *v;
    unsigned char nk;
    if (*(unsigned int *)&ram_41352[part * 0x11f] & mask) {
        zone = *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41350 + part * 0x11f)
                                                                     + ((int)src * 37 + 0x6e)))[4];
        z = Velocity_Select_Split_Zone(vel, zone);
        blk = *(unsigned char **)((unsigned char *)(unsigned long)(ram_41350 + part * 0x11f) + ((int)src * 37 + 0x6e));
        pblk = *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41350 + part * 0x11f)
                                                                     + ((int)src * 37 + (int)z * 4)))[118];
        lblk = &((unsigned char *)(unsigned long)(ram_41350 + (int)part * 287))[(int)tgt * 37 + 0x6e];
        if (key >= 0x78) {
            if (pblk[0] & 2) {
                nk = key - 0x78 + pblk[11];
                Voice_Allocate_Typed(req, part, 1, 0, nk, vel, 3, *(unsigned int *)(pblk + 12));
            } else {
                req[(int)tgt + 2] = 0;
                req[(int)tgt + 6] = 0;
            }
        } else {
            v = ram_2942 + (int)tgt * 71;
            *(unsigned int *)(v + 1) = ((z) << 6 | 4);
            v[3] = tgt;
            v[4] = part;
            v[5] = key | 0x80;
            if (ram_4132b & 2) {
                if (part == 0)
                    vel = Voice_Pitch_ClampRange(vel + 0x28, 0x7f, 0);
                else if (part == 1)
                    vel = Voice_Pitch_ClampRange(vel + 0x0c, 0x7f, 0);
            }
            v[12] = vel;
            *(unsigned char **)(v + 35) = (unsigned char *)(unsigned long)(ram_41350 + part * 0x11f);
            *(unsigned char **)(v + 19) = *(unsigned char **)(ram_41356 + part * 0x11f);
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
