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

extern unsigned char ram_4131c[];
extern unsigned char ram_41320[];
extern unsigned char ram_41322[];
extern unsigned char ram_41326[];
extern unsigned char ram_451ca;
extern unsigned char ram_451cb;
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);
#define PART_FLAGS(p)   (*(unsigned int *)(ram_4131c + (p) * 0x11f))
#define PART_W72(p)     (*(unsigned int *)(ram_41326 + (p) * 0x11f))
#define PART_PATCH(p)   (*(unsigned char **)(ram_41322 + (p) * 0x11f))

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
    ram_451ca = PART_PATCH(part)[16];
    if ((PART_PATCH(part)[93] & 0xf) == 12) ram_451cb = PART_PATCH(part)[95];
    else ram_451cb = 0;
    return r;
}

void Voice_ActiveFlag_Set(unsigned char part)
{
    PART_FLAGS(part) &= ~3;
    PART_FLAGS(part) |= 4;
    ram_41320[part * 0x11f] = 0;
}

unsigned char Voice_SecondaryParam_Epilogue(unsigned char part)
{
    unsigned char r = 0;
    if (PART_W72(part) & 0x8000L) r = PART_PATCH(part)[101];
    return r;
}

extern unsigned char ram_4131e[];
extern unsigned char ram_41384[];
extern unsigned char ram_41385[];
extern unsigned char ram_41386[];
extern unsigned char ram_4138a[];
extern unsigned char ram_413af[];
extern unsigned char ram_413d4[];
extern unsigned char ram_413f9[];
extern unsigned char ram_45158;
extern char ram_4515b;
extern char ram_4515c;
extern char ram_4515d;
struct partial { unsigned char pad[54]; unsigned char f54; unsigned char pad2[22]; unsigned char a77[4]; };
#define PART_PRESENT(p) (*(unsigned int *)(ram_4131e + (p) * 0x11f))
#define PART_PTR(a, p)  (*(unsigned char **)((a) + (p) * 0x11f))

void DSP_SlotParam_Write_Slot0(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_45158 == part) ram_41384[part * 0x11f] = ram_4515b << 1;
    else ram_41384[part * 0x11f] = 0;
}

void DSP_SlotParam_Write_Slot1(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_45158 == part) ram_41385[part * 0x11f] = ram_4515c << 1;
    else ram_41385[part * 0x11f] = 0;
}

void DSP_SlotParam_Write_Slot2(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_45158 == part) ram_41386[part * 0x11f] = ram_4515d << 1;
    else ram_41386[part * 0x11f] = 0;
}

unsigned int Partial_GetBaseKey(unsigned char part, unsigned char partial)
{
    switch (partial) {
    case 0:
        if (PART_PRESENT(part) & 0x4000) return PART_PTR(ram_413af, part)[1];
        return PART_PTR(ram_4138a, part)[1];
    case 1:
        if (PART_PRESENT(part) & 0x8000L) return PART_PTR(ram_4138a, part)[1];
        return PART_PTR(ram_413af, part)[1];
    case 2:
        return PART_PTR(ram_413d4, part)[1];
    case 3:
        return PART_PTR(ram_413f9, part)[1];
    }
}

extern unsigned int ram_412f7;
extern unsigned char ram_41337[];
extern unsigned char ram_41338[];
extern unsigned char ram_41339[];
extern unsigned char ram_4133b[];
extern unsigned char ram_4133c[];
extern unsigned char ram_41387[];
extern unsigned char ram_41388[];
extern char ram_4515f;
extern char ram_45160;
struct slotrt { unsigned char pad[26]; unsigned int w[256]; };

void DSP_SlotParam_Write_Slot3(unsigned char part)
{
    if ((*(unsigned int *)(ram_4131c + part * 0x11f) & 1) && ram_45158 == part) ram_41387[part * 0x11f] = ram_4515f << 2;
    else ram_41387[part * 0x11f] = 0;
}

void DSP_SlotParam_Write_Slot4(unsigned char part)
{
    if ((*(unsigned int *)(ram_4131c + part * 0x11f) & 1) && ram_45158 == part) ram_41388[part * 0x11f] = ram_45160 << 2;
    else ram_41388[part * 0x11f] = 0;
}

void SlotRouting_Chan1(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f)
{
    if ((f & 0x20) && ((f & 0xc0) >> 6) == ch) {
        if (f & 0x10) p->w[slot] = ch | 0xc000;
        else p->w[slot] = ch | 0x4000;
    }
}

void SlotRouting_Chan3(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f)
{
    if ((f & 0x20) && ((f & 0xc0) >> 6) == ch) {
        if (f & 0x10) p->w[slot] = ch | 0x3300;
        else p->w[slot] = ch | 0x1100;
    }
}

void SlotRouting_WriteSingle(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f)
{
    if ((f & 0x20) && ((f & 0xc0) >> 6) == ch) {
        if (f & 0x10) p->w[slot] = (unsigned int)ch | 0xc0;
        else p->w[slot] = (unsigned int)ch | 0x40;
    }
}

void Voice_NoteState_Clear(unsigned char part)
{
    unsigned int i;
    unsigned int j;
    if (ram_412f7 & 1) return;
    *(unsigned int *)(ram_41339 + part * 0x11f) = 0;
    ram_4133b[part * 0x11f] = 0;
    ram_4133c[part * 0x11f] = 0;
    ram_41337[part * 0x11f] = 0x40;
    ram_41338[part * 0x11f] = 0x40;
    for (i = 0; i < 4; i++) {
        for (j = 0; j < 3; j++) {
            ((unsigned char *)((unsigned long)(ram_4131c + part * 0x11f) + (((unsigned long)j << 4) + ((unsigned long)i << 2))))[41] = 0;
            ((unsigned char *)((unsigned long)(ram_4131c + part * 0x11f) + (((unsigned long)j << 4) + ((unsigned long)i << 2))))[42] = 0;
        }
    }
}
