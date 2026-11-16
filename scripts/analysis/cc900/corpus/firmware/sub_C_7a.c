/* lane_sub probe round 7, helper C, form a: round 6's calr callers that were lost with sub_C_6b.c, and refinements of
   sub_C_6a.c's misses, KN5000 sub-CPU payload v1.42 (core/08_voice_noteon_and_tonegen.s, core/10_dsp_voice_params.s).
   No tone-generator writers here (they are in the bisection files sub_C_7d..7h.c).  Callees the ROM reaches with a
   zero-extended byte (`extz wa` before the call) are declared without a prototype, as in round 6.

   cc900-module: VoiceAlloc_CheckAndInit ToneDB_Resolve_NamedToneRecord BlockCopy_Words_BC_to_HL
   cc900-module: DSP_ParamWrite_BlockCopy WaveSel_StageA2_FromToneRec
   cc900-module: Voice_SetVelocity Voice_SetPitch Voice_Allocate Voice_ParamInit Voice_NoteOff */

extern unsigned char ram_41368[];               /* Part_Record_Base */
extern unsigned char ram_4136e[];               /* Part_PatchRecord_Ptr */
extern unsigned char ram_4502b;
extern unsigned char ram_44fce[];
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_RootPtr;

extern void VoiceAlloc_CheckAndInit();
extern unsigned char *ToneDB_Resolve_NamedToneRecord();
extern unsigned char *WaveSel_StageA1_FromPatchBlock();
extern unsigned char *WaveSel_StageA1_FindVelSplit();
extern unsigned char *WaveSel_StageA2_FromToneRec();
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n);
extern void DSP_ParamWrite_BlockCopy(unsigned int n, unsigned char *s, unsigned char *d);
extern void RingBuf_SetOffsetLo(unsigned char v);
extern void Voice_SetVelocity(unsigned char a, unsigned char b, unsigned char c, unsigned char d);
extern void Voice_SetPitch(unsigned char a, unsigned char b, unsigned char c, unsigned char d);
extern void Voice_NoteOff(unsigned char a, unsigned char b, unsigned char c, unsigned char d);
extern unsigned char *Voice_Allocate(unsigned char a, unsigned char b);
extern void Voice_ParamInit(unsigned char *v);

void VoiceAlloc_WithRoutingFlag(unsigned char part, unsigned char flag)
{
    VoiceAlloc_CheckAndInit(part);
    if (flag != 0) ram_4502b |= 0x80;
    else ram_4502b &= ~0x80;
}

unsigned char *ToneDB_Find_SubToneRecord(unsigned char *p, unsigned char c, unsigned char e)
{
    unsigned int x;
    unsigned int y;
    x = p[(int)c * 2 + 39];
    y = (p + ((int)c * 2 + 39))[1];
    return ToneDB_Resolve_NamedToneRecord(x, y, c, e);
}

void VoiceSubSlot_Init(unsigned char a, unsigned char c)
{
    BlockCopy_Words_BC_to_HL(WaveSel_StageA1_FromPatchBlock(a, c),
                             (unsigned char *)((unsigned long)ram_44fce + ((int)c * 11 + 426)),
                             *(unsigned int *)(ToneDB_RootPtr + 234));
}

void CustomTone_CopySubUnitRecord(unsigned char a, unsigned char b, unsigned char c, unsigned char d)
{
    BlockCopy_Words_BC_to_HL(WaveSel_StageA1_FindVelSplit(a, b, c, d, 255),
                             &((unsigned char *)(unsigned long)(ram_4531c + ((int)d * 80 + (int)a * 11)))[19169],
                             *(unsigned int *)(ToneDB_RootPtr + 240));
}

void WaveSel_Cache_SetDescPtr(unsigned char a, unsigned char c, unsigned char e)
{
    *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41368 + a * 0x11f)
                                                         + ((int)c * 37 + (int)e * 4)))[118] =
        WaveSel_StageA2_FromToneRec(a, c, e);
}

int DSP_WriteVoiceParam(unsigned int part, unsigned int off, unsigned int n, unsigned char *buf)
{
    switch ((*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f))[16] & 0xc0) {
    case 0:
        DSP_ParamWrite_BlockCopy(n, (unsigned long)off + *(unsigned char **)((unsigned long)ram_4136e
                                                                              + (unsigned long)part * 0x11f), buf);
        return n;
    case 0x40:
        return 0;
    case 0x80:
        DSP_ParamWrite_BlockCopy(n, (unsigned long)off + *(unsigned char **)((unsigned long)ram_4136e
                                                                              + (unsigned long)part * 0x11f), buf);
        return n;
    case 0xc0:
        return 0;
    }
}

void Voice_NoteOn(unsigned char *m)
{
    unsigned char ch;
    if ((char)m[1] >= 26) return;
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
