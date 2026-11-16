/* lane_sub probe round 8, helper C, form b: core/08_voice_noteon_and_tonegen.s functions that address the 11-byte
   rows at 0x44fce + 426 (as a [][11] array, so V4.23 keeps the 426 in the index), and other spellings of two
   sub_C_8a.c functions, KN5000 sub-CPU payload v1.42.

   cc900-module: BlockCopy_Words_BC_to_HL */

extern unsigned char ram_41368[];               /* Part_Record_Base */
extern unsigned char ram_41382[];
extern unsigned char ram_44fce[][11];
extern unsigned int ram_41360;
extern unsigned char ram_4308e[][71];
extern unsigned char *ToneDB_RootPtr;

extern unsigned char *WaveSel_StageA1_FromPatchBlock();
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n);
extern void Voice_Allocate_Nodes(unsigned char *v);
extern void DSP_FlushAllSlots_ForPart();

void VoiceSubSlot_Init(unsigned char a, unsigned char c)
{
    BlockCopy_Words_BC_to_HL(WaveSel_StageA1_FromPatchBlock(a, c), &ram_44fce[c][426],
                             *(unsigned int *)(ToneDB_RootPtr + 234));
}

void Audio_Cmd_DSPGlobal_Param_Store(unsigned char *m)
{
    (&ram_44fce[(m[2] & 0xc0) >> 6][426])[m[2] & 0x3f] = m[4];
    if ((m[2] & 0x7f) <= 10) __ASM("");
}

void Voice_SetPanning(unsigned char *v)
{
    register unsigned char *r;
    *(unsigned int *)v = (ram_41360 >> 8) | 0x1480;
    v[2] = 0x80;
    v[6] = 0;
    v[3] = 0;
    v[4] = 0;
    v[5] = 0;
    Voice_Allocate_Nodes(v);
    if (v[10] >= 0x40) return;
    r = &ram_4308e[v[10]][0];
    *(unsigned int *)(r + 8) = ram_41360;
    *(unsigned int *)(r + 6) = ram_41360;
    *(unsigned int *)(r + 1) = 1;
    *(long *)(r + 19) = 0;
    *(long *)(r + 23) = 0;
    *(long *)(r + 27) = 0;
    *(long *)(r + 31) = 0;
    *(long *)(r + 39) = 0;
    r[12] = 0;
    r[4] = 0x14;
    r[5] = ram_41360 >> 8;
    r[0] = v[10];
    r[3] = 0;
    *(unsigned int *)(r + 47) = 0;
    *(unsigned int *)(r + 49) = 0xff;
    r[53] = 0;
    *(unsigned int *)(r + 54) = 0;
    *(unsigned int *)(r + 58) = 0;
    *(unsigned int *)(r + 56) = 0;
}

void VoiceAlloc_CheckAndInit_FromRecord(unsigned char *m)
{
    unsigned char e;
    unsigned char t;
    e = m[1];
    if (e > 2 && (*(unsigned int *)(ram_41368 + e * 0x11f) & 3) != 3) return;
    if (*(unsigned int *)(ram_41368 + e * 0x11f) & 1) {
        *(unsigned int *)(ram_41368 + e * 0x11f) |= 1;
        return;
    }
    *(unsigned int *)(ram_41368 + e * 0x11f) |= 1;
    t = ram_41382[e * 0x11f];
    if (t < 64) return;
    if (t >= 80) return;
    DSP_FlushAllSlots_ForPart(e);
}
