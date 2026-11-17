/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_13b.c (2026-11-16-99-sub-r13-idioms)
   sha256 0501825fad663d83e955d81b7d85b3bb7a70d125b2c417ebb8e80ecbb1b7e3de (name+funcs); compiled at -O2 -Xr */
extern int AudioChannel_Handler_Cmd01(int);
extern int AudioChannel_Handler_Cmd02(int);
extern int AudioChannel_Handler_Cmd03(int);
extern int AudioChannel_Handler_Cmd04_07(int, int, unsigned char *, int);
extern int AudioChannel_Handler_Cmd08_0B(int, int, unsigned char *, int);
extern int AudioChannel_Handler_Cmd0C_0F(int, int, unsigned char *, int);
extern int AudioChannel_Handler_Cmd10_13(int, int, unsigned char *, int);
extern int AudioChannel_Handler_Cmd14_17(int, int, unsigned char *, int);
extern int AudioChannel_Handler_Cmd18_1B(int, int, unsigned char *, int);
int AudioChannel_Dispatch(unsigned char a, unsigned char b, unsigned char *d)
{
    int c;

    c = d[1] & 0x3f;
    switch (c) {
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
