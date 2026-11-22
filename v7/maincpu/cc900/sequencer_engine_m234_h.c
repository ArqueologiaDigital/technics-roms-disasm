/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PartCtrl_ReadWord PartCtrl_SetClearBit7 PartCtrl_TestBit7 PartCtrl_WriteWord PartCtrl_WriteWord_Off1 Part_ProcessAndDecrementVoice Part_ReadVoiceBit7 Part_ReadVoiceWord SeqData_SetErrorCode */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int PartCtrl_ReadWord(unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
extern unsigned int Part_ProcessAndDecrementVoice(void);
extern void SeqData_SetErrorCode(unsigned int);
extern unsigned int Part_LinkVoiceToChain(unsigned int);
extern unsigned int Part_LinkVoiceToChain(unsigned int v);
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern unsigned char Part_ReadVoiceBit7(unsigned int, unsigned int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern unsigned int SeqVoice_CountChainLength(unsigned char, unsigned char);
extern unsigned int SeqVoice_CountChainLength(unsigned char part, unsigned char voice);

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
