/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_31r1m301a.c (2026-11-22-15-p6-r82)
   sha256 fc0bdd4e1ce2faeb277782227a33793c40d7212f3fdb56e1d66cde9f40e05d52 (tar-sha256); compiled at -Xr */
extern unsigned int __near AUDIO_CONFIG_FLAGS;
extern void SndParam_ApplyMaskClamp(unsigned char *p, unsigned char *q);
extern void MIDI_SendCmdPacket(unsigned char *);
extern void MIDI_PostSendStub(void);
extern void MidiEvent_ConfigChannel(int, int);
void SndPart_SendProgramChange(int part, unsigned char bank, unsigned char prog, int fx)
{
    unsigned char b[6];

    if (fx == -1)
        fx = 0;
    else
        fx = fx != 0 ? 0x7f : 0;
    SndParam_ApplyMaskClamp(&bank, &prog);
    b[0] = 5; b[1] = 0xc0; b[2] = part; b[3] = bank; b[4] = prog; b[5] = fx;
    MIDI_SendCmdPacket(b);
    MIDI_PostSendStub();
    if (part == 2 && (AUDIO_CONFIG_FLAGS & 0x80) == 0x80 && !(AUDIO_CONFIG_FLAGS & 0x100))
        MidiEvent_ConfigChannel(0xff, 2);
    if (part == 0x15)
        MidiEvent_ConfigChannel(0xff, 0x15);
    if (part == 0x16)
        MidiEvent_ConfigChannel(0xff, 0x16);
}
