/* Probe round 32r1, helper T, form b: audio/audio_control_engine.s (module 280), as form a with a for loop
   and the stack-argument byte as an unsigned char prototype. */
/* cc900-module: MIDI_WriteCommandToBuffer */

extern void MIDI_WriteCommandToBuffer(int, int, int, unsigned char);
extern void MIDI_WriteMultiByteWithHeader(unsigned char *);

void MIDI_WriteMultiByteWithHeader(unsigned char *s)
{
    unsigned char ch;
    unsigned char n;
    unsigned char i;

    ch = *s++;
    n = *s++;
    MIDI_WriteCommandToBuffer(ch, 1, s[1], 0xff);
    MIDI_WriteCommandToBuffer(ch, 0, *s, 0xff);
    n -= 2;
    i = 2;
    for (s += 2; n != 0; s++) {
        MIDI_WriteCommandToBuffer(ch, i, *s, 0xff);
        n--;
        i++;
    }
}
