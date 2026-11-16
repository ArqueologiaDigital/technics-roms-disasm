/* lane_sub helper B, round 7, file h: SUSPECT 4: the sounding-voice walkers (a pointer-to-71-byte-rows local, calr to the ToneGen writers)
   (KN5000 sub-CPU payload v1.42; round 6's sub_B_6a / 6b crashed V4.23, read at 0x630, so each suspect
   spelling now has a file of its own).
   cc900-module: ToneGen_WriteVoice_Short ToneGen_WriteVoice_Long ToneGen_WriteVoice_TvfPair ToneGen_WriteVoice_Reg21_Reg22 */

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;

extern unsigned int ram_41343;
extern int ram_41360;
extern int ram_41362;
extern int ram_41364;
extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_4137b[];
extern unsigned char ram_41383[];
extern unsigned char ram_41384[];
extern unsigned char ram_41385[];
extern unsigned char ram_41387[];
extern unsigned char ram_41388[];
extern unsigned char ram_413bf[];
extern unsigned char ram_413c1[];
extern unsigned char ram_413c3[];
extern unsigned char ram_413c5[];
extern unsigned char ram_413c9[];
extern unsigned char ram_413ce[];
extern unsigned char ram_4308e[][0x47];

extern unsigned int ram_451cc[];
extern unsigned int ram_451ce;
extern unsigned int ram_451d0;
extern unsigned int ram_451d2;
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
extern unsigned int ram_451d8;
extern unsigned int ram_451da;
extern unsigned int ram_451dc;
extern unsigned int ram_451de;
extern unsigned int ram_451e0;
extern unsigned int ram_451e2;
extern unsigned int ram_451e4;
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern unsigned int ram_451ea;
extern unsigned int ram_451ec;
extern unsigned int ram_451ee;
extern unsigned int ram_451f0;
extern unsigned int ram_451f2;
extern unsigned int ram_451f4;
extern unsigned int ram_451f6;
extern unsigned int ram_45206;
extern unsigned int ram_45208;
extern unsigned int ram_4520a;
extern unsigned int ram_4520c;
extern unsigned int ram_4520e;

extern unsigned char Voice_OutputLevel_Table[];
extern unsigned char Voice_PitchDepth_Scale[];
extern unsigned char Voice_FilterDepth_Scale[];

