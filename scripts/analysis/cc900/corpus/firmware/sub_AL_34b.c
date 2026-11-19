/* sub_AL_34b.c, form b.  Change from form a: the byte local nk declared FIRST (before blk; frame and
   register choice depend on declaration order).  Form a's head follows.

   sub_AL_34a.c -- lane_sub helper AL, round 34, form a (KN5000 sub-CPU payload v1.42; core/07_voice_ctrlchange.s).
   Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address).  No __IZ / __XIZ, no inline assembly.
   Base: sub_AL_33a/b/c (run 2026-11-19-54-sub-r33a), whose Voice_Build_Partial_Descriptor compiled identically
   in all three forms (the three zone-field spellings gave the same code, and it matches).

   Voice_Build_Partial_Descriptor (+32 there, the first difference a jump displacement): everything matches except
   the Voice_Allocate_Typed call of the key >= 0x78 branch.  The ROM computes the rebased key FIRST, in C as byte
   arithmetic (`ld c,key; sub c,0x78; add c,(pblk+11)`), and moves it to E; only then loads part straight into
   BC, pushes 0, pushes the key from E, ... ; ours loaded part into DE first, computed the key between the pushes
   and moved part into BC at the end.  The rebased key is a byte local assigned before the call (the ROM keeps it
   in E, as V4.23 keeps register-candidate locals that no call clobbers):
   form a: `unsigned char nk;` declared last, `nk = key - 0x78 + pblk[11];` then the call.

   VoiceParam_Update is dropped (its default slot pointer did not move in rounds 32-33; see the report).

   cc900-options: -Xr
*/

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

/* Voice_Build_Partial_Descriptor (core/07, never compiled; span_refs.py: its inner labels BranchA..C are
   inner-only).  Parameters (req, part, mask) in XWA / C / DE, then five stack words pushed left to right
   (tgt +38, src +36, key +34, vel +32, sel +30; Voice_Build_Four_Partials' calls).  Frame top-down from +4 in
   declaration order: blk, zone, pblk, lblk; the velocity zone z kept in L; the staging record v in XIZ
   (`register`).  Spellings from the built Voice_Allocate_1of4 / _Typed (ah_20a.c): pblk is 1of4's t, the
   staging fields as there, `p[(int)k + 2]`.  Voice_Allocate_Typed's arguments read from the ROM's pushes:
   (req, part, 1, 0, key - 0x78 + pblk[11], vel, 3, word at pblk + 12). */
/* cc900-module: Voice_Allocate_Typed Voice_Pitch_ClampRange */
void Voice_Build_Partial_Descriptor(unsigned char *req, unsigned char part, unsigned int mask, unsigned char tgt,
                                    unsigned char src, unsigned char key, unsigned char vel, unsigned char sel)
{
    unsigned char nk;
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
            if (pblk[0] & 2) {
                nk = key - 0x78 + pblk[11];
                Voice_Allocate_Typed(req, part, 1, 0, nk, vel, 3, *(unsigned int *)(pblk + 12));
            } else {
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
