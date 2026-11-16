/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_7c.c (2026-11-16-79-sub-r7)
   sha256 650eeae51d68d405c677a408096d7d6e93bb8d1452054784e0988350f0418cdb (name+funcs); compiled at -Xr */
struct tgparams { int w[0x22]; };
extern unsigned int __near ram_3b1c;
extern unsigned int __near ram_3b1e;
extern unsigned int __near ram_3b20;
extern unsigned int __near ram_3b22;
extern unsigned int __near ram_3b2a;
extern unsigned char Audio_DSP_StateTable_Packed[];
extern unsigned char ToneGen_VoiceType_Default_Level[];
extern int ToneGen_Semitone_Pitch_Table[];
extern unsigned int DSP_GetEffectRouting(void);
extern unsigned int DSP_VelocityToVolume(unsigned int);
extern void ToneGen_WriteVoiceParams(int, unsigned int *);
extern void ToneGen_WriteSingleReg(int, unsigned int);
void ToneGen_SetupPolyVoice(unsigned char voice, unsigned char type, unsigned char note, unsigned char vel)
{
    *(struct tgparams *)0x3b1c = *(struct tgparams *)0x12115;
    note += Audio_DSP_StateTable_Packed[type];
    note &= 0x7f;
    ram_3b2a = ((unsigned int)note << 8) | 0x80;
    if (ToneGen_VoiceType_Default_Level[type] != 0)
        vel = ToneGen_VoiceType_Default_Level[type];
    ram_3b20 |= DSP_VelocityToVolume(vel);
    ram_3b22 |= DSP_GetEffectRouting();
    ram_3b1e = ToneGen_Semitone_Pitch_Table[note % 12];
    ToneGen_WriteVoiceParams(voice, &ram_3b1c);
    ToneGen_WriteSingleReg(voice, ram_3b1c);
}
