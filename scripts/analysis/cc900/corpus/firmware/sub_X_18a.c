/* lane_sub helper X, round 18, form a: the four functions round 17 left open with a sub_S_17* best attempt (KN5000
   sub-CPU payload v1.42, core/14_dsp_control_routines.s and core/04_intercpu_link.s).
   - DSP_BytecodeInterpreter_Init (sub_S_17a, +423): in the three `code + 2` places the ROM keeps the advanced
     pointer in XWA and reads the byte into C; sub_S_17a's scratch pointer got XBC and its byte A.  Helper G's
     DSP_WriteLUTParamSet had the same exchange and lost it when the byte local was declared BEFORE the pointer
     local (v142/subcpu/cc900/dsp_control_routines_l_16a.c): here `c` and `q` are the first two locals, in
     that order, as in that file.
   - DSP_ParamInterp_3Point_WithOffset (sub_S_17a, +93): the ROM builds the sum in XWA, keeps it there across
     `*pp = p` (which goes through XBC) and copies it to XHL at the return; ours built it straight in XHL.  Here
     the result local is unsigned long, so the return converts it.
   - InterCPU_DMA_Send (sub_S_17b, +22): the ROM loads the constant 0x20 as a word before the buffer pointer and
     extends the last packet's byte length (`extz bc`): the callee's length is an unsigned int parameter and the
     last call passes (unsigned char)len; the constant stays a literal.
   - Keybed_Read_Event (sub_S_17c, +7): the ROM has the status in BC, the low byte in L and the high byte in E,
     with a copy of L to C at the calls; ours had DE, C and A.  Here the locals are declared lo, hi, st, d. */

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
    unsigned char c;
    unsigned char *q;
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
                    q = code + 2;
                    code = q;
                    c = *q++;
                    code = q;
                    st = DSP_DispatchData(c, chip);
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
                q = code + 2;
                code = q;
                c = *q++;
                code = q;
                st = DSP_DispatchData(c, chip);
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
                    q = code + 2;
                    code = q;
                    c = *q++;
                    code = q;
                    st = DSP_DispatchData(c, chip);
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
    unsigned long r;
    long u;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    v0 = (v0 >> 8) & 0xffffff;
    u = (v1 >> 8) & 0xffffff;
    v1 = u;
    r = (c + v0 + (u - v0) * b / 0x63) << 8;
    *pp = p;
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
        lo = d & 0xff;
        hi = (d >> 8) & 0xff;
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
    while (len > 0x20) {
        InterCPU_DMA_SendDataPacket(ch, 0x20, buf);
        buf += 0x20;
        len -= 0x20;
    }
    InterCPU_DMA_SendDataPacket(ch, (unsigned char)len, buf);
}
