/* sub_AL_31c.c, form c.  Changes from form a: AlgoType_StateWrite's type read with `(int)part`; VoiceParam_Update's
   default slot pointer as `ToneDB_RootPtr[43] + ToneDB_RelBase` (the ROM loads RelBase into XBC first and sums
   into XWA, the Root word's register).  Form a's head follows.

   sub_AL_31a.c -- lane_sub helper AL, round 31, form a (KN5000 sub-CPU payload v1.42; core/10_dsp_voice_params.s).
   Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address).  No __IZ / __XIZ, no inline assembly.

   Checked with span_refs.py:
   - AlgoType_StateWrite .. DSP_AlgoType_Dispatch1: its 10 inner labels are inner-only: one function.
   - VoiceParam_Update .. WaveSel_StageA1_SelectTables: one function (its inner labels, the EFFSlotScan_* ones
     included, are its own branches; the body ends at EFFSlotScan_Epilogue).
   - Audio_Cmd_DSPUnit_Op01 is NOT a function: an inner case label (the table base) of Audio_Cmd_DSPUnit_Param
     (round 23's span_refs.py run: all 21 inner labels inner-only); skipped.
   WaveSel_StageA1_FindVelSplit: set aside (no clear new idea for its W / L register choice).

   - AlgoType_StateWrite (635 B, never compiled): part spilled, the algorithm type t a byte frame local, c kept
     in C (the record bases are then XDE / XBC, as in the matched Voice_Part_SetStateAndReinit).  Record words
     through `*(unsigned int *)&ram_X[part * 0x11f] op= K` (ad_20a.c), bytes `ram_X[part * 0x11f] = K`.
     The ROM's layout is an if / else on t == 7 whose two arms end in the part+0x02 bit-9 clear (type 7) and the
     zeroed coefficient triple (other types).
   - VoiceParam_Update (723 B, never compiled): part spilled, b / d kept in BC / DE (passed on to the
     ToneDB_Find_* calls as `ld wa,bc; ld bc,de`), the partial counter p in QIZH (`pushw qiz`), the selector
     returned by VoiceBuf_TypeSelector_MatchEpilogue kept in L (a byte local s).  The ROM has the bit-1 branch's
     two arms identical (record lookup + the four-partial binding loop); written twice.  Slot pointer stores:
     row by lda (`&ram_41368[part * 0x11f]`), slot term in DE, the store `(xhl+de)`:
     form a `*(unsigned char **)(&ram_41368[part * 0x11f] + ((int)p * 37 + 0x6e))`.

   cc900-options: -Xr
*/

extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_41368[];
extern unsigned char ram_4136a[];
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char ram_413cb[];
extern unsigned char ram_413cc[];
extern unsigned char ram_413cd[];
extern unsigned char ram_44fce[];
extern unsigned char *ram_4531c;

extern int DSP_AlgoType_Dispatch1(int, int);
extern int DSP_AlgoType_Dispatch2(int, int);
extern int DSP_ChanFreq_WritePacket1(int);
extern int DSP_ChanFreq_WritePacket2(int);
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);
extern unsigned char *ToneDB_Find_PatchRecord(unsigned int a, unsigned int b);
unsigned char VoiceBuf_TypeSelector_MatchEpilogue(unsigned char part, unsigned char c);
void AlgoType_StateWrite(unsigned char part, unsigned char c);
void VoiceParam_Update(unsigned char part, unsigned int b, unsigned int d);

#define PATCH(p)        (*(unsigned char **)(ram_4136e + (p) * 0x11f))
#define WORD(r, p)      (*(unsigned int *)&(r)[(p) * 0x11f])
#define SLOT(p, k)      (*(unsigned char **)(&ram_41368[(p) * 0x11f] + ((int)(k) * 37 + 0x6e)))

/* cc900-module: DSP_AlgoType_Dispatch1 DSP_AlgoType_Dispatch2 DSP_ChanFreq_WritePacket1 DSP_ChanFreq_WritePacket2 */
/* cc900-module: ToneDB_Find_ToneRecord ToneDB_Find_PatchRecord VoiceBuf_TypeSelector_MatchEpilogue */

