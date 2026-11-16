/* lane_sub helper B, round 7, file e: SUSPECT 2: __IZ for the channel + the record pointer in a one-member local struct
   (KN5000 sub-CPU payload v1.42; round 6's sub_B_6a / 6b crashed V4.23, read at 0x630, so each suspect
   spelling now has a file of its own). */

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

void ToneGen_WriteVoice_TvfPair(unsigned int ch, unsigned int *p)
{
    struct { unsigned int *p; } s;
    s.p = p;
    __IZ = ch;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 256;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = s.p[4];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 320;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = s.p[5];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg21_Reg22(unsigned int ch, unsigned int *p)
{
    struct { unsigned int *p; } s;
    s.p = p;
    __IZ = ch;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 2112;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = s.p[13];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 2176;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = s.p[14];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}
