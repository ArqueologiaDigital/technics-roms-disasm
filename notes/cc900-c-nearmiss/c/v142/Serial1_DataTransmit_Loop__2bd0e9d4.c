/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_8a.c (2026-11-16-82-sub-r8)
   sha256 2bd0e9d403659e27609b3db2776547ab4944dd194edf600e4ea44c78b9847464 (name+funcs); compiled at -Xr */
extern unsigned char __near ram_1034;
extern void SAVE_BYTE_TO_RING_BUFFER(void *rb, int c);
extern void Serial1_Enable_TX_Interrupt(void);
extern void Serial1_HandleEnableCommand(unsigned int c);
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
