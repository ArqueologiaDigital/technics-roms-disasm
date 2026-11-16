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
