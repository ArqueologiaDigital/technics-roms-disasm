/* Functions of core/07_voice_ctrlchange.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41350[];
extern unsigned long ram_452f8;
extern unsigned char *ram_452fc;

void Voice_PortamentoTarget_ComputePitch(unsigned char part, unsigned char slot)
{
    unsigned int k;
    unsigned long l;
    unsigned char *s;
    unsigned int w;
    k = ((*(unsigned char **)&((unsigned char *)(unsigned long)(ram_41350 + (int)part * 287))[(int)slot * 37 + 0x6e])[3]
         & 0x30) >> 4;
    l = *(unsigned long *)(ram_452fc + 112);
    w = *(unsigned int *)(ram_452fc + 236);
    s = &((unsigned char *)(unsigned long)(ram_41350 + (int)part * 287))[(int)slot * 37 + 0x6e];
    *(unsigned long *)(s + 8) = (unsigned long)w * k + l + ram_452f8;
}
