/* Functions of core/10_dsp_voice_params.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_4131e[];
extern unsigned char ram_41322[];
extern unsigned char ram_41326[];
extern unsigned char Voice_SecondaryParam_Curve[];
#define PART_PRESENT(p) (((unsigned int *)(ram_4131e + (p) * 0x11f))[0])
#define PART_W72(p)     (((unsigned int *)(ram_41326 + (p) * 0x11f))[0])
#define PART_PATCH(p)   (((unsigned char **)(ram_41322 + (p) * 0x11f))[0])

/* cc900-name: Algo_PanTrim_From_PartFlags=Algo_SubTable_PanTrim_From_PartFlags */
char Algo_PanTrim_From_PartFlags(unsigned char part, unsigned char side)
{
    char r;
    if ((unsigned long)PART_PRESENT(part) & 0xc000) {
        switch (side) {
        case 0: r = -4; break;
        case 1: r = -16; break;
        default: r = 0; break;
        }
    } else r = 0;
    return r;
}

unsigned char Voice_SecondaryParam_Fetch(unsigned char part)
{
    unsigned char r;
    if ((unsigned long)PART_W72(part) & 0x8000) {
        if ((PART_PATCH(part)[93] & 0xf) == 9) r = Voice_SecondaryParam_Curve[PART_PATCH(part)[94]];
        else r = 0xff;
    } else r = 0xff;
    return r;
}
