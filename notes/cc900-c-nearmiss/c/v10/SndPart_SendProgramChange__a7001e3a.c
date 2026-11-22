/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_31r1m301b.c (2026-11-22-15-p6-r82)
   sha256 a7001e3ac3832f9377e0cd3dffbb87163ab3ddcd5bb19d3826fcc3e848129717 (tar-sha256); compiled at -Xr */
extern unsigned int __near AUDIO_CONFIG_FLAGS;
extern void SndParam_ApplyMaskClamp(unsigned char *p, unsigned char *q);
extern void MIDI_SendCmdPacket(unsigned char *);
extern void MIDI_PostSendStub(void);
extern void MidiEvent_ConfigChannel(int, int);
void SndPart_SendProgramChange(int part, unsigned char bank, unsigned char prog, int fx)
{
    unsigned char vb;
    unsigned char vp;
    unsigned char b[6];

    if (fx == -1)
        fx = 0;
    else
        fx = fx != 0 ? 0x7f : 0;
    vb = bank;
    vp = prog;
    SndParam_ApplyMaskClamp(&vb, &vp);
    b[0] = 5; b[1] = 0xc0; b[2] = part; b[3] = vb; b[4] = vp; b[5] = fx;
    MIDI_SendCmdPacket(b);
    MIDI_PostSendStub();
    if (part == 2 && (AUDIO_CONFIG_FLAGS & 0x80) == 0x80 && !(AUDIO_CONFIG_FLAGS & 0x100))
        MidiEvent_ConfigChannel(0xff, 2);
    if (part == 0x15)
        MidiEvent_ConfigChannel(0xff, 0x15);
    if (part == 0x16)
        MidiEvent_ConfigChannel(0xff, 0x16);
}
