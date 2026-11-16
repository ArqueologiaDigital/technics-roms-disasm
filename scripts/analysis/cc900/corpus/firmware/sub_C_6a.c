/* lane_sub probe round 6, helper C, form a: callers of same-module routines (calr) from pool_C_rel, KN5000 sub-CPU
   payload v1.42 (core/08_voice_noteon_and_tonegen.s, core/10_dsp_voice_params.s).  Names are the tree's labels;
   ram_<hex> is a RAM cell (sub-CPU address) the tree has not named.

   The ROM's callers zero-extend an unsigned char argument to a word (`extz wa`) before most calls, and those callees
   take the byte themselves (NoteState_ClearRecord starts with `extz wa`): the calls had no prototype in scope, so
   the argument was promoted.  Such callees are declared here without a prototype; callees whose arguments go in
   unextended byte or word registers keep one.

   cc900-module: ToneDB_Find_ToneRecord_CoeffPath ToneDB_Find_PatchRecord VoiceParam_FullSetup BlockCopy_Words_BC_to_HL
   cc900-module: WaveSel_StageA2_FromToneRec Voice_SecondaryParam_Fetch2 DSP_ParamWrite_BlockCopy Voice_NoteState_Clear
   cc900-module: Voice_SetVelocity Voice_SetPitch Voice_Allocate Voice_ParamInit Voice_NoteOff */

extern unsigned int ram_41343;                  /* Voice_GlobalFlags */
extern unsigned char ram_41368[];               /* Part_Record_Base */
extern unsigned char ram_4136e[];               /* Part_PatchRecord_Ptr */
extern unsigned char ram_41372[];
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
extern unsigned char ram_413cf[];
extern unsigned char ram_451a4;
extern char ram_451a6;
extern unsigned char ram_44fce[];
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_RootPtr;

extern unsigned char *ToneDB_Find_ToneRecord_CoeffPath(unsigned int a, unsigned int b);
extern unsigned char *ToneDB_Find_PatchRecord(unsigned int a, unsigned int b);
extern void VoiceParam_FullSetup();
extern void WaveSel_Rebuild_PartCaches();
extern unsigned char *WaveSel_StageA1_FromPatchBlock();
extern unsigned char *ToneDB_Resolve_NamedToneRecord();
extern unsigned char *WaveSel_StageA1_FindVelSplit();
extern unsigned char *WaveSel_StageA2_FromToneRec();
extern char Voice_SecondaryParam_Fetch2();
extern void Voice_NoteState_Clear();
extern void NoteState_ClearRecord();
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n);
extern void DSP_ParamWrite_BlockCopy(unsigned int n, unsigned char *s, unsigned char *d);
extern void RingBuf_SetOffsetLo(char v);
extern void Voice_SetVelocity(char a, char b, char c, unsigned char d);
extern void Voice_SetPitch(char a, char b, char c, unsigned char d);
extern void Voice_NoteOff(char a, char b, char c, unsigned char d);
extern unsigned char *Voice_Allocate(char a, char b);
extern void Voice_ParamInit(unsigned char *v);

unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b)
{
    unsigned char *r;
    if (ram_41343 & 1) r = ToneDB_Find_ToneRecord_CoeffPath(a, b);
    else r = ToneDB_Find_PatchRecord(a, b);
    return r;
}

void VoiceAlloc_CheckAndInit(unsigned char part)
{
    if (ram_451a4 == part) {
        if (part <= 2 || (*(unsigned int *)(ram_41368 + part * 0x11f) & 3) == 3) {
            if (*(unsigned int *)(ram_41368 + part * 0x11f) & 1) {
                *(unsigned int *)(ram_41368 + part * 0x11f) |= 1;
            } else {
                *(unsigned int *)(ram_41368 + part * 0x11f) |= 1;
                VoiceParam_FullSetup(part);
                WaveSel_Rebuild_PartCaches(part, ram_41381[part * 0x11f], ram_41382[part * 0x11f]);
            }
        }
    }
}

