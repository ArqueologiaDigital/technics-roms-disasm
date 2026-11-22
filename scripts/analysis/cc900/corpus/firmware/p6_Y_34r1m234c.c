/* Probe round 34r1, helper Y, form c: sequencer/sequencer_engine.s (module 234).
   As form a, with one spot changed per function: the `register` local declared first (CountChainLength), and the
   first failure written as an if / else whose else holds the rest (LinkVoiceToChain, no goto). */
/* cc900-module: PartCtrl_ReadWord PartCtrl_SetClearBit7 PartCtrl_TestBit7 PartCtrl_WriteWord PartCtrl_WriteWord_Off1 Part_ProcessAndDecrementVoice Part_ReadVoiceBit7 Part_ReadVoiceWord SeqData_SetErrorCode */

extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern unsigned char Part_ReadVoiceBit7(unsigned int, unsigned int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern unsigned int PartCtrl_ReadWord(unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
extern unsigned int Part_ProcessAndDecrementVoice(void);
extern void SeqData_SetErrorCode(unsigned int);
extern unsigned int SeqVoice_CountChainLength(unsigned char, unsigned char);
extern unsigned int Part_LinkVoiceToChain(unsigned int);

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

unsigned int Part_LinkVoiceToChain(unsigned int v)
{
    register unsigned int b;

    if (PartCtrl_ReadWord(v) != 0xffff) {
        SeqData_SetErrorCode(8);
    } else {
        b = Part_ProcessAndDecrementVoice();
        if (b != 0xffff) {
            PartCtrl_WriteWord(v, b);
            PartCtrl_WriteWord_Off1(b, v);
            PartCtrl_WriteWord(b, 0xffff);
            PartCtrl_SetClearBit7(b, 1);
            return b;
        }
    }
    return 0xffff;
}
