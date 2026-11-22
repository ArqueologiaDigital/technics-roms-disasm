/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_T_32r1m280b.c (2026-11-22-17-p6-r84)
   sha256 50a51edeec6712c6ff80bfcc8cf7f16832ba48d902d9847d854f353a3c49d452 (tar-sha256); compiled at -Xr */
extern void MIDI_WriteCommandToBuffer(int, int, int, unsigned char);
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
