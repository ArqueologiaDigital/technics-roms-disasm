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
extern struct cfg __near DSP_ConfigBuffer;
extern struct slot __near ram_4496[];
extern unsigned int __near ram_454a;
extern unsigned int __near ram_45b8;
extern unsigned int __near ram_45ba;
extern void DSP_State_ApplyBuf(struct cfg *);
extern void DSP_ApplyAlgoForVoiceType(unsigned int);

/* cc900-module: DSP_ApplyAlgoForVoiceType */
void DSP_ApplyConfig(unsigned char mode, unsigned char unused, unsigned char flag)
{
    if (flag == 0xff)
        DSP_ConfigBuffer.f0 = 1;
    else
        DSP_ConfigBuffer.f0 = 0;
    switch (mode) {
    case 0:
        DSP_State_ApplyBuf(&DSP_ConfigBuffer);
        DSP_ApplyAlgoForVoiceType(ram_4496[0].type);
        return;
    case 1: case 2: case 4:
        DSP_State_ApplyBuf(&DSP_ConfigBuffer);
        return;
    case 3:
        (&ram_454a)[0] = ram_45ba != 0 ? ram_45b8 : 0;
        DSP_State_ApplyBuf(&DSP_ConfigBuffer);
        break;
    default:
        break;
    }
}
