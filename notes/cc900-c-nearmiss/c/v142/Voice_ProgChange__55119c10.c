/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_D_10a.c (2026-11-16-90-sub-r10)
   sha256 55119c10bf70d64332a47b3a6a60f61ec60204f1153235ca93ccacfebfb2acff (name+funcs); compiled at -Xr */
/* lane_sub probe round 10, helper D, form a: KN5000 sub-CPU payload v1.42, core/10_dsp_voice_params.s:
   the voice-slot initialisers and their callers (calr into the same module), and round 9's closest misses.
   Names are the tree's labels and .equ names; ram_<hex> is a RAM cell the tree has not named.  A pointer the ROM
   forms with lda and then reads at +N is written as an integer address, *(T *)((unsigned long)&x[i] + N): V4.23
   folds N into the index for every pointer spelling (round 9). */
/* cc900-module: AlgoType_StateWrite Voice_ActiveFlag_CheckAndLoad DSP_SlotParam_Write_Slot0 DSP_SlotParam_Write_Slot1 DSP_SlotParam_Write_Slot2 */
/* cc900-module: DSP_SlotParam_Write_Slot3 DSP_SlotParam_Write_Slot4 Partial_Build_Present_Word EnvTranspose_UpdateLoop AlgoFlag_Write */
/* cc900-module: AlgoFlag_Write_Bit3 EFF_RoutingInit VoiceNoteParam_UpdateLoop Voice_ActiveFlag_Set Voice_NoteState_Clear WaveSel_Rebuild_PartCaches */
/* cc900-module: VoiceSlot_FullInit VoiceSlot_AltInit VoiceParam_Update WaveSel_Cache_VelSplitPtr WaveSel_Cache_SetDescPtr */
/* cc900-module: WaveSel_StageA1_FindVelSplit DSP_ParamWrite_BlockCopy ToneDB_Resolve_NamedToneRecord WaveSel_StageA2_FindSetDesc */

extern unsigned char ram_4136e[];
extern unsigned char ram_41368[];
extern unsigned char ram_41372[];
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
extern unsigned char ram_41399[];
extern unsigned char DSP_AlgoDescriptor_Records[];
extern unsigned char DSP_AlgoChannel_SelectorByte5[];
extern unsigned char DSP_ChanFreq_CurvePool[];

extern void AlgoType_StateWrite(int, int);
extern void Voice_ActiveFlag_CheckAndLoad(int);
extern void DSP_SlotParam_Write_Slot0(int);
extern void DSP_SlotParam_Write_Slot1(int);
extern void DSP_SlotParam_Write_Slot2(int);
extern void DSP_SlotParam_Write_Slot3(int);
extern void DSP_SlotParam_Write_Slot4(int);
extern void Partial_Build_Present_Word(int);
extern void Voice_InitFromSlot(int);
extern void EnvTranspose_UpdateLoop(int);
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
extern void EFF_RoutingInit(int, int, int);
extern void VoiceNoteParam_UpdateLoop(int);
extern void Voice_ActiveFlag_Set(int);
extern void Voice_NoteState_Clear(int);
extern void Voice_SetLFO_ActiveFlag(int);
extern void Voice_PortamentoTargets_SetAll(int);
extern void VoiceParam_Update(int, int, int);
extern void WaveSel_Cache_VelSplitPtr(int, int);
extern void WaveSel_Cache_SetDescPtr(int, int, int);
extern void Voice_PortamentoTarget_SetSlot(int, int);
/* cc900-name: Voice_PortaTgt_ComputePitch=Voice_PortamentoTarget_ComputePitch */
extern void Voice_PortaTgt_ComputePitch(int, int);
extern void WaveSel_StageA1_FindVelSplit(int, int, int, int, int);
extern void WaveSel_StageA2_FindSetDesc(int, int);
extern unsigned char *ToneDB_Resolve_NamedToneRecord(int, int, int, int);
extern void DSP_ParamWrite_BlockCopy(unsigned int, unsigned char *, unsigned char *);