void VoiceSubSlot_Init(unsigned char a, unsigned char c)
{
    BlockCopy_Words_BC_to_HL(WaveSel_StageA1_FromPatchBlock(a, c), ram_44fce + ((int)c * 11 + 426),
                             *(unsigned int *)(ToneDB_RootPtr + 234));
}

void CustomTone_CopyToneRecord(unsigned char a, unsigned char b, unsigned char e)
{
    BlockCopy_Words_BC_to_HL(ToneDB_Resolve_NamedToneRecord(a, b, e, 255), ram_4531c + ((int)e * 80 + 19111),
                             *(unsigned int *)(ToneDB_RootPtr + 238));
}

void CustomTone_CopySubUnitRecord(unsigned char a, unsigned char b, unsigned char c, unsigned char d)
{
    BlockCopy_Words_BC_to_HL(WaveSel_StageA1_FindVelSplit(a, b, c, d, 255),
                             ram_4531c + ((int)d * 80 + (int)a * 11) + 19169,
                             *(unsigned int *)(ToneDB_RootPtr + 240));
}

void WaveSel_Cache_SetDescPtr(unsigned char a, unsigned char c, unsigned char e)
{
    *(unsigned char **)&((unsigned char *)(unsigned long)(ram_41368 + a * 0x11f + ((int)c * 37 + (int)e * 4)))[118] =
        WaveSel_StageA2_FromToneRec(a, c, e);
}

void Voice_ActiveFlag_CheckAndLoad(unsigned char part)
{
    char v;
    v = 0;
    if ((*(unsigned int *)(ram_41368 + part * 0x11f) & 1) && ram_451a4 == part) v = ram_451a6 << 2;
    if (*(unsigned int *)(ram_41372 + part * 0x11f) & 0x8000L) v += Voice_SecondaryParam_Fetch2(part);
    ram_413cf[part * 0x11f] = v;
}

int DSP_WriteVoiceParam(unsigned int part, unsigned int off, unsigned int n, unsigned char *buf)
{
    switch ((*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f))[16] & 0xc0) {
    case 0:
        DSP_ParamWrite_BlockCopy(n, *(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f)
                                    + (unsigned long)off, buf);
        return n;
    case 0x40:
        return 0;
    case 0x80:
        DSP_ParamWrite_BlockCopy(n, *(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f)
                                    + (unsigned long)off, buf);
        return n;
    case 0xc0:
        return 0;
    }
}

void VoiceSlot_ClearAll(void)
{
    unsigned int i;
    unsigned int j;
    unsigned char p;
    for (p = 0; p < 26; p++) {
        for (i = 0; i < 4; i++) {
            for (j = 0; j < 3; j++) {
                ((unsigned char *)((unsigned long)(ram_41368 + p * 0x11f) + (((unsigned long)j << 4) + ((unsigned long)i << 2))))[39] = 0;
                ((unsigned int *)((unsigned long)(ram_41368 + p * 0x11f) + ((unsigned long)i * 37 + (unsigned long)j * 2)))[68] = 0;
            }
        }
        Voice_NoteState_Clear(p);
    }
    for (i = 0; i < 64; i++) {
        for (j = 0; j < 3; j++) NoteState_ClearRecord((unsigned char)i, (unsigned char)j);
    }
    ram_451a4 = 0xff;
}

void Voice_NoteOn(char *m)
{
    unsigned char ch;
    if (m[1] >= 26) return;
    ch = m[0] & 7;
    if ((m[3] & 0x7f) != 0) {
        RingBuf_SetOffsetLo(m[0] & 8);
        Voice_SetVelocity(m[1], m[2], m[3], ch);
        Voice_SetPitch(m[1], m[2], m[3], ch);
    } else {
        Voice_ParamInit(Voice_Allocate(m[1], m[2]));
        Voice_NoteOff(m[1], m[2], m[3], ch);
    }
}
