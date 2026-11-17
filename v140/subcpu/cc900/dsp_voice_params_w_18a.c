/* Functions of core/10_dsp_voice_params.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_4131c[];
extern unsigned char ram_41322[];
extern unsigned char ram_41326[];
extern unsigned char ram_4137b[];
extern unsigned char ram_4137d[];
extern unsigned char DSP_AlgoDescriptor_Records[];
extern unsigned char DSP_AlgoDescriptor_SelIdx[];
extern unsigned char DSP_AlgoDescriptor_FlagsAB[];
extern unsigned char DSP_AlgoDescriptor_ValueAB[];
extern unsigned char DSP_AlgoChannel_SelectorByte4[][6];
extern unsigned char DSP_AlgoChannel_SelectorByte5[][6];
extern unsigned char DSP_ChanFreq_Packet1_Curve[];
extern unsigned char DSP_ChanFreq_CurvePool[];
extern int EGEnv_ModeBits_Table[];
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
struct algorec { unsigned char b[40]; };
struct b5 { unsigned char f0; unsigned char f1; unsigned char f2; unsigned char f3; unsigned char f4; };
void AlgoFlag_Write(unsigned char part, unsigned char c, unsigned char e);
void AlgoFlag_Write_Bit3(unsigned char part, unsigned char c, unsigned char e);
unsigned char Algo_SubTable_DispatchB(unsigned char part, unsigned char k);
unsigned int DSP_ChanFreq_WritePacket1(unsigned char part);
unsigned int DSP_ChanFreq_WritePacket2(unsigned char part);
unsigned char Voice_SecondaryParam_Fetch2(unsigned char part);

/* cc900-data: Algo_SubTable_DispatchB 1 = Algo_SubTable_DispatchB_CaseOffsets */
void AlgoFlag_Write(unsigned char part, unsigned char c, unsigned char e)
{
    unsigned char *q;
    unsigned char *p;
    unsigned char w;
    unsigned char b;
    q = &((unsigned char *)((struct partrec *)(ram_4131c + (part) * 0x11f)))[(int)c * 16 + (int)e * 4];
    q += 39;
    p = (*(unsigned char **)&ram_41322[(part) * 0x11f]);
    *q &= 0xfc;
    if (q[3] != 0 && (q[1] & 0x55)) {
        *q |= 2;
    } else {
        for (w = 0; w < 4; w++) {
            switch (c) {
            case 0:
                b = (*(unsigned char **)((struct partrec *)(ram_4131c + (part) * 0x11f))->partial[w])[6];
                break;
            case 1:
                b = (*(unsigned char **)((struct partrec *)(ram_4131c + (part) * 0x11f))->partial[w])[38];
                break;
            case 2:
                b = (*(unsigned char **)((struct partrec *)(ram_4131c + (part) * 0x11f))->partial[w])[56];
                break;
            }
            if (b & 0x20) {
                if (((b & 0xc0) >> 6) == e)
                    *q |= 1;
            }
        }
    }
}

void AlgoFlag_Write_Bit3(unsigned char part, unsigned char c, unsigned char e)
{
    unsigned char *q;
    unsigned char *p;
    unsigned char w;
    unsigned char b;
    q = &((unsigned char *)((struct partrec *)(ram_4131c + (part) * 0x11f)))[(int)c * 16 + (int)e * 4];
    q += 39;
    p = (*(unsigned char **)&ram_41322[(part) * 0x11f]);
    *q &= 0xf3;
    if (q[2] != 0 && (q[1] & 0x55)) {
        *q |= 8;
    } else {
        for (w = 0; w < 4; w++) {
            switch (c) {
            case 0:
                b = (*(unsigned char **)((struct partrec *)(ram_4131c + (part) * 0x11f))->partial[w])[6];
                break;
            case 1:
                b = (*(unsigned char **)((struct partrec *)(ram_4131c + (part) * 0x11f))->partial[w])[38];
                break;
            case 2:
                b = (*(unsigned char **)((struct partrec *)(ram_4131c + (part) * 0x11f))->partial[w])[56];
                break;
            }
            if (b & 0x20) {
                if (((b & 0xc0) >> 6) == e)
                    *q |= 4;
            }
        }
    }
}

unsigned char Algo_SubTable_DispatchB(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;
    t = (*(unsigned char **)&ram_41322[(part) * 0x11f])[93] & 0xf;
    r = ((struct b5 *)((unsigned long)&((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)(k) * 5 + 0x13]))->f2;
    switch (t) {
    case 0: case 1: case 2: case 3:
        if (k == 1) {
            part = (*(unsigned char **)&ram_41322[(part) * 0x11f])[96];
            r = part + part;
        }
        break;
    case 4: case 5:
        if (k == 1) {
            part = (*(unsigned char **)&ram_41322[(part) * 0x11f])[98];
            r = part + part;
        }
        break;
    case 8:
        if (k == 1) {
            part = (*(unsigned char **)&ram_41322[(part) * 0x11f])[95];
            r = part + part;
        }
        break;
    }
    return r;
}

unsigned int DSP_ChanFreq_WritePacket1(unsigned char part)
{
    unsigned int r;
    unsigned char t;
    unsigned char sel;
    t = (*(unsigned char **)&ram_41322[(part) * 0x11f])[93] & 0xf;
    switch (t) {
    case 6:
        sel = DSP_AlgoChannel_SelectorByte4[t][0];
        r = ((unsigned int *)(DSP_ChanFreq_Packet1_Curve + (int)sel * 0x66))[(*(unsigned char **)&ram_41322[(part) * 0x11f])[94]];
        r |= EGEnv_ModeBits_Table[(*(unsigned char **)&ram_41322[(part) * 0x11f])[96]];
        break;
    case 7:
        sel = DSP_AlgoChannel_SelectorByte4[t][0];
        r = ((unsigned int *)(DSP_ChanFreq_Packet1_Curve + (int)sel * 0x66))[DSP_AlgoDescriptor_SelIdx[(int)t * 0x27]];
        break;
    default:
        r = 0;
    }
    *(unsigned int *)(ram_4137b + part * 0x11f) = r;
    return r;
}

unsigned int DSP_ChanFreq_WritePacket2(unsigned char part)
{
    unsigned int r;
    unsigned char sel;
    unsigned char t;
    t = (*(unsigned char **)&ram_41322[(part) * 0x11f])[93] & 0xf;
    switch (t) {
    case 6:
    case 7:
        sel = DSP_AlgoChannel_SelectorByte5[t][0];
        r = ((unsigned int *)(DSP_ChanFreq_CurvePool + (int)sel * 0x66))[(*(unsigned char **)&ram_41322[(part) * 0x11f])[95]];
        break;
    default:
        r = 0;
    }
    *(unsigned int *)(ram_4137d + part * 0x11f) = r;
    return r;
}

unsigned char Voice_SecondaryParam_Fetch2(unsigned char part)
{
    unsigned char r;
    unsigned char t;
    r = 0;
    if (!((unsigned long)*(unsigned int *)&ram_41326[part * 0x11f] & 0x8000))
        return r;
    t = (*(unsigned char **)&ram_41322[(part) * 0x11f])[93] & 0xf;
    r = t;
    switch (t) {
    case 0x0a: case 0x0b:
        if (DSP_AlgoDescriptor_FlagsAB[(int)r * 0x27] & 0x80)
            r = DSP_AlgoDescriptor_ValueAB[(int)r * 0x27];
        else
            r = (*(unsigned char **)&ram_41322[(part) * 0x11f])[100];
        break;
    default:
        r = (*(unsigned char **)&ram_41322[(part) * 0x11f])[100];
        break;
    }
    return r;
}