void VoiceSlot_FullInit(unsigned char part)
{
    unsigned int g;
    unsigned int k;

    AlgoType_StateWrite(part, 0);
    Voice_ActiveFlag_CheckAndLoad(part);
    DSP_SlotParam_Write_Slot0(part);
    DSP_SlotParam_Write_Slot1(part);
    DSP_SlotParam_Write_Slot2(part);
    DSP_SlotParam_Write_Slot3(part);
    DSP_SlotParam_Write_Slot4(part);
    Partial_Build_Present_Word(part);
    EnvTranspose_UpdateLoop(part);
    for (g = 0; g < 3; g++) {
        for (k = 0; k < 4; k++) {
            AlgoFlag_Write_Bit3(part, (unsigned char)g, (unsigned char)k);
            AlgoFlag_Write(part, (unsigned char)g, (unsigned char)k);
        }
        for (k = 0; k < 4; k++)
            EFF_RoutingInit(part, (unsigned char)k, (unsigned char)g);
    }
    VoiceNoteParam_UpdateLoop(part);
}

void VoiceSlot_AltInit(unsigned char part)
{
    unsigned char g;
    unsigned char k;

    AlgoType_StateWrite(part, 0);
    Voice_ActiveFlag_CheckAndLoad(part);
    DSP_SlotParam_Write_Slot0(part);
    DSP_SlotParam_Write_Slot1(part);
    DSP_SlotParam_Write_Slot2(part);
    DSP_SlotParam_Write_Slot3(part);
    DSP_SlotParam_Write_Slot4(part);
    Voice_InitFromSlot(part);
    EnvTranspose_UpdateLoop(part);
    for (g = 0; g < 3; g++) {
        for (k = 0; k < 4; k++) {
            AlgoFlag_Write_Bit3(part, g, k);
            AlgoFlag_Write(part, g, k);
        }
        for (k = 0; k < 4; k++)
            EFF_RoutingInit(part, k, g);
    }
    VoiceNoteParam_UpdateLoop(part);
}

void WaveSel_Rebuild_PartCaches(unsigned char part, unsigned char b, unsigned char c)
{
    unsigned char i;
    unsigned char j;

    VoiceParam_Update(part, b, c);
    switch ((*(unsigned char **)&ram_4136e[part * 0x11f])[16] & 0xc0) {
    case 0x00:
        for (i = 0; i < 4; i++) {
            WaveSel_Cache_VelSplitPtr(part, i);
            for (j = 0; j < 4; j++)
                WaveSel_Cache_SetDescPtr(part, i, j);
        }
        break;
    case 0x40:
        for (i = 0; i < 4; i++) {
            Voice_PortamentoTarget_SetSlot(part, i);
            Voice_PortaTgt_ComputePitch(part, i);
        }
        break;
    case 0x80:
        break;
    case 0xc0:
        break;
    }
}

void Voice_ProgChange(char *m)
{
    unsigned char ch;

    if (m[1] < 0x1a) {
        ch = m[1];
        ram_41381[ch * 0x11f] = m[2];
        ram_41382[ch * 0x11f] = m[3];
        if (m[4] != 0)
            *(unsigned int *)&ram_41372[ch * 0x11f] |= 0x4000;
        else
            *(unsigned int *)&ram_41372[ch * 0x11f] &= ~0x4000;
        Voice_ActiveFlag_Set(ch);
        Voice_NoteState_Clear(ch);
        Voice_SetLFO_ActiveFlag(ch);
        WaveSel_Rebuild_PartCaches(ch, m[2], m[3]);
        switch ((*(unsigned char **)&ram_4136e[ch * 0x11f])[16] & 0xc0) {
        case 0x00: case 0xc0:
            VoiceSlot_FullInit(ch);
            break;
        case 0x40:
            Voice_PortamentoTargets_SetAll(ch);
            VoiceSlot_AltInit(ch);
            break;
        case 0x80:
            break;
        }
    }
}

