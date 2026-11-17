/* Functions of core/13_audio_process_dsp_and_effects.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct slot { unsigned int type; unsigned int a[1]; int param[17]; unsigned int idx; int q[1]; int r42[6]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };
struct e50 { unsigned int f0; char pad[48]; };
extern struct fxflags __near EFF_SlotActiveFlags;
extern struct e50 __near ram_4940[];
extern unsigned char __near ram_4944[];
extern unsigned int __near DSP_AlgoChangedFlag;
extern unsigned char EFF_VolumeReduction_Steps[];
void EFF_VolumeUpdate_WithDebug(unsigned int slot, unsigned int b, unsigned int idx, unsigned long p);
void EFF_SlotActive_UpdateFlags(unsigned long p);
void EFF_VolumeLoop(unsigned long p);

void EFF_SlotActive_UpdateFlags(unsigned long p)
{
    unsigned int i;
    unsigned int found;
    found = 0;
    if (DSP_AlgoChangedFlag == 1) {
        for (i = 0; i < 5; i++)
            EFF_SlotActiveFlags.active[i] = 1;
    } else {
        for (i = 0; i < 5; i++) {
            switch (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type) {
            case 0x46: case 0x45: case 0x34: case 0x33:
                found = 1;
            }
            if (ram_4940[i].f0 == 1 || (((struct cfg *)p)->f0 == 1 && EFF_SlotActiveFlags.r[i].g[4] == 1) || (EFF_SlotActiveFlags.r[i].g[4] == 1 && found == 1)) {
                EFF_SlotActiveFlags.active[i] = 1;
                (*(unsigned int *)&(ram_4944)[(i) * 50 + ((((struct slot *)(p + ((unsigned long)i * 56 + 8)))->idx) << 1)]) = 1;
                EFF_SlotActiveFlags.r[i].g[1] = 1;
                EFF_SlotActiveFlags.r[i].g[2] = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
                if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->r42[3] != 0x63)
                    EFF_SlotActiveFlags.r[i].g[0] = 1;
            } else
                EFF_SlotActiveFlags.active[i] = 0;
        }
    }
}

void EFF_VolumeLoop(unsigned long p)
{
    unsigned int i;
    unsigned int d;
    for (i = 0; i < 5; i++) {
        if ((*(unsigned int *)&(ram_4944)[(i) * 50 + ((((struct slot *)(p + ((unsigned long)i * 56 + 8)))->idx) << 1)]) == 1) {
            d = ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->idx;
            if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type == 0x3f) {
                ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->param[0] = ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->param[0] - EFF_VolumeReduction_Steps[((struct slot *)(p + ((unsigned long)i * 56 + 8)))->param[1]];
                if (((struct slot *)(p + ((unsigned long)i * 56 + 8)))->param[0] < 0)
                    ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->param[0] = 0;
            }
            EFF_VolumeUpdate_WithDebug(i, ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->type, d, p);
        }
    }
}
