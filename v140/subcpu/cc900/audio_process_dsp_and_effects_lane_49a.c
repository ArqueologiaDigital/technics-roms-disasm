/* Functions of core/13_audio_process_dsp_and_effects.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct slot { unsigned int type; int f2; int param[25]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
extern struct cfg __near DSP_ConfigBuffer;
extern unsigned int __near ram_45b8;
extern unsigned int __near ram_45ba;
extern unsigned int __near ram_454a;
extern unsigned int __near ram_44b4;
extern unsigned int __near ram_45b0;
extern void DSP_State_ApplyBuf(struct cfg *);
void DSP_ApplyAlgoForVoiceType(int t);
void DSP_Set_MicSense(unsigned char v);

void DSP_ApplyAlgoForVoiceType(int t)
{
    if (t == 0x35 || t == 0xf) {
        ram_44b4 = ram_45b0;
        DSP_State_ApplyBuf(&DSP_ConfigBuffer);
    }
}

void DSP_Set_MicSense(unsigned char v)
{
    ram_45ba = v;
    DSP_ConfigBuffer.f0 = 0;
    if (v != 0)
        ram_454a = ram_45b8;
    else
        ram_454a = 0;
    DSP_State_ApplyBuf(&DSP_ConfigBuffer);
}
