/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_7a.c (2026-11-16-79-sub-r7)
   sha256 5387fb8dc1a4a10ac803200b808b9746db79da03261b93a1784389397bca675d (name+funcs); compiled at -Xr */
extern unsigned char __near ram_1034;
extern void SAVE_BYTE_TO_RING_BUFFER(void *rb, int c);
extern void Serial1_Enable_TX_Interrupt(void);
extern void Serial1_HandleEnableCommand(int c);
int __cdecl Serial1_DataTransmit_Loop(unsigned char n, unsigned char *p)
{
    while (n--) {
        if (!(ram_1034 & 4)) {
            Serial1_HandleEnableCommand(*p++);
        } else {
            SAVE_BYTE_TO_RING_BUFFER((void *)0x1016, *p++);
            Serial1_Enable_TX_Interrupt();
        }
    }
    return 0;
}
