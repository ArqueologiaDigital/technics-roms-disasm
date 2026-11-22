/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Y_34r1m234c.c (2026-11-22-21-p6-r88)
   sha256 8d6ca8907d47b32f95b8e14c79e31e51bc84afaa3821818288bf5706fdf23b2d (tar-sha256); compiled at -O3 -Xr */
extern unsigned int PartCtrl_ReadWord(unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
extern unsigned int Part_ProcessAndDecrementVoice(void);
extern void SeqData_SetErrorCode(unsigned int);
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
