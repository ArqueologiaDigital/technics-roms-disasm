/* Functions of core/10_dsp_voice_params.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

int SignedClamp_Zero(int a)
{
    if (a > 0x7f) a = 0x7f;
    else if (a < 0) a = 0;
    return a;
}

extern unsigned char ram_41350[];
extern unsigned char ram_41354[];
extern unsigned char ram_41356[];
extern unsigned char ram_4135a[];
extern unsigned char ram_451fe;
extern unsigned char ram_451ff;
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);
#define PART_FLAGS(p)   (*(unsigned int *)(ram_41350 + (p) * 0x11f))
#define PART_W72(p)     (*(unsigned int *)(ram_4135a + (p) * 0x11f))
#define PART_PATCH(p)   (*(unsigned char **)(ram_41356 + (p) * 0x11f))

unsigned int AlgoType_AB_Checker(unsigned char part)
{
    unsigned int r = 0;
    switch (PART_PATCH(part)[93] & 0xf) {
    case 10:
    case 11:
        r = PART_PATCH(part)[95] & 0x3f;
    }
    return r;
}

void DSP_ParamWrite_BlockCopy(unsigned int n, unsigned char *s, unsigned char *d)
{
    unsigned int i;
    for (i = 0; i < n; i++) *d++ = *s++;
}

int DSP_ReadVoiceParam11(unsigned int a, unsigned int b, unsigned char *out)
{
    *out = ToneDB_Find_ToneRecord(a, b)[17];
    return 1;
}

int DSP_ReadVoiceParam5D(unsigned int a, unsigned int b, unsigned char *out)
{
    *out = ToneDB_Find_ToneRecord(a, b)[93];
    return 1;
}

int DSP_SetCoeff_WriteParams(unsigned char part)
{
    int r = 2;
    ram_451fe = PART_PATCH(part)[16];
    if ((PART_PATCH(part)[93] & 0xf) == 12) ram_451ff = PART_PATCH(part)[95];
    else ram_451ff = 0;
    return r;
}

void Voice_ActiveFlag_Set(unsigned char part)
{
    PART_FLAGS(part) &= ~3;
    PART_FLAGS(part) |= 4;
    ram_41354[part * 0x11f] = 0;
}

unsigned char Voice_SecondaryParam_Epilogue(unsigned char part)
{
    unsigned char r = 0;
    if (PART_W72(part) & 0x8000L) r = PART_PATCH(part)[101];
    return r;
}
