/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_12a.c (2026-11-16-97-sub-r12)
   sha256 ef09c91dc22bf5001d41879e57e9b0da009e69828006decb9be0884688d9809d (name+funcs); compiled at -Xr */
struct bcfg { int a; int b; int c; int d; long e; };
extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern void DSP2_SPI_BusIdle(void);
extern void DSP_Bytecode_NotifyStateChange(void);
int DSP_BytecodeInterpreter_Init(int chip, unsigned int idx, struct bcfg *cfg, unsigned char *code)
{
    int st;
    unsigned int t;
    unsigned int op;
    unsigned int i;
    unsigned int len;
    int f0;
    int f1;
    int f2;
    int f3;
    long f4;

    f0 = cfg[idx].a;
    f1 = cfg[idx].b;
    f2 = cfg[idx].c;
    f3 = cfg[idx].d;
    f4 = cfg[idx].e;
    while ((*code & 0xf0) != 0xf0) {
        op = *code & 0xf0;
        len = ((int)(*code & 0xf) << 8) + (int)(code[1] & 0xff) - 2;
        code = code + 2;
        switch (op >> 4) {
        case 0:
            st = DSP_DispatchCommand(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            for (i = 1; i <= (len - 3) / 5; i++) {
                if (*code == 0) {
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData(*code++, chip);
                    t = ((unsigned int)code[0] << 4) + ((code[1] >> 4) & 0xf);
                    t += (unsigned int)f1;
                    st = DSP_DispatchData((unsigned char)((t >> 4) & 0xff), chip);
                    st = DSP_DispatchData((unsigned char)((t << 4) & 0xff), chip);
                    code = code + 2;
                    st = DSP_DispatchData(*code++, chip);
                } else if (*code == 10) {
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData(*code++, chip);
                } else {
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData((unsigned char)(code[0] + ((f4 >> 17) & 0x7f)), chip);
                    st = DSP_DispatchData((unsigned char)(code[1] + ((f4 >> 9) & 0xff)), chip);
                    st = DSP_DispatchData((unsigned char)(code[2] + ((f4 >> 1) & 0xff)), chip);
                    st = DSP_DispatchData((unsigned char)(code[3] + ((f4 << 7) & 0x80)), chip);
                    code = code + 4;
                }
            }
            break;
        case 1:
            st = DSP_DispatchCommand(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            for (i = 1; i <= (len - 3) / 5; i++) {
                st = DSP_DispatchData(*code++, chip);
                st = DSP_DispatchData(*code++, chip);
                t = ((unsigned int)code[0] << 4) + ((code[1] >> 4) & 0xf);
                t += (unsigned int)f0;
                st = DSP_DispatchData((unsigned char)((t >> 4) & 0xff), chip);
                st = DSP_DispatchData((unsigned char)(((t << 4) & 0xff) + 8), chip);
                code = code + 2;
                st = DSP_DispatchData(*code++, chip);
            }
            break;
        case 2:
            st = DSP_DispatchCommand(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            for (i = 1; i <= (len - 3) / 3; i++) {
                st = DSP_DispatchData(*code++, chip);
                st = DSP_DispatchData(*code++, chip);
                st = DSP_DispatchData(*code++, chip);
            }
            break;
        case 3:
            st = DSP_DispatchCommand(*code++, chip);
            t = ((unsigned int)code[0] << 8) + (code[1] & 0xff);
            t += (unsigned int)f3;
            st = DSP_DispatchData((unsigned char)((t >> 8) & 0xff), chip);
            st = DSP_DispatchData((unsigned char)(t & 0xff), chip);
            code = code + 2;
            for (i = 1; i <= len - 3; i++)
                st = DSP_DispatchData(*code++, chip);
            break;
        case 4:
            st = DSP_DispatchCommand(*code++, chip);
            break;
        case 5:
            st = DSP_DispatchCommand(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            for (i = 1; i <= (len - 3) / 5; i++) {
                if (*code == 8) {
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData(*code++, chip);
                    t = ((unsigned int)code[0] << 4) + ((code[1] >> 4) & 0xf);
                    t += (unsigned int)f2;
                    t &= 0xff;
                    st = DSP_DispatchData((unsigned char)((t >> 4) & 0xff), chip);
                    st = DSP_DispatchData((unsigned char)(((t << 4) & 0xff) + 8), chip);
                    code = code + 2;
                    st = DSP_DispatchData(*code++, chip);
                } else {
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData((unsigned char)(code[0] + ((f4 >> 17) & 0x7f)), chip);
                    st = DSP_DispatchData((unsigned char)(code[1] + ((f4 >> 9) & 0xff)), chip);
                    st = DSP_DispatchData((unsigned char)(code[2] + ((f4 >> 1) & 0xff)), chip);
                    st = DSP_DispatchData((unsigned char)(code[3] + ((f4 << 7) & 0x80)), chip);
                    code = code + 4;
                }
            }
            break;
        case 0xd:
            DSP2_SPI_BusIdle();
            DSP_Bytecode_NotifyStateChange();
            break;
        case 0xe:
            st = DSP_DispatchCommand(*code++, chip);
            for (i = 1; i <= len - 1; i++)
                st = DSP_DispatchData(*code++, chip);
            break;
        }
    }
    return st;
}
