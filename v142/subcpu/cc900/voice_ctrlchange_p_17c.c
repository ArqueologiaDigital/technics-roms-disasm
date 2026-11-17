/* Functions of core/07_voice_ctrlchange.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41368[];

void Voice_PortamentoTargets_SetAll(unsigned char part)
{
    unsigned int i;
    unsigned int v;
    for (i = 0; i < 4; i++) {
        v = (*(unsigned char **)((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287) + ((unsigned long)i * 37 + 0x6e)))[2];
        v |= (unsigned int)(*(unsigned char **)((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287) + ((unsigned long)i * 37 + 0x6e)))[3] << 8;
        *(unsigned int *)((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287) + ((unsigned long)i * 2 + 0x102)) = (int)(v & 0xfff);
    }
}
