/* lane_sub helper X, round 18, form c (see sub_X_18a.c for what the ROM has in each function).
   - DSP_BytecodeInterpreter_Init: no scratch locals; the advance and the read in ONE expression with a plain
     assignment, `(code = code + 2, *code++)` (sub_S_17c had `code += 2` there, which adds to the stack slot and
     reloads).
   - DSP_ParamInterp_3Point_WithOffset: the sum in a second long local `s`, the result assigned from it after
     `*pp = p`.
   - InterCPU_DMA_Send: the callee's length an unsigned int parameter, the constant through a `register` local,
     the last call passing (unsigned char)len.
   - Keybed_Read_Event: locals declared lo, hi, st, d and the two bytes taken through a conversion,
     `(unsigned char)d & 0xff`. */

/* cc900-data: DSP_BytecodeInterpreter_Init 1 = DSP_BytecodeInterpreter_CaseOffsets */
/* cc900-module: DSP_Bytecode_NotifyStateChange */
/* cc900-module: Keybed_Decode_Event */
/* cc900-module: InterCPU_DMA_SendDataPacket */

struct bcfg { int a; int b; int c; int d; long e; };

extern unsigned char __tiny ram_18;                           /* P6 */
extern unsigned int ram_110000;
extern unsigned int ram_110002;
extern void Keybed_Decode_Event(unsigned char *ev, char d);
extern void InterCPU_DMA_SendDataPacket(unsigned char ch, unsigned int n, unsigned char *buf);
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);

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
                    st = DSP_DispatchData((code = code + 2, *code++), chip);
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
                st = DSP_DispatchData((code = code + 2, *code++), chip);
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
                    st = DSP_DispatchData((code = code + 2, *code++), chip);
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

long DSP_ParamInterp_3Point_WithOffset(unsigned char **pp, long b, long c)
{
    long v0;
    long v1;
    unsigned char *p;
    long r;
    long u;
    long s;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    v0 = (v0 >> 8) & 0xffffff;
    u = (v1 >> 8) & 0xffffff;
    v1 = u;
    s = (c + v0 + (u - v0) * b / 0x63) << 8;
    *pp = p;
    r = s;
    return r;
}

unsigned int Keybed_Read_Event(unsigned char *ev)
{
    unsigned char lo;
    unsigned char hi;
    int st;
    unsigned int d;

    ram_18 |= 0x80;
    __ASM(" nop");
    st = ram_110002;
    if (st & 1) {
        ram_18 &= ~0x80;
        __ASM(" nop");
        d = ram_110000;
        lo = (unsigned char)d & 0xff;
        hi = (unsigned char)(d >> 8) & 0xff;
        if (hi == 0xff || (st & 2)) {
            if (lo & 0x80)
                return 0xffff;
            Keybed_Decode_Event(ev, lo);
            ev[1] = 0;
            return 0;
        } else {
            Keybed_Decode_Event(ev, lo);
            return 0;
        }
    }
    return 0xffff;
}

void InterCPU_DMA_Send(unsigned char ch, unsigned int len, unsigned char *buf)
{
    register unsigned int k = 0x20;

    while (len > 0x20) {
        InterCPU_DMA_SendDataPacket(ch, k, buf);
        buf += 0x20;
        len -= 0x20;
    }
    InterCPU_DMA_SendDataPacket(ch, (unsigned char)len, buf);
}
