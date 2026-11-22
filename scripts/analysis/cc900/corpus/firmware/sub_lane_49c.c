/* lane_sub round 49 form c (form a with: MicSense's v a plain char; ApplyAlgo an early return): three small setters of core/13_audio_process_dsp_and_effects.s that no probe compiled
   before (sub_screen.py, 2026-11-22: kept out of the old pools for their memory-to-memory moves).
   DSP_Set_MicLevel: v stored as a word; nothing more while the mic sense cell is 0; else the config buffer's head
   cleared, cell 0x454a = 0x45b8 and the buffer applied; a dead `return ram_45b8;` follows (as DSP_Set_FadeLevel's).
   DSP_Set_MicSense: v stored; cell 0x454a = the level or 0; the buffer applied (a tail jump in the ROM).
   DSP_ApplyAlgoForVoiceType: for type 0x35 or 0x0f, cell 0x44b4 = 0x45b0 and the buffer applied.
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

int DSP_Set_MicLevel(unsigned char v)
{
    ram_45b8 = v;
    if (ram_45ba == 0)
        return;
    DSP_ConfigBuffer.f0 = 0;
    ram_454a = ram_45b8;
    DSP_State_ApplyBuf(&DSP_ConfigBuffer);
    return;
    return ram_45b8;
}

void DSP_Set_MicSense(char v)
{
    ram_45ba = v;
    DSP_ConfigBuffer.f0 = 0;
    if (v != 0)
        ram_454a = ram_45b8;
    else
        ram_454a = 0;
    DSP_State_ApplyBuf(&DSP_ConfigBuffer);
}

void DSP_ApplyAlgoForVoiceType(int t)
{
    if (t != 0x35 && t != 0xf)
        return;
    ram_44b4 = ram_45b0;
    DSP_State_ApplyBuf(&DSP_ConfigBuffer);
}
