/* Functions of core/10_dsp_voice_params.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_4136e[];
extern unsigned char DSP_AlgoDescriptor_Records[];
struct algorec { unsigned char b[40]; };
unsigned int DSP_AlgoType_Dispatch3(unsigned char part, unsigned char ch, unsigned char e);

/* cc900-data: DSP_AlgoType_Dispatch3 1 = DSP_AlgoType_Dispatch3_CaseOffsets */
unsigned int DSP_AlgoType_Dispatch3(unsigned char part, unsigned char ch, unsigned char e)
{
    unsigned int r;
    unsigned char t;
    r = 0;
    t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
    switch (t) {
    case 0: case 1: case 2: case 3: case 4: case 5: case 7:
        if (e == 0) {
            if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)ch * 5 + 0x13] & 0x80) {
                if ((*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0x40) {
                    if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)ch * 5 + 0x13] & 8)
                        r = 0xc0;
                    else
                        r = 0x40;
                } else
                    r = 0x40;
            }
        } else {
            if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)ch * 5 + 0x13] & 0x40) {
                if ((*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0x40) {
                    if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)ch * 5 + 0x13] & 4)
                        r = 0xc0;
                    else
                        r = 0x40;
                } else
                    r = 0x40;
            }
        }
        break;
    case 10: case 11:
        if (e == 0) {
            if ((*(unsigned char **)&ram_4136e[(part) * 0x11f])[94] != 0) {
                if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)ch * 5 + 0x13] & 8)
                    r = 0xc0;
                else
                    r = 0x40;
            }
        }
        break;
    }
    return r;
}
