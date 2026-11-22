/* Probe round 32r1, helper T, form a: audio/audio_control_engine.s (module 280).
   MIDI_WriteMultiByteWithHeader: a channel byte, a count byte, then the data bytes; the first two data bytes go
   out as items 1 and 0, the rest as items 2, 3, ...  Three char locals in stack slots, the pointer in XIZ. */
/* cc900-module: MIDI_WriteCommandToBuffer */

extern void MIDI_WriteCommandToBuffer(int, int, int, int);
extern void MIDI_WriteMultiByteWithHeader(unsigned char *);

void MIDI_WriteMultiByteWithHeader(unsigned char *s)
{
    unsigned char ch;
    unsigned char n;
    unsigned char i;

    ch = *s++;
    n = *s++;
    MIDI_WriteCommandToBuffer(ch, 1, s[1], 0xff);
    MIDI_WriteCommandToBuffer(ch, 0, s[0], 0xff);
    n -= 2;
    i = 2;
    s += 2;
    while (n != 0) {
        MIDI_WriteCommandToBuffer(ch, i, *s, 0xff);
        n--;
        i++;
        s++;
    }
}
