/* Functions of core/10_dsp_voice_params.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41352[];
extern unsigned char ram_41356[];
extern unsigned char ram_4135a[];
extern unsigned char ram_413b3[];
extern unsigned char ram_413b4[];
extern unsigned char ram_413b5[];
extern int DSP_AlgoType_Dispatch1(int, int);
extern int DSP_AlgoType_Dispatch2(int, int);
extern int DSP_ChanFreq_WritePacket1(int);
extern int DSP_ChanFreq_WritePacket2(int);
void AlgoType_StateWrite(unsigned char part, unsigned char c);

/* cc900-module: DSP_AlgoType_Dispatch1 DSP_AlgoType_Dispatch2 DSP_ChanFreq_WritePacket1 DSP_ChanFreq_WritePacket2 */
void AlgoType_StateWrite(unsigned char part, unsigned char c)
{
    unsigned char t;
    t = (*(unsigned char **)(ram_41356 + (part) * 0x11f))[93] & 0xf;
    if (t == 7) {
        (*(unsigned int *)&(ram_4135a)[(part) * 0x11f]) |= 0x8000;
        if (c == 0) {
            if ((*(unsigned int *)&(ram_4135a)[(part) * 0x11f]) & 0x4000) {
                ram_413b3[part * 0x11f] = 0x0f;
                ram_413b4[part * 0x11f] = 0x4f;
                ram_413b5[part * 0x11f] = 0x96;
            } else {
                ram_413b3[part * 0x11f] = 1;
                ram_413b4[part * 0x11f] = 1;
                ram_413b5[part * 0x11f] = 1;
            }
            DSP_AlgoType_Dispatch1(part, 0);
            DSP_AlgoType_Dispatch2(part, 0);
            DSP_AlgoType_Dispatch1(part, 1);
            DSP_AlgoType_Dispatch2(part, 1);
            DSP_ChanFreq_WritePacket1(part);
            DSP_ChanFreq_WritePacket2(part);
        } else {
            if ((*(unsigned int *)&(ram_4135a)[(part) * 0x11f]) & 0x4000) {
                ram_413b3[part * 0x11f] &= 0x05;
                ram_413b3[part * 0x11f] |= 0x02;
            } else {
                ram_413b3[part * 0x11f] &= 0x05;
            }
        }
        (*(unsigned int *)&(ram_41352)[(part) * 0x11f]) &= 0xfdff;
    } else {
        if ((*(unsigned int *)&(ram_4135a)[(part) * 0x11f]) & 0x4000) {
            (*(unsigned int *)&(ram_4135a)[(part) * 0x11f]) |= 0x8000;
            DSP_AlgoType_Dispatch1(part, 0);
            DSP_AlgoType_Dispatch2(part, 0);
            DSP_AlgoType_Dispatch1(part, 1);
            DSP_AlgoType_Dispatch2(part, 1);
            DSP_ChanFreq_WritePacket1(part);
            DSP_ChanFreq_WritePacket2(part);
            if (t == 0x0a)
                (*(unsigned int *)&(ram_41352)[(part) * 0x11f]) |= 0x0200;
            else
                (*(unsigned int *)&(ram_41352)[(part) * 0x11f]) &= 0xfdff;
        } else {
            (*(unsigned int *)&(ram_4135a)[(part) * 0x11f]) &= 0x7fff;
            (*(unsigned int *)&(ram_41352)[(part) * 0x11f]) &= 0xfdff;
        }
        ram_413b3[part * 0x11f] = 0;
        ram_413b4[part * 0x11f] = 0;
        ram_413b5[part * 0x11f] = 0;
    }
}
