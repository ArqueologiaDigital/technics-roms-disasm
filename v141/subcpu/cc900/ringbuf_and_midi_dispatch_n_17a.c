/* Functions of core/11_ringbuf_and_midi_dispatch.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

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

/* cc900-module: DSP_GetEffectRouting DSP_VelocityToVolume */
void ToneGen_SetupPolyVoice(unsigned char voice, unsigned char type, unsigned char note, unsigned char vel)
{
    *(struct tgparams *)0x3b1c = *(struct tgparams *)0x12115;
    {
        unsigned char x;
        x = Audio_DSP_StateTable_Packed[type] + note;
        note = x;
    }
    note &= 0x7f;
    ram_3b2a = ((unsigned int)note << 8) | 0x80;
    if (ToneGen_VoiceType_Default_Level[type] != 0)
        vel = ToneGen_VoiceType_Default_Level[type];
    ram_3b20 |= DSP_VelocityToVolume(vel);
    ram_3b22 |= DSP_GetEffectRouting();
    {
        int t;
        t = ToneGen_Semitone_Pitch_Table[note % 12];
        ram_3b1e = t;
    }
    ToneGen_WriteVoiceParams(voice, &ram_3b1c);
    ToneGen_WriteSingleReg(voice, ram_3b1c);
}
