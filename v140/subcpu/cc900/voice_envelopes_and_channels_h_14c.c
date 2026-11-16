/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_412f6[];
unsigned char ScaleTune_Get_User_Offset(unsigned char n);
void ScaleTune_Set_User_Offset(unsigned char n, unsigned char v);

unsigned char ScaleTune_Get_User_Offset(unsigned char n)
{
    unsigned int i = n;
    i += 12;
    return ram_412f6[(int)i];
}

void ScaleTune_Set_User_Offset(unsigned char n, unsigned char v)
{
    unsigned int i = n;
    i += 12;
    ram_412f6[(int)i] = v - 0x80;
}
