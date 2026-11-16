/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
   Held back from subcpu/cc900/ (2026-11-16): they call a callee by a short cc900-name (ToneGen_Write_ExtParam_05C0_Stb ...), which the build's call lookup does not map yet.
*/

/* cc900-name: ToneGen_WriteExtParam_1C0_Sgl=ToneGen_WriteExtParam_1C0_Single */
/* cc900-name: ToneGen_Write_ExtParam_05C0_Stb=ToneGen_Write_ExtParam_05C0_Strobe */

extern unsigned int ram_45180[];
extern unsigned int ram_451ac;
extern unsigned int ram_451ae;
extern unsigned int ram_451b0;
extern unsigned int ram_451b2;
extern unsigned int ram_451b4;
extern unsigned int ram_451b6;
extern int ram_451bc;
extern int ram_451be;
extern int ram_451c0;
extern int ram_451c2;
extern int DSP_AlgoType_Dispatch1(int, int);
extern int DSP_AlgoType_Dispatch2(int, int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_WriteExtParams_56(int, unsigned int *);
extern void ToneGen_WriteExtParams_56b(int, unsigned int *);
struct lvl70 { char pad[70]; unsigned char v; };







extern unsigned int ram_412f7;
extern unsigned char ram_41328[];
extern unsigned char ram_4132c[];
extern int ram_451b8;
extern int ram_451ba;
extern unsigned int Voice_CC_VolumeCurve[];
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern int DSP_ChanFreq_WritePacket1(int);
extern int DSP_ChanFreq_WritePacket2(int);
extern void ToneGen_WriteExtParams_15_Alt(int, unsigned int *);
extern void ToneGen_WriteExtParam_1C0_Sgl(int, unsigned int *);
extern void ToneGen_WriteReg0640(int, unsigned int *);
extern void ToneGen_WriteExtParam_600(int, unsigned int *);
extern void ToneGen_Write_ExtParam_05C0_Stb(int, unsigned int *);
extern void ToneGen_WriteExtParams_56_Alt(int, unsigned int *);









void Voice_DSP_OutputConfig2(unsigned char ch, unsigned char mode)
{
    unsigned int *list;
    unsigned int i;
    if (mode == 0) {
        ram_451be = DSP_AlgoType_Dispatch2(ch, mode);
        list = Voice_BuildOutputList(ch, (unsigned char)((unsigned int)mode | 12), 0);
        for (i = 0; (list[i] & 0xff) < 0x80; i++)
            ToneGen_Write_ExtParam_05C0_Stb(list[i] & 0xff, ram_45180);
    } else {
        ram_451bc = DSP_AlgoType_Dispatch2(ch, mode);
        list = Voice_BuildOutputList(ch, (unsigned char)((unsigned int)mode | 12), 0);
        for (i = 0; (list[i] & 0xff) < 0x80; i++)
            ToneGen_WriteExtParams_56_Alt(list[i] & 0xff, ram_45180);
    }
}

void Voice_DSP_SimpleCopy(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_451b8 = DSP_ChanFreq_WritePacket1(ch);
    list = Voice_BuildOutputList(ch, 16, 0);
    for (i = 0; (list[i] & 0xff) < 0x40; i++)
        ToneGen_WriteExtParam_1C0_Sgl(list[i] & 0xff, ram_45180);
}






