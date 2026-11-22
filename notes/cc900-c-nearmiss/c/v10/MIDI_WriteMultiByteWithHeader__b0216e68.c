/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_T_32r1m280a.c (2026-11-22-17-p6-r84)
   sha256 b0216e68c3ef7afee1c1aef47ec9a2935efe1ec0a19b50092ef0064492a36671 (tar-sha256); compiled at -Xr */
extern void MIDI_WriteCommandToBuffer(int, int, int, int);
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
