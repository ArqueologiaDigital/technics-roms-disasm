/* sub_AL_32b.c, form b.  Changes from form a: the slot pointer as `&((char *)&row)[term]`; the default slot
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
#define DEFAULT_SLOT    ((unsigned char *)(ToneDB_RootPtr[43] + (0, ToneDB_RelBase)))

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
