/* lane_sub probe round 7, helper C, form b: CustomTone_CopyToneRecord (which reaches ToneDB_Resolve_NamedToneRecord
   with an absolute call, so it cannot share sub_C_7a.c's module list) and other spellings of sub_C_7a.c's refinements,
   KN5000 sub-CPU payload v1.42 (core/08_voice_noteon_and_tonegen.s, core/10_dsp_voice_params.s).

   cc900-module: BlockCopy_Words_BC_to_HL WaveSel_StageA2_FromToneRec
   cc900-module: Voice_SetVelocity Voice_SetPitch Voice_Allocate Voice_ParamInit Voice_NoteOff */

extern unsigned char ram_41368[];               /* Part_Record_Base */
extern unsigned char ram_44fce[];
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_RootPtr;

extern unsigned char *ToneDB_Resolve_NamedToneRecord();
extern unsigned char *WaveSel_StageA1_FromPatchBlock();
extern unsigned char *WaveSel_StageA1_FindVelSplit();
extern unsigned char *WaveSel_StageA2_FromToneRec();
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n);
extern void RingBuf_SetOffsetLo(unsigned char v);
extern void Voice_SetVelocity(unsigned char a, unsigned char b, unsigned char c, unsigned int d);
extern void Voice_SetPitch(unsigned char a, unsigned char b, unsigned char c, unsigned int d);
extern void Voice_NoteOff(unsigned char a, unsigned char b, unsigned char c, unsigned int d);
extern unsigned char *Voice_Allocate(unsigned char a, unsigned char b);
extern void Voice_ParamInit(unsigned char *v);

void CustomTone_CopyToneRecord(unsigned char a, unsigned char b, unsigned char e)
{
    BlockCopy_Words_BC_to_HL(ToneDB_Resolve_NamedToneRecord(a, b, e, 255), &ram_4531c[(int)e * 80 + 19111],
                             *(unsigned int *)(ToneDB_RootPtr + 238));
}

void VoiceSubSlot_Init(unsigned char a, unsigned char c)
{
    BlockCopy_Words_BC_to_HL(WaveSel_StageA1_FromPatchBlock(a, c), &ram_44fce[(int)c * 11 + 426],
                             *(unsigned int *)(ToneDB_RootPtr + 234));
}

void CustomTone_CopySubUnitRecord(unsigned char a, unsigned char b, unsigned char c, unsigned char d)
{
    BlockCopy_Words_BC_to_HL(WaveSel_StageA1_FindVelSplit(a, b, c, d, 255),
                             (unsigned char *)((unsigned long)(ram_4531c + ((int)d * 80 + (int)a * 11)) + 19169),
                             *(unsigned int *)(ToneDB_RootPtr + 240));
}

void WaveSel_Cache_SetDescPtr(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char *r;
    r = WaveSel_StageA2_FromToneRec(a, c, e);
    *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41368 + a * 0x11f)
                                                         + ((int)c * 37 + (int)e * 4)))[118] = r;
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
