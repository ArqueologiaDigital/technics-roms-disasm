/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_9b.c (2026-11-16-86-sub-r9)
   sha256 1da6a1690db331bb9bef7b317d3f4194c4c953d5ba1c69b3b409c7cc311d550e (name+funcs); compiled at -Xr */
extern unsigned char __near ram_1034;
extern void SAVE_BYTE_TO_RING_BUFFER(void *rb, int c);
extern void Serial1_Enable_TX_Interrupt(void);
extern void Serial1_HandleEnableCommand(int c);
int __cdecl Serial1_DataTransmit_Loop(unsigned char n, unsigned char *p)
{
    unsigned int c;

    while (n--) {
        if (!(ram_1034 & 4)) {
            c = *p++;
            Serial1_HandleEnableCommand(c);
        } else {
            c = *p++;
            SAVE_BYTE_TO_RING_BUFFER((void *)0x1016, c);
            Serial1_Enable_TX_Interrupt();
        }
    }
    return 0;
}
