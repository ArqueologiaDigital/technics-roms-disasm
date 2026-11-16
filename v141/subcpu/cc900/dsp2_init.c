/* Functions of core/12_dsp2_init.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

void DSP2_InitTask_NullStub(void)
{
    return;
}

unsigned long DSP_Pack3x7bitFields(unsigned char *p)
{
    return (unsigned long)(unsigned char)(p[3] & 0x7f)
        | ((unsigned long)(unsigned char)(p[1] & 0x7f) << 14 | (unsigned long)(unsigned char)(p[2] & 0x7f) << 7);
}

struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
extern struct ring2k __near DSP2_RingBuffer;

void DSP2_Init(void)
{
    DSP2_RingBuffer.w = DSP2_RingBuffer.r = DSP2_RingBuffer.n = 0;
}

unsigned int Extract_14Bit_PayloadSize(unsigned char *p)
{
    return (((unsigned int)p[5] & 0x7f) << 7) | ((unsigned int)p[6] & 0x7f);
}

unsigned int Extract_14Bit_VoiceParam(unsigned char *p)
{
    return (((unsigned int)p[2] & 0x7f) << 7) | ((unsigned int)p[3] & 0x7f);
}

extern unsigned int __near ram_4488;
extern unsigned int __near ram_448a;
extern unsigned int __near ram_448c;

int __cdecl Audio_CmdHandler_60_7F(unsigned int n, unsigned char *p)
{
    unsigned int i;
    unsigned int size;

    if (ram_448c != 0) {
        if (ram_448c > 1)
            i = 0;
        if (ram_448a + n < ram_4488) {
            ram_448a += n;
            ram_448c++;
        } else {
            ram_448a = 0;
            ram_448c = 0;
        }
    } else if (n == 0x20) {
        size = p[5] & 0x7ff;
        size <<= 7;
        ram_4488 = p[6] + size + 8;
        ram_448a += 32;
        ram_448c = 1;
    } else {
        ram_448a = 0;
        ram_448c = 0;
    }
    for (i = 0; i < n; i++) {
        DSP2_RingBuffer.buf[DSP2_RingBuffer.w++ & 0x7ff] = *p++;
        DSP2_RingBuffer.n++;
    }
    return 0;
}
