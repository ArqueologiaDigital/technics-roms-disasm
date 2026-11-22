/* Probe round 34r1, helper Y, form a: sequencer/sequencer_engine.s (module 234), unoptimised -Xr shape (both
   parameters stored to the frame and reloaded before each use, one `register` local in IZ).
   SeqVoice_CountChainLength(part, voice): 0 when the voice has no chain word or its bit 7 is clear, else the number
   of chain links (1 + each linked word whose bit 7 is set).
   Part_LinkVoiceToChain(v): error 8 and 0xffff when v's chain word is already set; else take a block from the
   free list (0xffff when none), link v and the block both ways, end the chain at the block and mark it.
   The counter / v are plain autos, the chain word / block `register`. */
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

unsigned int Part_LinkVoiceToChain(unsigned int v)
{
    register unsigned int b;

    if (PartCtrl_ReadWord(v) != 0xffff) {
        SeqData_SetErrorCode(8);
        goto fail;
    }
    b = Part_ProcessAndDecrementVoice();
    if (b == 0xffff) {
fail:
        return 0xffff;
    }
    PartCtrl_WriteWord(v, b);
    PartCtrl_WriteWord_Off1(b, v);
    PartCtrl_WriteWord(b, 0xffff);
    PartCtrl_SetClearBit7(b, 1);
    return b;
}
