/* Functions of core/14_dsp_control_routines.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char __tiny ram_1c;
extern unsigned char __tiny ram_38;
extern unsigned char __near ram_4a48;
extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern void DSP_Nop();
extern void DSP_WriteParamWord(long v, int chip);
extern void ToneGen_Poll_Init(void);
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);

/* cc900-module: DSP_Nop DSP_WriteParamCmd30 DSP_WriteParamWord ToneGen_Poll_Init */
void DSP_Deselect_Chip(int chip)
{
    DSP_Nop(chip);
    switch (chip) {
    case 0:
        ram_1c |= 0x20;
        break;
    case 1:
        ram_38 |= 0x40;
        break;
    }
}

long DSP_ParamInterp_MultiStep(unsigned char **pp, long b, int *tbl, int unused, unsigned int n)
{
    long junk;
    long v0;
    long v1;
    unsigned char *p;
    int k;
    long r;

    p = *pp;
    switch (*p++ & 0xf0) {
    default:
        k = (int)b;
        break;
    case 0x10:
        k = tbl[n - 1];
        break;
    case 0x20:
        k = tbl[n - 2];
        break;
    }
    switch (k) {
    default:
        p = DSP_StreamDecode_3ByteWord(p, &v0);
        p = DSP_StreamDecode_3ByteWord(p, &v1);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        break;
    case 1:
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &v0);
        p = DSP_StreamDecode_3ByteWord(p, &v1);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        break;
    case 2:
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &v0);
        p = DSP_StreamDecode_3ByteWord(p, &v1);
        break;
    }
    r = (v0 >> 8) + ((v1 - v0) >> 8) * b / 0x63;
    *pp = p;
    return r;
}

void DSP_Select_Chip(int chip)
{
    DSP_Nop(chip);
    switch (chip) {
    case 0:
        ram_1c &= ~0x20;
        break;
    case 1:
        ram_38 &= ~0x40;
        break;
    }
}

long DSP_VolScale_B(unsigned char **pp, long x)
{
    unsigned char *p;
    long r;

    p = *pp;
    switch (*p++) {
    case 0:
        if (x <= 0x32)
            r = (x << 23) / 0x6baa8;
        else if (x <= 0x4b)
            r = ((x - 0x19) << 23) / 0x35d54;
        else if (x <= 0x58)
            r = ((x * 4 - 0xfa) << 23) / 0x35d54;
        else
            r = ((x * 9 - 0x2b2) << 23) / 0x35d54;
        break;
    case 1:
        if (x <= 0xa)
            r = (x << 23) / 0xac44;
        else if (x <= 0x13)
            r = ((x * 10 - 0x5a) << 23) / 0xac44;
        else if (x <= 0x40)
            r = ((x * 20 - 0x118) << 15) / 0xac44 << 8;
        else if (x <= 0x57)
            r = ((x * 0x190 - 0x60e0) << 15) / 0xac44 << 8;
        else
            r = ((x * 0x320 - 0xe8d0) << 15) / 0xac44 << 8;
        break;
    case 2:
        if (x <= 0x32)
            r = (x << 23) / (0xfa0 - x * 2);
        else if (x <= 0x4b)
            r = ((x - 0x19) << 23) / (0x79c - (x * 2 - 0x66));
        else if (x <= 0x58)
            r = ((x * 4 - 0xfa) << 23) / (0x764 - (x * 8 - 0x260));
        else
            r = ((x * 9 - 0x2b2) << 23) / (0x6f2 - (x * 18 - 0x642));
        break;
    }
    *pp = p;
    return r;
}

long DSP_VolumeParam_Scale(unsigned char **pp, long x)
{
    unsigned char *p;
    long r;

    p = *pp;
    switch (*p++) {
    case 0:
        if (x <= 0x32)
            r = (x << 23) / 0x6baa8;
        else if (x <= 0x4b)
            r = ((x - 0x19) << 23) / 0x35d54;
        else if (x <= 0x58)
            r = ((x * 4 - 0xfa) << 23) / 0x35d54;
        else
            r = ((x * 9 - 0x2b2) << 23) / 0x35d54;
        break;
    case 1:
        if (x <= 0xa)
            r = (x << 23) / 0xac44;
        else if (x <= 0x13)
            r = ((x * 10 - 0x5a) << 23) / 0xac44;
        else if (x <= 0x40)
            r = ((x * 20 - 0x118) << 15) / 0xac44 << 8;
        else if (x <= 0x57)
            r = ((x * 0x190 - 0x60e0) << 15) / 0xac44 << 8;
        else
            r = ((x * 0x320 - 0xe8d0) << 15) / 0xac44 << 8;
        break;
    case 2:
        if (x <= 0x32)
            r = (x << 23) / (0xfa0 - x * 2);
        else if (x <= 0x4b)
            r = ((x - 0x19) << 23) / (0x79c - (x * 2 - 0x66));
        else if (x <= 0x58)
            r = ((x * 4 - 0xfa) << 23) / (0x764 - (x * 8 - 0x260));
        else
            r = ((x * 9 - 0x2b2) << 23) / (0x6f2 - (x * 18 - 0x642));
        break;
    }
    *pp = p;
    return r;
}

void DSP_WriteParamCmd30(int chip, unsigned int b, long v)
{
    DSP_DispatchCommand(0x30, chip);
    DSP_DispatchData(0, chip);
    DSP_DispatchData((unsigned char)b, chip);
    DSP_WriteParamWord(v, chip);
}

void ToneGen_Init(void)
{
    ram_4a48 = 6;
    ToneGen_Poll_Init();
}
