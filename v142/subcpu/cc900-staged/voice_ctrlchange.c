/* Functions of core/07_voice_ctrlchange.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

void Level_Build_Reg0C0(unsigned char *v);

int Voice_Pitch_ClampRange(int a, int hi, int lo)
{
    if (a < lo) a = lo;
    else if (a > hi) a = hi;
    return a;
}

#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern unsigned char ram_4136e[];
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
struct pkt { unsigned char op; unsigned char key[2]; unsigned char mask[2]; };
extern struct pkt __near ram_2a5e;
void NoteOn_RoutePacket(struct pkt *q);
void Voice_NoteState_Clear(int n);
void Voice_SetLFO_ActiveFlag(int n);
void WaveSel_Rebuild_PartCaches(int n, int a, int b);
void VoiceSlot_FullInit(int n);
void VoiceSlot_AltInit(int n);
void Voice_PortamentoTargets_SetAll(int n);
#define PKW(q, o) (*(unsigned int *)((unsigned char *)(q) + (o)))

struct pkt *Voice_Allocate(unsigned char part, unsigned char key)
{
    struct pkt *q = &ram_2a5e;
    q->op = 0x80;
    PKW(q, 1) = ((unsigned int)part << 8 | key) | 0x80;
    PKW(q, 3) = 0;
    NoteOn_RoutePacket(q);
    return q;
}

struct pkt *Voice_AllocateForRelease(unsigned char part)
{
    struct pkt *q = &ram_2a5e;
    q->op = 0x80;
    PKW(q, 1) = (unsigned int)part << 8 | 0x80;
    PKW(q, 3) = 0x7f;
    NoteOn_RoutePacket(q);
    return q;
}

struct pkt *Voice_AllocateForSustain(unsigned char part)
{
    struct pkt *q = &ram_2a5e;
    q->op = 0x40;
    PKW(q, 1) = (unsigned int)part << 8;
    PKW(q, 3) = 0x7f;
    NoteOn_RoutePacket(q);
    return q;
}

void Voice_PerVoice_PortamentoPitchUpdate(unsigned char n)
{
    Voice_NoteState_Clear(n);
    Voice_SetLFO_ActiveFlag(n);
    WaveSel_Rebuild_PartCaches(n, ram_41381[n * 287], ram_41382[n * 287]);
    switch ((*(unsigned char **)&ram_4136e[n * 287])[16] & 0xc0) {
    case 0:
    case 0xc0:
        VoiceSlot_FullInit(n);
        break;
    case 0x40:
        Voice_PortamentoTargets_SetAll(n);
        VoiceSlot_AltInit(n);
        break;
    case 0x80:
        break;
    }
}

struct pkt *Voice_Query_AllChannels(void)
{
    struct pkt *q = &ram_2a5e;
    q->op = 0;
    PKW(q, 1) = 0;
    PKW(q, 3) = 0x1fff;
    NoteOn_RoutePacket(q);
    return q;
}

struct pkt *Voice_Query_PartVoices(unsigned char part)
{
    struct pkt *q = &ram_2a5e;
    q->op = 0;
    PKW(q, 1) = (unsigned int)part << 8;
    PKW(q, 3) = 0xff;
    NoteOn_RoutePacket(q);
    return q;
}

struct pkt *Voice_Query_PartVoices_Mask7F(unsigned char part)
{
    struct pkt *q = &ram_2a5e;
    q->op = 0;
    PKW(q, 1) = (unsigned int)part << 8 | 0x80;
    PKW(q, 3) = 0x7f;
    NoteOn_RoutePacket(q);
    return q;
}

void Voice_Slot_LoadPitchOffset_A(unsigned char *v) { SW(v, 13) += SW(P(v, 35), 270); }

void Voice_Slot_LoadPitchOffset_B(unsigned char *v) { SW(v, 13) += SW(P(v, 35), 272); }

unsigned int Voice_KeyIndex_Pack3Nibbles(unsigned int a)
{
    unsigned int r;
    r = ((a >> 8) & 0xf) * 81;
    r += ((a >> 4) & 0xf) * 9;
    r += a & 0xf;
    return r;
}

#define W(p, o) (*(unsigned int *)((p) + (o)))
extern unsigned char ram_451cc[];
extern unsigned char Voice_Selector_FieldSlot_Table[][3];
extern unsigned char ram_4308e[];
void Voice_Calc_LevelPair_Silence(unsigned char *v);
void ToneGen_WriteLevelBurst(int n, unsigned char *blk);
void ToneGen_WriteVoiceParams(int n, unsigned char *blk);
void Voice_ComputeVolume_CappedLFO(unsigned char *v);
void Voice_Calc_LevelPair_EGA(unsigned char *v);
void Voice_Calc_LevelPair_EGB(unsigned char *v);
void Voice_Calc_LevelPair_EGC(unsigned char *v);
void WaveSel_StageB_Build_Reg040(unsigned char *v);
void Pitch_Emit_Reg400(unsigned char *v);
void Pitch_Apply_Partial_Detune(unsigned char *v);
void Voice_Level_ComputeTriplet(unsigned char *v);
void TVF_Build_Dispatch(unsigned char *v);
void TVF_Emit_Registers(unsigned char *v);
void Voice_StereoLevel_Compute(unsigned char *v);
void Voice_PortaLevel_Compute(unsigned char *v);
void ExtVoice_Build_SlotRegisters(unsigned char *v);
void Voice_SubVoice_ComputeAndTrigger(unsigned char *v);
void Voice2_UpdatePitch(unsigned char *v);
void Voice_Build_GateCommand(unsigned char *v);
void Voice_Calc_LevelPair_PatchAtk(unsigned char *v);
void Voice_WriteChPanShift(unsigned char *v, int s);
void Voice_ComputePitch(unsigned char *v);
void Voice_ApplyPortamento(unsigned char *v);

void Voice_Build_Register_Set(unsigned char n)
{
    unsigned char *v;
    v = &ram_4308e[(int)n * 71];
    WaveSel_StageB_Build_Reg040(v);
    Pitch_Apply_Partial_Detune(v);
    Pitch_Emit_Reg400(v);
    Voice_Level_ComputeTriplet(v);
    TVF_Build_Dispatch(v);
    TVF_Emit_Registers(v);
    Voice_StereoLevel_Compute(v);
    Voice_PortaLevel_Compute(v);
    ExtVoice_Build_SlotRegisters(v);
    Voice_SubVoice_ComputeAndTrigger(v);
    Voice2_UpdatePitch(v);
    Level_Build_Reg0C0(v);
    Voice_Build_GateCommand(v);
    Voice_Calc_LevelPair_PatchAtk(v);
    Voice_WriteChPanShift(v, 0);
    Voice_ComputePitch(v);
    Voice_ApplyPortamento(v);
    ToneGen_WriteVoiceParams(n, ram_451cc);
}

void Voice_Cut(unsigned char n)
{
    unsigned char *v;
    unsigned char *s;
    unsigned int w;
    v = &ram_4308e[(int)n * 71];
    s = P(v, 35);
    v[5] &= 0x7f;
    w = W(s, 10);
    if (v[3] == 3) W(s, 10) &= ~1;
    if ((W(v, 1) & 0x8000L) || !(W(P(v, 35), 10) & 1)) {
        if (v[3] < 3) Voice_ComputeVolume_CappedLFO(v);
        else Voice_Calc_LevelPair_EGA(v);
        Voice_Calc_LevelPair_EGB(v);
        Voice_Calc_LevelPair_EGC(v);
        ToneGen_WriteLevelBurst(n, ram_451cc);
    }
    W(s, 10) = w;
}

void Voice_ReleaseSingle(unsigned char n)
{
    unsigned char *v;
    v = ram_4308e + (int)n * 71;
    v[5] &= 0x7f;
    if (v[70] != 0) {
        Voice_Calc_LevelPair_Silence(v);
        ToneGen_WriteLevelBurst(n, ram_451cc);
    }
}

void Voice_Selector_Unpack3Groups(unsigned char *p, unsigned int v, unsigned char e)
{
    p[Voice_Selector_FieldSlot_Table[e][0]] = v % 16;
    v >>= 4;
    p[Voice_Selector_FieldSlot_Table[e][1]] = v % 16;
    v >>= 4;
    p[Voice_Selector_FieldSlot_Table[e][2]] = v % 16;
}

void Voice_SignedClamp(unsigned char *p, char d, int hi, int lo)
{
    int v;
    v = (int)*p + d;
    if (v > hi) v = hi;
    if (v < lo) v = lo;
    *p = v;
}

extern int ram_451ce;
extern unsigned char ram_41368[];
extern unsigned char ram_41472[];
extern unsigned char ram_41473[];
extern unsigned char ram_41474[];
extern unsigned char ram_41475[];
extern unsigned char ram_43094[];
void ToneGen_WriteSegRegs_SameLevel(int n, unsigned char *blk);
void ToneGen_WriteEnvSegments(int n, unsigned char *blk);
void ToneGen_WriteSingleReg(int n, int v);
void Voice_Clear_HoldBit(int n);
void Voice_Stage_EnvSegments(unsigned char *v);
void WaveSel_AddRandomEntryOffset(int *p);
void Pitch_Apply_Zone_Trim(unsigned char *v);
void Voice_Pitch_WriteOutReg_Sec(unsigned char *v);
void TVF_BuildEmit_Short_Dispatch(unsigned char *v);
void TVF_Emit_Registers_Type2(unsigned char *v);
void Voice_Build_GateCmd_NoPartial(unsigned char *v);
void Voice_Calc_LevelPair_FixedAtk(unsigned char *v);
void Voice_WriteChPanShift2(unsigned char *v, int s);
void Voice_Level_ClearAllOutputRegs(unsigned char *v);
void Voice_ComputePitch_Mono(unsigned char *v);
void Voice_ApplyPortamento2(unsigned char *v);
void Voice_Slot_LoadPitchOffset_A(unsigned char *v);
void Voice_Slot_LoadPitchOffset_B(unsigned char *v);
void Voice_Calc_LevelPair_Full(unsigned char *v);
void Voice_Calc_LevelPair_Mono(unsigned char *v);
void Voice_Slot_ApplyPortamentoDelta(unsigned char *v);
void Voice_ComputePitchBend2(unsigned char *v);
void WaveSel_StageB_Reg040_Footage(unsigned char *v);

/* cc900-name: Voice_Pitch_WriteOutReg_Sec=Voice_Pitch_WriteOutputReg_Secondary */
/* cc900-name: Voice_Build_GateCmd_NoPartial=Voice_Build_GateCommand_NoPartial */
/* cc900-name: WaveSel_StageB_Reg040_Footage=WaveSel_StageB_Build_Reg040_Footage */
void Voice_Artic_SetDepthPair_A(unsigned char part, unsigned char v)
{
    ram_41472[part * 287] = ((char)v >> 4) << 2;
    ram_41473[part * 287] = ((char)((char)v << 4) >> 4) * 2;
}