int DSP_WriteVoiceParam(unsigned int part, unsigned int off, unsigned int n, unsigned char *src)
{
    switch ((*(unsigned char **)(ram_4136e + (unsigned long)part * 0x11f))[16] & 0xc0) {
    case 0x00:
        DSP_ParamWrite_BlockCopy(n, (*(unsigned char **)(ram_4136e + (unsigned long)part * 0x11f)) + off, src);
        return n;
    case 0x40:
        return 0;
    case 0x80:
        DSP_ParamWrite_BlockCopy(n, (*(unsigned char **)(ram_4136e + (unsigned long)part * 0x11f)) + off, src);
        return n;
    case 0xc0:
        return 0;
    }
}

void WaveSel_StageA1_FromPatchBlock(unsigned char part, unsigned char slot)
{
    int x;
    int y;

    x = (*(unsigned char **)&(ram_41368 + (int)part * 0x11f)[(int)slot * 37 + 0x6e])[2];
    y = (*(unsigned char **)&(ram_41368 + (int)part * 0x11f)[(int)slot * 37 + 0x6e])[3];
    WaveSel_StageA1_FindVelSplit(slot, (unsigned char)x, (unsigned char)y, ram_41381[part * 0x11f], part);
}

unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e)
{
    int x;
    int y;

    x = rec[(int)k * 2 + 0x27];
    y = *(unsigned char *)((unsigned long)&rec[(int)k * 2 + 0x27] + 1);
    return ToneDB_Resolve_NamedToneRecord(x, y, k, e);
}

void WaveSel_StageA2_FromVelZone(unsigned char z, unsigned char *p)
{
    int lo;
    int hi;

    lo = p[(int)z * 2 + 3];
    hi = *(unsigned char *)((unsigned long)(p + ((int)z * 2 + 3)) + 1);
    WaveSel_StageA2_FindSetDesc((unsigned char)lo, (unsigned char)hi);
}

void WaveSel_StageA2_FromToneRec(unsigned char part, unsigned char slot, unsigned char z)
{
    int lo;
    int hi;

    lo = (*(unsigned char **)((unsigned long)&(ram_41368 + (int)part * 0x11f)[(int)slot * 37 + 0x6e] + 4))[(int)z * 2 + 3];
    hi = *(unsigned char *)((unsigned long)&(*(unsigned char **)((unsigned long)&(ram_41368 + (int)part * 0x11f)[(int)slot * 37 + 0x6e] + 4))[(int)z * 2 + 3] + 1);
    WaveSel_StageA2_FindSetDesc((unsigned char)lo, (unsigned char)hi);
}

unsigned char Algo_SubTable_DispatchA(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;

    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    r = *(unsigned char *)((unsigned long)&(DSP_AlgoDescriptor_Records + (int)t * 39)[(int)k * 5 + 0x13] + 1);
    switch (t) {
    case 8:
        if (k == 1)
            r = (*(unsigned char **)&ram_4136e[part * 0x11f])[96];
        break;
    }
    return r;
}

unsigned int Algo67_LUTOffset_Check(unsigned char part, unsigned char k)
{
    unsigned int r;
    unsigned char t;

    r = 0;
    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    switch (t) {
    case 6: case 7:
        if ((DSP_AlgoDescriptor_Records + (int)t * 39)[(int)k * 5 + 0x13] & 0x20) {
            if ((*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0x40) {
                if ((DSP_AlgoDescriptor_Records + (int)t * 39)[(int)k * 5 + 0x13] & 2)
                    r = 0xc000;
                else
                    r = 0x4000;
            } else
                r = 0x4000;
        }
        break;
    }
    return r;
}

void DSP_ChanFreq_WritePacket2(unsigned char part)
{
    unsigned char t;
    unsigned char s;
    int r;

    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    switch (t) {
    case 6: case 7:
        s = DSP_AlgoChannel_SelectorByte5[(int)t * 6];
        r = ((int *)(DSP_ChanFreq_CurvePool + (int)s * 0x66))[(*(unsigned char **)&ram_4136e[part * 0x11f])[95]];
        break;
    default:
        r = 0;
        break;
    }
    *(int *)&ram_41399[part * 0x11f] = r;
}
