/* Functions of core/11_ringbuf_and_midi_dispatch.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

unsigned int DSP_VelocityToVolume(unsigned int v) { return ((v * v) >> 2) + 0x3f; }

extern unsigned char *ram_4531c;
extern unsigned char *ram_45320;
extern unsigned char ram_7800[];
extern unsigned char DSP1_ImageHeader_SoundRAM[];

void DSP_ResetAlgoDefaults(void)
{
    unsigned int i;

    for (i = 0; i < 16; i++)
        ram_4531c[i] = DSP1_ImageHeader_SoundRAM[i];
}

void DSP_ResetWriteBufferPtr(void)
{
    ram_45320 = ram_7800;
    ram_4531c = ram_7800;
}

void DSP_Stub_RetB(void)
{
}

void DSP_Stub_RetC(void)
{
}

struct ring4k { unsigned int w, r, n; unsigned char buf[4096]; };
extern struct ring4k __near MIDI_RingBuffer;
extern unsigned char ram_41377;
extern unsigned char ram_4137a;

int __cdecl Audio_CmdHandler_00_1F(int n, const unsigned char *p)
{
    while (n != 0) {
        MIDI_RingBuffer.buf[MIDI_RingBuffer.w++ & 0xfff] = *p;
        MIDI_RingBuffer.n++;
        n--;
        p++;
    }
    return 0;
}

unsigned int DSP_GetEffectRouting(void)
{
    unsigned int r;
    r = 0;
    if (ram_41377 != 0)
        r |= (unsigned int)ram_41377 << 8;
    if (ram_4137a != 0)
        r |= ram_41377;
    return r;
}
