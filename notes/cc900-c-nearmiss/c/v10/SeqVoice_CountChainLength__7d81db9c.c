/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Y_34r1m234a.c (2026-11-22-21-p6-r88)
   sha256 7d81db9c33c3f0dcfe4a3a07390f754ef28c9157482f63d864f58744ac5809e8 (tar-sha256); compiled at -Xr */
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern unsigned char Part_ReadVoiceBit7(unsigned int, unsigned int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern unsigned int PartCtrl_ReadWord(unsigned int);
unsigned int SeqVoice_CountChainLength(unsigned char part, unsigned char voice)
{
    unsigned int n;
    register unsigned int w;

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
