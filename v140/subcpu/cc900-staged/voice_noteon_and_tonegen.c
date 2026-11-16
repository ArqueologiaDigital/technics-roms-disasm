/* Functions of core/08_voice_noteon_and_tonegen.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n)
{
    unsigned int i;
    for (i = 0; i < n; i++) *d++ = *s++;
}

extern unsigned char ram_4131c[];
extern unsigned char ram_41322[];
extern unsigned char ram_41326[];
extern void Voice_DSP_OutputConfig2(unsigned int part, unsigned int slot);
#define PART_FLAGS(p)   (*(unsigned int *)(ram_4131c + (p) * 0x11f))
#define PART_W72(p)     (*(unsigned int *)(ram_41326 + (p) * 0x11f))
#define PART_PATCH(p)   (*(unsigned char **)(ram_41322 + (p) * 0x11f))

int DSP_EffectStateQuery(unsigned char part, unsigned char *out)
{
    if (PART_FLAGS(part) & 1) *out = 1;
    else *out = 0;
    return 1;
}

void Voice_DSPOut_Second_B(unsigned char part)
{
    switch (PART_PATCH(part)[93] & 0xf) {
    case 4:
    case 5:
        Voice_DSP_OutputConfig2(part, 1);
        break;
    case 7:
        if (PART_W72(part) & 0x4000) Voice_DSP_OutputConfig2(part, 1);
        break;
    }
}