void Voice_Artic_SetDepthPair_B(unsigned char part, unsigned char v)
{
    ram_41474[part * 287] = ((char)v >> 4) << 2;
    ram_41475[part * 287] = ((char)((char)v << 4) >> 4) << 3;
}

void Voice_Init_Type1(unsigned char n)
{
    unsigned char *v;
    v = &ram_4308e[(int)n * 71];
    WaveSel_StageB_Build_Reg040(v);
    WaveSel_AddRandomEntryOffset(&ram_451ce);
    Pitch_Apply_Zone_Trim(v);
    Voice_Pitch_WriteOutReg_Sec(v);
    TVF_BuildEmit_Short_Dispatch(v);
    TVF_Emit_Registers_Type2(v);
    Voice_ComputePitchBend2(v);
    Voice_Build_GateCmd_NoPartial(v);
    Voice_Calc_LevelPair_FixedAtk(v);
    Voice_WriteChPanShift2(v, 0);
    Voice_Level_ClearAllOutputRegs(v);
    Voice_ComputePitch_Mono(v);
    Voice_Slot_LoadPitchOffset_B(v);
    Voice_ApplyPortamento2(v);
    ToneGen_WriteVoiceParams(n, ram_451cc);
}

void Voice_Init_Type2(unsigned char n)
{
    unsigned char *v;
    v = &ram_4308e[(int)n * 71];
    WaveSel_StageB_Build_Reg040(v);
    Pitch_Apply_Zone_Trim(v);
    Voice_Pitch_WriteOutReg_Sec(v);
    TVF_BuildEmit_Short_Dispatch(v);
    TVF_Emit_Registers_Type2(v);
    Voice_ComputePitchBend2(v);
    Voice_Build_GateCmd_NoPartial(v);
    Voice_Calc_LevelPair_FixedAtk(v);
    Voice_WriteChPanShift2(v, 0);
    Voice_Level_ClearAllOutputRegs(v);
    Voice_ComputePitch_Mono(v);
    Voice_ApplyPortamento2(v);
    ToneGen_WriteVoiceParams(n, ram_451cc);
}

