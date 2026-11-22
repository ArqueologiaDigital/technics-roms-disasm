/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Y_34r1m234b.c (2026-11-22-21-p6-r88)
   sha256 26191255ff5bc96d9e5e992dc82a0809cd8a51e2b41a741b8ef120086c9704fb (tar-sha256); compiled at -Xr */
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern unsigned char Part_ReadVoiceBit7(unsigned int, unsigned int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern unsigned int PartCtrl_ReadWord(unsigned int);
unsigned int SeqVoice_CountChainLength(unsigned char part, unsigned char voice)
{
    unsigned int n;
    unsigned int w;

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