void AlgoType_StateWrite(unsigned char part, unsigned char c)
{
    unsigned char t;

    t = (*(unsigned char **)(ram_4136e + (int)part * 0x11f))[93] & 0xf;
    if (t == 7) {
        WORD(ram_41372, part) |= 0x8000;
        if (c == 0) {
            if (WORD(ram_41372, part) & 0x4000) {
                ram_413cb[part * 0x11f] = 0x0f;
                ram_413cc[part * 0x11f] = 0x4f;
                ram_413cd[part * 0x11f] = 0x96;
            } else {
                ram_413cb[part * 0x11f] = 1;
                ram_413cc[part * 0x11f] = 1;
                ram_413cd[part * 0x11f] = 1;
            }
            DSP_AlgoType_Dispatch1(part, 0);
            DSP_AlgoType_Dispatch2(part, 0);
            DSP_AlgoType_Dispatch1(part, 1);
            DSP_AlgoType_Dispatch2(part, 1);
            DSP_ChanFreq_WritePacket1(part);
            DSP_ChanFreq_WritePacket2(part);
        } else {
            if (WORD(ram_41372, part) & 0x4000) {
                ram_413cb[part * 0x11f] &= 0x05;
                ram_413cb[part * 0x11f] |= 0x02;
            } else {
                ram_413cb[part * 0x11f] &= 0x05;
            }
        }
        WORD(ram_4136a, part) &= 0xfdff;
    } else {
        if (WORD(ram_41372, part) & 0x4000) {
            WORD(ram_41372, part) |= 0x8000;
            DSP_AlgoType_Dispatch1(part, 0);
            DSP_AlgoType_Dispatch2(part, 0);
            DSP_AlgoType_Dispatch1(part, 1);
            DSP_AlgoType_Dispatch2(part, 1);
            DSP_ChanFreq_WritePacket1(part);
            DSP_ChanFreq_WritePacket2(part);
            if (t == 0x0a)
                WORD(ram_4136a, part) |= 0x0200;
            else
                WORD(ram_4136a, part) &= 0xfdff;
        } else {
            WORD(ram_41372, part) &= 0x7fff;
            WORD(ram_4136a, part) &= 0xfdff;
        }
        ram_413cb[part * 0x11f] = 0;
        ram_413cc[part * 0x11f] = 0;
        ram_413cd[part * 0x11f] = 0;
    }
}

void VoiceParam_Update(unsigned char part, unsigned int b, unsigned int d)
{
    unsigned char p;
    unsigned char s;

    if (WORD(ram_41368, part) & 1) {
        if (d == 0x40 || d == 0x41 || d == 0x50) {
            PATCH(part) = ram_4531c + 18816;
        } else {
            PATCH(part) = ram_44fce;
            for (p = 0; p < 4; p++)
                SLOT(part, p) = PATCH(part) + ((int)p * 0x51 + 0x66);
        }
    } else if (WORD(ram_41368, part) & 2) {
        if (part <= 0x0f)
            PATCH(part) = ToneDB_Find_ToneRecord(b, d);
        else
            PATCH(part) = ToneDB_Find_PatchRecord(b, d);
        for (p = 0; p < 4; p++) {
            if ((s = VoiceBuf_TypeSelector_MatchEpilogue(part, p)) == 0xff)
                SLOT(part, p) = (unsigned char *)(ToneDB_RootPtr[43] + ToneDB_RelBase);
            else
                SLOT(part, p) = PATCH(part) + ((int)s * 0x51 + 0x66);
        }
    } else {
        if (part <= 0x0f)
            PATCH(part) = ToneDB_Find_ToneRecord(b, d);
        else
            PATCH(part) = ToneDB_Find_PatchRecord(b, d);
        for (p = 0; p < 4; p++) {
            if ((s = VoiceBuf_TypeSelector_MatchEpilogue(part, p)) == 0xff)
                SLOT(part, p) = (unsigned char *)(ToneDB_RootPtr[43] + ToneDB_RelBase);
            else
                SLOT(part, p) = PATCH(part) + ((int)s * 0x51 + 0x66);
        }
    }
}
