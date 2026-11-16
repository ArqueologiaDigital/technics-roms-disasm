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

extern unsigned char ram_41368[];
extern unsigned char ram_4136c[];
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char ram_45216;
extern unsigned char ram_45217;
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);
#define PART_FLAGS(p)   (*(unsigned int *)(ram_41368 + (p) * 0x11f))
#define PART_W72(p)     (*(unsigned int *)(ram_41372 + (p) * 0x11f))
#define PART_PATCH(p)   (*(unsigned char **)(ram_4136e + (p) * 0x11f))

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
    ram_45216 = PART_PATCH(part)[16];
    if ((PART_PATCH(part)[93] & 0xf) == 12) ram_45217 = PART_PATCH(part)[95];
    else ram_45217 = 0;
    return r;
}

void Voice_ActiveFlag_Set(unsigned char part)
{
    PART_FLAGS(part) &= ~3;
    PART_FLAGS(part) |= 4;
    ram_4136c[part * 0x11f] = 0;
}

unsigned char Voice_SecondaryParam_Epilogue(unsigned char part)
{
    unsigned char r = 0;
    if (PART_W72(part) & 0x8000L) r = PART_PATCH(part)[101];
    return r;
}

extern unsigned char ram_4136a[];
extern unsigned char ram_413d0[];
extern unsigned char ram_413d1[];
extern unsigned char ram_413d2[];
extern unsigned char ram_413d6[];
extern unsigned char ram_413fb[];
extern unsigned char ram_41420[];
extern unsigned char ram_41445[];
extern unsigned char ram_451a4;
extern char ram_451a7;
extern char ram_451a8;
extern char ram_451a9;
struct partial { unsigned char pad[54]; unsigned char f54; unsigned char pad2[22]; unsigned char a77[4]; };
#define PART_PRESENT(p) (*(unsigned int *)(ram_4136a + (p) * 0x11f))
#define PART_PTR(a, p)  (*(unsigned char **)((a) + (p) * 0x11f))

void DSP_SlotParam_Write_Slot0(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_451a4 == part) ram_413d0[part * 0x11f] = ram_451a7 << 1;
    else ram_413d0[part * 0x11f] = 0;
}

void DSP_SlotParam_Write_Slot1(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_451a4 == part) ram_413d1[part * 0x11f] = ram_451a8 << 1;
    else ram_413d1[part * 0x11f] = 0;
}

void DSP_SlotParam_Write_Slot2(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_451a4 == part) ram_413d2[part * 0x11f] = ram_451a9 << 1;
    else ram_413d2[part * 0x11f] = 0;
}

unsigned int Partial_GetBaseKey(unsigned char part, unsigned char partial)
{
    switch (partial) {
    case 0:
        if (PART_PRESENT(part) & 0x4000) return PART_PTR(ram_413fb, part)[1];
        return PART_PTR(ram_413d6, part)[1];
    case 1:
        if (PART_PRESENT(part) & 0x8000L) return PART_PTR(ram_413d6, part)[1];
        return PART_PTR(ram_413fb, part)[1];
    case 2:
        return PART_PTR(ram_41420, part)[1];
    case 3:
        return PART_PTR(ram_41445, part)[1];
    }
}

extern unsigned int ram_41343;
extern unsigned char ram_41383[];
extern unsigned char ram_41384[];
extern unsigned char ram_41385[];
extern unsigned char ram_41387[];
extern unsigned char ram_41388[];
extern unsigned char ram_413d3[];
extern unsigned char ram_413d4[];
extern char ram_451ab;
extern char ram_451ac;
struct slotrt { unsigned char pad[26]; unsigned int w[256]; };

void DSP_SlotParam_Write_Slot3(unsigned char part)
{
    if ((*(unsigned int *)(ram_41368 + part * 0x11f) & 1) && ram_451a4 == part) ram_413d3[part * 0x11f] = ram_451ab << 2;
    else ram_413d3[part * 0x11f] = 0;
}

void DSP_SlotParam_Write_Slot4(unsigned char part)
{
    if ((*(unsigned int *)(ram_41368 + part * 0x11f) & 1) && ram_451a4 == part) ram_413d4[part * 0x11f] = ram_451ac << 2;
    else ram_413d4[part * 0x11f] = 0;
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
    if (ram_41343 & 1) return;
    *(unsigned int *)(ram_41385 + part * 0x11f) = 0;
    ram_41387[part * 0x11f] = 0;
    ram_41388[part * 0x11f] = 0;
    ram_41383[part * 0x11f] = 0x40;
    ram_41384[part * 0x11f] = 0x40;
    for (i = 0; i < 4; i++) {
        for (j = 0; j < 3; j++) {
            ((unsigned char *)((unsigned long)(ram_41368 + part * 0x11f) + (((unsigned long)j << 4) + ((unsigned long)i << 2))))[41] = 0;
            ((unsigned char *)((unsigned long)(ram_41368 + part * 0x11f) + (((unsigned long)j << 4) + ((unsigned long)i << 2))))[42] = 0;
        }
    }
}
