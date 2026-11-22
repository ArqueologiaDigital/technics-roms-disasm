/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Y_34r1m234c.c (2026-11-22-21-p6-r88)
   sha256 8d6ca8907d47b32f95b8e14c79e31e51bc84afaa3821818288bf5706fdf23b2d (tar-sha256); compiled at -Xr */
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern unsigned char Part_ReadVoiceBit7(unsigned int, unsigned int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern unsigned int PartCtrl_ReadWord(unsigned int);
unsigned int SeqVoice_CountChainLength(unsigned char part, unsigned char voice)
{
    register unsigned int w;
    unsigned int n;

    w = Part_ReadVoiceWord(part, voice);
    if (w == 0xffff || Part_ReadVoiceBit7(part, voice) == 0)
        return 0;
    n = 1;
    while (w != 0xffff) {
        if (PartCtrl_TestBit7(w) == 0)
            break;
        w = PartCtrl_ReadWord(w);
        n++;
    }
    return n;
}
