/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern int AudioChannel_Handler_Cmd01(int);
extern int AudioChannel_Handler_Cmd02(int);
extern int AudioChannel_Handler_Cmd03(int);
extern int AudioChannel_Handler_Cmd04_07(int, int, unsigned char *, int);
extern int AudioChannel_Handler_Cmd08_0B(int, int, unsigned char *, int);
extern int AudioChannel_Handler_Cmd0C_0F(int, int, unsigned char *, int);
extern int AudioChannel_Handler_Cmd10_13(int, int, unsigned char *, int);
extern int AudioChannel_Handler_Cmd14_17(int, int, unsigned char *, int);
extern int AudioChannel_Handler_Cmd18_1B(int, int, unsigned char *, int);

/* cc900-module: AudioChannel_Handler_Cmd01 AudioChannel_Handler_Cmd02 AudioChannel_Handler_Cmd03 AudioChannel_Handler_Cmd04_07 AudioChannel_Handler_Cmd08_0B AudioChannel_Handler_Cmd0C_0F AudioChannel_Handler_Cmd10_13 AudioChannel_Handler_Cmd14_17 AudioChannel_Handler_Cmd18_1B */
int AudioChannel_Dispatch(unsigned char a, unsigned char b, unsigned char *d)
{
    switch (d[1] & 0x3f) {
    case 1: return AudioChannel_Handler_Cmd01(a);
    case 2: return AudioChannel_Handler_Cmd02(a);
    case 3: return AudioChannel_Handler_Cmd03(a);
    case 4: AudioChannel_Handler_Cmd04_07(a, b, d, 0); break;
    case 5: AudioChannel_Handler_Cmd04_07(a, b, d, 1); break;
    case 6: AudioChannel_Handler_Cmd04_07(a, b, d, 2); break;
    case 7: AudioChannel_Handler_Cmd04_07(a, b, d, 3); break;
    case 8: AudioChannel_Handler_Cmd08_0B(a, b, d, 0); break;
    case 9: AudioChannel_Handler_Cmd08_0B(a, b, d, 1); break;
    case 10: AudioChannel_Handler_Cmd08_0B(a, b, d, 2); break;
    case 11: AudioChannel_Handler_Cmd08_0B(a, b, d, 3); break;
    case 12: AudioChannel_Handler_Cmd0C_0F(a, b, d, 0); break;
    case 13: AudioChannel_Handler_Cmd0C_0F(a, b, d, 1); break;
    case 14: AudioChannel_Handler_Cmd0C_0F(a, b, d, 2); break;
    case 15: AudioChannel_Handler_Cmd0C_0F(a, b, d, 3); break;
    case 16: AudioChannel_Handler_Cmd10_13(a, b, d, 0); break;
    case 17: AudioChannel_Handler_Cmd10_13(a, b, d, 1); break;
    case 18: AudioChannel_Handler_Cmd10_13(a, b, d, 2); break;
    case 19: AudioChannel_Handler_Cmd10_13(a, b, d, 3); break;
    case 20: AudioChannel_Handler_Cmd14_17(a, b, d, 0); break;
    case 21: AudioChannel_Handler_Cmd14_17(a, b, d, 1); break;
    case 22: AudioChannel_Handler_Cmd14_17(a, b, d, 2); break;
    case 23: AudioChannel_Handler_Cmd14_17(a, b, d, 3); break;
    case 24: AudioChannel_Handler_Cmd18_1B(a, b, d, 0); break;
    case 25: AudioChannel_Handler_Cmd18_1B(a, b, d, 1); break;
    case 26: AudioChannel_Handler_Cmd18_1B(a, b, d, 2); break;
    case 27: AudioChannel_Handler_Cmd18_1B(a, b, d, 3); break;
    }
}
