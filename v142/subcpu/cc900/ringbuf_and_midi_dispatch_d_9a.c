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
extern int ToneGen_Semitone_Pitch_Table[];
extern int ToneGen_Octave_Pitch_Table[];
extern unsigned int DSP_GetEffectRouting(void);
extern void ToneGen_WriteVoiceParams(int, unsigned int *);
extern void ToneGen_WriteSingleReg(int, unsigned int);

/* cc900-module: DSP_GetEffectRouting */
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
    {
        int pt;

        pt = ToneGen_Semitone_Pitch_Table[0];
        ram_3b1e = pt;
    }
    ToneGen_WriteVoiceParams(voice, &ram_3b1c);
    ToneGen_WriteSingleReg(voice, ram_3b1c);
}
