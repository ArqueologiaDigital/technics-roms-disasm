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

extern unsigned char *ram_45304;
extern unsigned char *ram_45308;
extern unsigned char ram_7800[];
extern unsigned char DSP1_ImageHeader_SoundRAM[];

void DSP_ResetAlgoDefaults(void)
{
    unsigned int i;

    for (i = 0; i < 16; i++)
        ram_45304[i] = DSP1_ImageHeader_SoundRAM[i];
}

void DSP_ResetWriteBufferPtr(void)
{
    ram_45308 = ram_7800;
    ram_45304 = ram_7800;
}

void DSP_Stub_RetB(void)
{
}

void DSP_Stub_RetC(void)
{
}
