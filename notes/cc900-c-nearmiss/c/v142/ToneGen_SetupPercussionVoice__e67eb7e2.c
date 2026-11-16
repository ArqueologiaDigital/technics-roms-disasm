/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_9c.c (2026-11-16-86-sub-r9)
   sha256 e67eb7e2c0c66eb6b52a53b2f206995f13036598ffdb92b26d1921ab65cda84b (name+funcs); compiled at -Xr */
struct tgparams { int w[0x22]; };
extern unsigned int __near ram_3b1c;
extern unsigned int __near ram_3b1e;
extern unsigned int __near ram_3b20;
extern unsigned int __near ram_3b22;
extern unsigned int __near ram_3b2a;
extern int ToneGen_Semitone_Pitch_Table[];
extern int ToneGen_Octave_Pitch_Table[];
extern unsigned int DSP_GetEffectRouting(void);
extern void ToneGen_WriteVoiceParams(int, unsigned int *);
extern void ToneGen_WriteSingleReg(int, unsigned int);
void ToneGen_SetupPercussionVoice(unsigned char voice, unsigned char b, unsigned char note, unsigned char vel)
{
    unsigned char s;

    *(struct tgparams *)0x3b1c = *(struct tgparams *)0x12115;
    s = note % 12;
    note = (note - s) & 0x7f;
    ram_3b2a |= (unsigned int)note << 8;
    ram_3b1c |= ToneGen_Octave_Pitch_Table[s];
    ram_3b22 |= DSP_GetEffectRouting();
    ram_3b20 |= 0xfff;
    ram_3b1e = (int)ToneGen_Semitone_Pitch_Table[0];
    ToneGen_WriteVoiceParams(voice, &ram_3b1c);
    ToneGen_WriteSingleReg(voice, ram_3b1c);
}