void Voice_Release_Type4(unsigned char n)
{
    unsigned char *v;
    v = &ram_4308e[(int)n * 71];
    WaveSel_StageB_Reg040_Footage(v);
    Pitch_Apply_Partial_Detune(v);
    Pitch_Emit_Reg400(v);
    Voice_Level_ComputeTriplet(v);
    TVF_Build_Dispatch(v);
    TVF_Emit_Registers(v);
    Voice_StereoLevel_Compute(v);
    Voice_PortaLevel_Compute(v);
    ExtVoice_Build_SlotRegisters(v);
    Voice_SubVoice_ComputeAndTrigger(v);
    Voice2_UpdatePitch(v);
    Level_Build_Reg0C0(v);
    Voice_Build_GateCommand(v);
    if (v[3] < 3) {
        Voice_Calc_LevelPair_Full(v);
        Voice_ComputePitch(v);
        Voice_Slot_LoadPitchOffset_A(v);
        Voice_ApplyPortamento(v);
    } else {
        Voice_Calc_LevelPair_Mono(v);
        Voice_ComputePitch(v);
        Voice_Slot_ApplyPortamentoDelta(v);
        Voice_ApplyPortamento(v);
    }
    ToneGen_WriteVoiceParams(n, ram_451cc);
}

void Voice_Reload_Levels(unsigned char n)
{
    unsigned char *v;
    v = &ram_4308e[(int)n * 71];
    v[5] &= 0x7f;
    if (((*(unsigned int *)((v) + (1))) & 0x8000L) || !((*(unsigned int *)(((*(unsigned char **)((v) + (35)))) + (10))) & 1)) {
        if ((*(unsigned int *)((v) + (1))) & 0x100) {
            Voice_Calc_LevelPair_EGA(v);
            ToneGen_WriteSegRegs_SameLevel(n, ram_451cc);
            ToneGen_WriteSingleReg(n, (*(int *)((v) + (45))));
            Voice_Clear_HoldBit(n);
            (*(unsigned int *)((v) + (1))) &= ~0x100;
        } else {
            Voice_Calc_LevelPair_EGA(v);
            Voice_Calc_LevelPair_EGB(v);
            Voice_Calc_LevelPair_EGC(v);
            ToneGen_WriteLevelBurst(n, ram_451cc);
        }
    } else {
        if ((*(unsigned int *)((v) + (1))) & 0x100) {
            Voice_Calc_LevelPair_EGA(v);
            ToneGen_WriteSegRegs_SameLevel(n, ram_451cc);
            ToneGen_WriteSingleReg(n, (*(int *)((v) + (45))));
            Voice_Clear_HoldBit(n);
            (*(unsigned int *)((v) + (1))) &= ~0x100;
        } else {
            Voice_Stage_EnvSegments(v);
            ToneGen_WriteEnvSegments(n, ram_451cc);
        }
    }
}

