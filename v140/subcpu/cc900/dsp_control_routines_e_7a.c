/* Functions of core/14_dsp_control_routines.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct bcfg { int a; int b; int c; int d; long e; };
extern unsigned char EFF_SlotToChip_Table[];
extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern void DSP_NopReturn();
extern void DSP_WriteParamCmd30(int chip, unsigned int b, long v);
extern unsigned char *DSP_TableWalk_SearchWithState(unsigned char *p, int n, void *st, unsigned char **out);
extern unsigned char *DSP_PerParameterTranslator(int chip, unsigned int slot, int v, unsigned char *p, void *desc,
                                                 unsigned char *rec, struct bcfg *work, int *status);

/* cc900-module: DSP_NopReturn DSP_PerParameterTranslator DSP_TableWalk_SearchWithState DSP_WriteParamCmd30 */
long DSP_PanCurve_PiecewiseLin(unsigned char **pp, long x)
{
    long r;

    if (x <= 0x14)
        r = ((x * 2 + 10) * 0xac44) / 0x3e8;
    else if (x <= 0x1e)
        r = ((x * 5 - 50) * 0xac44) / 0x3e8;
    else if (x <= 0x46)
        r = ((x * 10 - 200) * 0xac44) / 0x3e8;
    else if (x <= 0x50)
        r = ((x * 50 - 3000) * 0xac44) / 0x3e8;
    else
        r = ((x * 100 - 7000) * 0xac44) / 0x3e8;
    return r;
}

void DSP_ParameterWriteEngine(unsigned int slot, struct bcfg *work, void *desc, unsigned char *vals, int v,
                              unsigned char *rec)
{
    int status;
    unsigned char *end;
    int chip;

    chip = EFF_SlotToChip_Table[slot];
    status = 0;
    vals = DSP_TableWalk_SearchWithState(vals, v, &status, &end);
    if (status != 0) {
        DSP_NopReturn(status);
        return;
    }
    while (vals < end) {
        if (chip == 0) {
            status = DSP_DispatchCommand(1, chip);
            status = DSP_DispatchData(1, chip);
            status = DSP_DispatchData(0x60, chip);
        }
        vals = DSP_PerParameterTranslator(chip, slot, v, vals, desc, rec, work, &status);
        if (status != 0) {
            DSP_NopReturn(status);
            return;
        }
        if (chip == 0)
            status = DSP_DispatchCommand(3, chip);
    }
}

void DSP_WriteFreqParam(unsigned int a, long v, int chip, unsigned int base)
{
    switch (chip) {
    default:
            DSP_DispatchData(0, chip);
            DSP_DispatchData(0, chip);
            DSP_DispatchData((unsigned char)((((base + a) >> 4) & 0xf) + 0x10), chip);
            DSP_DispatchData((unsigned char)(((base + a) << 4) & 0xf0), chip);
            DSP_DispatchData(0, chip);
            DSP_DispatchData(0xa, chip);
            DSP_DispatchData((unsigned char)((v >> 17) & 0x7f), chip);
            DSP_DispatchData((unsigned char)((v >> 9) & 0xff), chip);
            DSP_DispatchData((unsigned char)((v >> 1) & 0xff), chip);
            DSP_DispatchData((unsigned char)(((v << 7) & 0x80) + 0x15), chip);
        break;
    case 1:
            DSP_WriteParamCmd30(chip, a, v);
        break;
    }
}

void DSP_WriteFreqParam_AlgoType(unsigned int a, long v, int chip, unsigned int base)
{
    switch (chip) {
    default:
            DSP_DispatchData(0, chip);
            DSP_DispatchData(0, chip);
            DSP_DispatchData((unsigned char)((((base + a) >> 4) & 0xf) + 0x10), chip);
            DSP_DispatchData((unsigned char)(((base + a) << 4) & 0xf0), chip);
            DSP_DispatchData(0, chip);
            DSP_DispatchData(0xa, chip);
            DSP_DispatchData((unsigned char)((v >> 17) & 0x7f), chip);
            DSP_DispatchData((unsigned char)((v >> 9) & 0xff), chip);
            DSP_DispatchData((unsigned char)((v >> 1) & 0xff), chip);
            DSP_DispatchData((unsigned char)(((v << 7) & 0x80) + 0x15), chip);
        break;
    case 1:
            DSP_WriteParamCmd30(chip, a, v);
        break;
    }
}
