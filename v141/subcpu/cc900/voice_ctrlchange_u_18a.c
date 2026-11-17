/* Functions of core/07_voice_ctrlchange.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;

void ToneGen_SilenceChannel(unsigned char ch)
{
    (void)&ch;
    ram_18 &= 0x7f;
    ram_100000 = (unsigned char)(ch + 0xc0);
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = 0;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= 0x7f;
    ram_100000 = ch;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = 0x7e00;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}
