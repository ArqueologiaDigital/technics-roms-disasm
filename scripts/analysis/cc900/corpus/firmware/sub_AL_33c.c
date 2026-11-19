/* sub_AL_33c.c, form c (base: sub_AL_32b; see sub_AL_33a.c's head).  Change: the default slot pointer as
   `&((unsigned char *)ToneDB_RelBase)[ToneDB_RootPtr[43]]`.

   sub_AL_32b.c, form b.  Changes from form a: the slot pointer as `&((char *)&row)[term]`; the default slot
   pointer `Root[43] + (0, ToneDB_RelBase)`.  Form a's head follows.

   sub_AL_32a.c -- lane_sub helper AL, round 32, form a (KN5000 sub-CPU payload v1.42; core/10_dsp_voice_params.s).
   Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address).  No __IZ / __XIZ, no inline assembly.
   Base: sub_AL_31c (run 2026-11-19-50-sub-r31a; AlgoType_StateWrite matched there and is not repeated).

   VoiceParam_Update, what round 31 showed (idiff_full.py; 31a / 31b / 31c compiled identically):
   - `PATCH(part) = ram_44fce;`: V4.23 put the value in XDE and stored `(xbc+wa)`; the ROM moves the index to BC,
     builds the value in XWA, stores `(xde+bc)` -- as for the ActivePath's `ram_4531c + 18816`, which matches.
     Here: `&ram_44fce[0]` (round 21's lesson: an argument built in XWA and copied is an address expression).
   - slot pointer stores: V4.23 folded row and slot term into one index (`add de,bc`, base lda); the ROM keeps the
     row a pointer (`lda xbc,base; lda xhl,(xbc+wa)`) and stores `(xhl+de)`.  Form a: the row through a
     conversion, `(char *)&ram_41368[part * 0x11f] + term`.
   - the selector test: ours `ld a,l; cp a,0xff` (an assignment inside the condition), the ROM `cp l,0xff`:
     `s = f(...); if (s == 0xff)` as two statements.
   - the default slot pointer: the ROM loads ToneDB_RelBase into XBC first, then the Root word into XWA, and
     adds into XWA; ours added RelBase from memory (both operand orders): form a `(0, ToneDB_RelBase) + Root[43]`
     (the comma idiom that loads an operand into a register first).

   cc900-options: -Xr
*/

extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_44fce[];
extern unsigned char *ram_4531c;

extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);
extern unsigned char *ToneDB_Find_PatchRecord(unsigned int a, unsigned int b);
unsigned char VoiceBuf_TypeSelector_MatchEpilogue(unsigned char part, unsigned char c);
void VoiceParam_Update(unsigned char part, unsigned int b, unsigned int d);

#define PATCH(p)        (*(unsigned char **)(ram_4136e + (p) * 0x11f))
#define WORD(r, p)      (*(unsigned int *)&(r)[(p) * 0x11f])
#define SLOT(p, k)      (*(unsigned char **)&((char *)&ram_41368[(p) * 0x11f])[(int)(k) * 37 + 0x6e])
#define DEFAULT_SLOT    (&((unsigned char *)ToneDB_RelBase)[ToneDB_RootPtr[43]])

/* Voice_Build_Partial_Descriptor's declarations (the built ah_20a.c / ai_21c.c spellings) */
extern unsigned char ram_4136a[];
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
/* form c: the zone byte shifted and or-ed in place (z is dead afterwards) */
#define ZFIELD(z)       ((z) <<= 6, (z) |= 4, (z))

/* cc900-module: ToneDB_Find_ToneRecord ToneDB_Find_PatchRecord VoiceBuf_TypeSelector_MatchEpilogue */

void VoiceParam_Update(unsigned char part, unsigned int b, unsigned int d)
{
    unsigned char p;
    unsigned char s;

    if (WORD(ram_41368, part) & 1) {
        if (d == 0x40 || d == 0x41 || d == 0x50) {
            PATCH(part) = ram_4531c + 18816;
        } else {
            PATCH(part) = &ram_44fce[0];
            for (p = 0; p < 4; p++)
                SLOT(part, p) = PATCH(part) + ((int)p * 0x51 + 0x66);
        }
    } else if (WORD(ram_41368, part) & 2) {
        if (part <= 0x0f)
            PATCH(part) = ToneDB_Find_ToneRecord(b, d);
        else
            PATCH(part) = ToneDB_Find_PatchRecord(b, d);
        for (p = 0; p < 4; p++) {
            s = VoiceBuf_TypeSelector_MatchEpilogue(part, p);
            if (s == 0xff)
                SLOT(part, p) = DEFAULT_SLOT;
            else
                SLOT(part, p) = PATCH(part) + ((int)s * 0x51 + 0x66);
        }
    } else {
        if (part <= 0x0f)
            PATCH(part) = ToneDB_Find_ToneRecord(b, d);
        else
            PATCH(part) = ToneDB_Find_PatchRecord(b, d);
        for (p = 0; p < 4; p++) {
            s = VoiceBuf_TypeSelector_MatchEpilogue(part, p);
            if (s == 0xff)
                SLOT(part, p) = DEFAULT_SLOT;
            else
                SLOT(part, p) = PATCH(part) + ((int)s * 0x51 + 0x66);
        }
    }
}

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
                Voice_Allocate_Typed(req, part, 1, 0, key - 0x78 + pblk[11], vel, 3, *(unsigned int *)(pblk + 12));
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
