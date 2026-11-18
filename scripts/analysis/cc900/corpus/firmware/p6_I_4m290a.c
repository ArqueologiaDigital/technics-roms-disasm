/* Phase 6, lane_p6 helper I, round 4, module 290 (audio/dsp_config_sysex.s), form a.  New.
   SysEx_ApplyAndReloadPreset(type, v): for type 0x61 (DSP effect) / 0x63 (digital reverb) writes v as the
   algorithm (param 0x4900 / 0x4b00 into the panel record PANEL_DSP_EFFECT / PANEL_DIGITAL_REVERB), then reads the
   algorithm's parameter count (0x4904 / 0x4b04) and copies each default (DSPCfg_ReadParam_Map1(0x4910 + i)) into
   the record (DSPCfg_WriteParamSimple(0x4910 + i, value, record)).  0, or -1 for another type.
   Read from the hand assembly: v widened at entry (extz bc), the count in QIZ, i in IZ; the compare chain tests
   0x63 first (source order 0x61, 0x63), the default right after it; each loop test copied to the entry (-O3); the
   record addresses as 16-bit immediates (__near arrays).  Form b: the two cases' tails as gotos to one return. */

extern unsigned char __near PANEL_DSP_EFFECT[];
extern unsigned char __near PANEL_DIGITAL_REVERB[];
extern int DSPCfg_WriteParamSimple(long id, int v, unsigned char *rec);
extern int DSPCfg_ReadParam_Map0(long id);
extern int DSPCfg_ReadParam_Map1(long id);
extern int SysEx_ApplyAndReloadPreset(unsigned char type, unsigned char v);

int SysEx_ApplyAndReloadPreset(unsigned char type, unsigned char v)
{
    int n;
    int i;

    switch (type) {
    case 0x61:
        if (DSPCfg_WriteParamSimple(0x4900L, v, PANEL_DSP_EFFECT) < 0)
            return 0;
        n = DSPCfg_ReadParam_Map0(0x4904L);
        if (n < 0)
            return 0;
        for (i = 0; i < n; i++)
            DSPCfg_WriteParamSimple(i + 0x4910L, DSPCfg_ReadParam_Map1(i + 0x4910L), PANEL_DSP_EFFECT);
        return 0;
    case 0x63:
        if (DSPCfg_WriteParamSimple(0x4b00L, v, PANEL_DIGITAL_REVERB) < 0)
            return 0;
        n = DSPCfg_ReadParam_Map0(0x4b04L);
        if (n < 0)
            return 0;
        for (i = 0; i < n; i++)
            DSPCfg_WriteParamSimple(i + 0x4b10L, DSPCfg_ReadParam_Map1(i + 0x4b10L), PANEL_DIGITAL_REVERB);
        return 0;
    default:
        return -1;
    }
}
