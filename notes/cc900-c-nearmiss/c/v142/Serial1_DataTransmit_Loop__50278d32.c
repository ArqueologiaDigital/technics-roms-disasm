/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_9a.c (2026-11-16-86-sub-r9)
   sha256 50278d32d579b37dffe2a8c4368d5dcef6c6061274f0ddf727a7b480425c0cab (name+funcs); compiled at -Xr */
extern unsigned char __near ram_1034;
extern void SAVE_BYTE_TO_RING_BUFFER(void *rb, int c);
extern void Serial1_Enable_TX_Interrupt(void);
extern void Serial1_HandleEnableCommand(int c);
int __cdecl Serial1_DataTransmit_Loop(unsigned char n, unsigned char *p)
{
    int c;

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
