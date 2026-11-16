/* Functions of core/10_dsp_voice_params.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41350[];
extern unsigned char ram_4518f;
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
extern void EFF_RoutingInit(int, int, int);

/* cc900-module: AlgoFlag_Write AlgoFlag_Write_Bit3 EFF_RoutingInit */
void Voice_Part_ResetSlotRouting(unsigned char part)
{
    unsigned int k;
    if (ram_4518f != 0xf5) {
        for (k = 0; k < 4; k++) {
            (*(unsigned char **)((struct partrec *)(ram_41350 + (part) * 0x11f))->partial[k])[6] &= 7;
            (*(unsigned char **)((struct partrec *)(ram_41350 + (part) * 0x11f))->partial[k])[6] |= 0x20;
        }
        AlgoFlag_Write_Bit3(part, 0, 0);
        AlgoFlag_Write(part, 0, 0);
    } else {
        for (k = 0; k < 4; k++)
            (*(unsigned char **)((struct partrec *)(ram_41350 + (part) * 0x11f))->partial[k])[6] &= 7;
        AlgoFlag_Write_Bit3(part, 0, 0);
        AlgoFlag_Write(part, 0, 0);
    }
    for (k = 0; k < 4; k++)
        EFF_RoutingInit(part, (unsigned char)k, 0);
}