unsigned int Voice_Slot_CalcAmpNibble(unsigned char part, unsigned char n, unsigned char e)
{
    unsigned int *q;
    unsigned int lo;
    unsigned int r;
    q = (unsigned int *)&ram_41368[part * 287];
    q += 129;
    if ((*(unsigned int *)&ram_43094[(int)n * 71] >> 8) + 12 >= 36) r = q[e];
    else {
        lo = q[e] & 0xf;
        if (lo < ((q[e] >> 4) & 0xf)) r = q[e] & 0xff0;
        else r = (q[e] & 0xf00) | (lo << 4);
    }
    return r;
}

unsigned int Voice_Slot_FindOctaveOffset(unsigned char part, unsigned char n, unsigned char e)
{
    unsigned int *q;
    unsigned char k;
    unsigned int w, r, b, c;
    q = (unsigned int *)&ram_41368[part * 287];
    q += 129;
    k = 0;
    w = (*(unsigned int *)&ram_43094[(int)n * 71] >> 8) - 12;
    while (w >= 0x54) {
        w -= 12;
        k++;
    }
    if (k == 0) r = q[e];
    else if (k == 1) {
        r = q[e] & 0xff;
        b = (q[e] >> 4) & 0xf;
        c = (q[e] >> 8) & 0xf;
        if (b < c) r = (r & 0xf) | (c << 4);
    } else {
        r = q[e] & 0xf;
        b = (q[e] >> 4) & 0xf;
        c = (q[e] >> 8) & 0xf;
        if (r < b) {
            if (b < c) r = c;
            else r = b;
        } else if (r < c) r = c;
    }
    return r;
}

void Voice_UpdateFlagsFromSlot(unsigned char part)
{
    unsigned char *q;
    unsigned int *f;
    q = &ram_41368[part * 287];
    q += 258;
    f = (unsigned int *)(ram_41368 + part * 287) + 1;
    if ((*(unsigned int *)((q) + (0))) != 0) *f |= 1; else *f &= ~1;
    if ((*(unsigned int *)((q) + (2))) != 0) *f |= 2; else *f &= ~2;
    if ((*(unsigned int *)((q) + (4))) != 0) *f |= 4; else *f &= ~4;
    if ((*(unsigned int *)((q) + (6))) != 0) *f |= 8; else *f &= ~8;
}
