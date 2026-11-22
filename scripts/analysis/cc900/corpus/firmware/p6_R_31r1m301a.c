/* Probe round 31r1, helper R, form a: audio/note_voice_mapping.s SndPart_SendProgramChange (module 301), next to the
   built SubCPU_SendSystemRecord / MIDI_Send* packet senders (cc900/note_voice_mapping_m301_xr.c).  Form a passes the
   bank / program parameters' own addresses to SndParam_ApplyMaskClamp. */

extern unsigned int __near AUDIO_CONFIG_FLAGS;
extern void SndParam_ApplyMaskClamp(unsigned char *p, unsigned char *q);
extern void MIDI_SendCmdPacket(unsigned char *);
extern void MIDI_PostSendStub(void);
extern void MidiEvent_ConfigChannel(int, int);
extern void SndPart_SendProgramChange(int part, unsigned char bank, unsigned char prog, int fx);

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
