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
extern char Str_EffVolume_Prefix[], Str_EffVolume_Suffix[];
extern void Debug_Print_String(char *);
extern void Debug_Print_Byte(unsigned int);
extern void DSP_WriteParameter(unsigned int, unsigned int, unsigned int, unsigned long);
void Debug_Print_Word(unsigned int w);
void EFF_VolumeUpdate_WithDebug(unsigned int slot, unsigned int b, unsigned int idx, unsigned long p);

void EFF_VolumeUpdate_WithDebug(unsigned int slot, unsigned int b, unsigned int idx, unsigned long p)
{
    int t;
    if (idx != 0x63) {
        Debug_Print_String(Str_EffVolume_Prefix);
        Debug_Print_Byte(slot + 1);
        Debug_Print_String(Str_EffVolume_Suffix);
        Debug_Print_Word(((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6]);
        switch (((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->on) {
        default:
            DSP_WriteParameter(slot, b, idx, p);
            break;
        case 0:
            t = ((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6];
            ((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6] = 0;
            DSP_WriteParameter(slot, b, idx, p);
            ((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6] = t;
        }
    }
}