extern unsigned int DSP_AlgoType_Dispatch1(int, int);
extern unsigned int DSP_AlgoType_Dispatch2(int, int);
extern unsigned int DSP_ChanFreq_WritePacket2(int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_WriteExtParams_56(int, unsigned int *);
extern void ToneGen_WriteExtParams_56b(int, unsigned int *);
extern void ToneGen_WriteExtParams_15_Alt(int, unsigned int *);

extern void Pitch_Emit_Reg400(unsigned char *);
/* cc900-name: Voice_Pitch_WrOutReg_Secondary=Voice_Pitch_WriteOutputReg_Secondary */
extern void Voice_Pitch_WrOutReg_Secondary(unsigned char *);
extern void TVF_Emit_Registers(unsigned char *);
extern void TVF_Emit_Registers_Type2(unsigned char *);
extern void Voice_WriteChPanShift(unsigned char *, int);
extern void Voice_WriteChPanShift2(unsigned char *, int);
extern void Voice_UpdateAllLFO(void);
extern unsigned char *Voice_Query_AllChannels(void);
extern void Voice_Step_DelayTimers(unsigned char *);
extern void Voice_Clear_HoldBit(int);
extern void Voice_Reload_Levels(int);
extern int Voice_Build_OutputLevel(unsigned char *, int);
extern void Voice_Reset_Engine(int);
extern void VoiceSlot_ClearAll(void);
/* cc900-name: Voice_PerVoice_PortaPitchUpd=Voice_PerVoice_PortamentoPitchUpdate */
extern void Voice_PerVoice_PortaPitchUpd(int);
extern void VoiceParam_FullSetup(int);
extern void WaveSel_Rebuild_PartCaches(int, int, int);
extern void DSP_AdjustVoiceParams(unsigned char *);
extern void DSP_WriteAlgoBuffer(int, int);
extern void DSP_VoiceState_Dispatch(int, int);
extern void Voice_CC_SetSostenutoFlag(int, int);
extern void AlgoType_StateWrite(int, int);
extern void VoiceAlloc_WithRoutingFlag(int, int);
extern void Partial_Build_Present_Word(int);
extern void EnvTranspose_UpdateLoop(int);
extern void VoiceNoteParam_UpdateLoop(int);
extern void Voice_ActiveFlag_CheckAndLoad(int);
extern unsigned char Voice_SecondaryParam_Epilogue(int);

int Voice_ApplyPortamento(unsigned char *v);
int Voice_ApplyPortamento2(unsigned char *v);
void ToneGen_WriteVoice_Long(unsigned int ch, unsigned int *p);
void ToneGen_WriteVoice_Short(unsigned int ch, unsigned int *p);
void ToneGen_WriteVoice_TvfPair(unsigned int ch, unsigned int *p);
void ToneGen_WriteVoice_Reg21_Reg22(unsigned int ch, unsigned int *p);

void Pitch_Refresh_Sounding_Voices(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    base = ram_4308e;
    for (q = list + 5; *q < 0x40; q++) {
        v = base[*q];
        switch (*(unsigned int *)(v + 1) & 0x3c) {
        case 4:
        case 8:
        case 0x20:
            Pitch_Emit_Reg400(v);
            ToneGen_WriteVoice_Long(*q, ram_451cc);
            break;
        case 0x10:
            Voice_Pitch_WrOutReg_Secondary(v);
            ToneGen_WriteVoice_Long(*q, ram_451cc);
            break;
        }
    }
}

void TVF_Refresh_Sounding_Voices(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    base = ram_4308e;
    for (q = list + 5; *q < 0x40; q++) {
        v = base[*q];
        switch (*(unsigned int *)(v + 1) & 0x3c) {
        case 4:
        case 0x20:
            TVF_Emit_Registers(v);
            ToneGen_WriteVoice_TvfPair(*q, ram_451cc);
            break;
        case 0x10:
            TVF_Emit_Registers_Type2(v);
            ToneGen_WriteVoice_TvfPair(*q, ram_451cc);
            break;
        case 8:
            break;
        }
    }
}

void Voice_AllVoices_WriteAmplitude(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    base = ram_4308e;
    for (q = list + 5; *q < 0x40; q++) {
        v = base[*q];
        switch (*(unsigned int *)(v + 1) & 0x3c) {
        case 4:
        case 8:
        case 0x20:
            Voice_ApplyPortamento(v);
            break;
        case 0x10:
            Voice_ApplyPortamento2(v);
            break;
        }
        ToneGen_WriteVoice_Short(*q, ram_451cc);
    }
}

/* cc900-name: AudioChannel_AllVoices_UpdPan=AudioChannel_AllVoices_Update_PanShift */
void AudioChannel_AllVoices_UpdPan(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    base = ram_4308e;
    for (q = list + 5; *q < 0x40; q++) {
        v = base[*q];
        switch (*(unsigned int *)(v + 1) & 0x3c) {
        case 4:
        case 0x20:
            if (v[5] & 0x80) {
                Voice_WriteChPanShift(v, 1);
                ToneGen_WriteVoice_Reg21_Reg22(*q, ram_451cc);
            }
            break;
        case 0x10:
            if (!((*(unsigned char **)(v + 19))[13] & 0x20) || (v[5] & 0x80)) {
                Voice_WriteChPanShift2(v, 1);
                ToneGen_WriteVoice_Reg21_Reg22(*q, ram_451cc);
            }
            break;
        case 8:
            break;
        }
    }
}
