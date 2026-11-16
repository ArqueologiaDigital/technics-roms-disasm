/* Functions of core/13_audio_process_dsp_and_effects.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct slot { unsigned int type; unsigned int a[1]; int param[17]; int idx; int q[1]; int r42[6]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct e50 { unsigned int f0; char pad[48]; };
extern struct slot __near ram_4496[];
extern struct slot __near ram_45d2[];
extern struct e50 __near ram_4940[];

void DSP_Config_ClampLimits(unsigned long p)
{
    unsigned int i;

    if (((struct cfg *)p)->f6 > 1)
        ((struct cfg *)p)->f6 = 0;
    for (i = 0; i < 5; i++)
        if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type > 0x63)
            ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type = 0x63;
}

void DSP_SlotParam_DiffAndFlag(unsigned long p)
{
    unsigned int i;

    for (i = 0; i < 5; i++) {
        if (ram_45d2[i].type != ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type)
            ram_4940[i].f0 = 1;
        else
            ram_4940[i].f0 = 0;
    }
}

struct slot *EFF_GetSlotBuffer(unsigned int i)
{
    struct slot *r;

    switch (i) {
    case 0: case 1: case 2: case 3: case 4:
        r = (struct slot *)(unsigned long)&ram_4496[i];
        break;
    default:
        r = (struct slot *)0xffffffff;
        break;
    }
    return r;
}
