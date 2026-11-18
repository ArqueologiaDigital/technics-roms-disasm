/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/voice_envelopes_and_channels_ag_21a.c (2026-11-18-32-sub-r21g-staged)
   sha256 ffcedff560f1dc88ff9d34b0d6db4e4b13655df466d77899e99df330f4d6543b (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: ToneGen_WrExtParam_1C0_Single=ToneGen_WriteExtParam_1C0_Single
   cc900-name: ToneGen_WrExtParam_TypeDisp_Sgl=ToneGen_WriteExtParam_TypeDispatch_Single */
extern unsigned char ram_44202[];
extern unsigned char ram_4420b[];
extern unsigned char ram_44214[];
extern unsigned int ram_45180[];
extern unsigned int ram_451b8;
extern unsigned int ram_451c0;
extern unsigned int ram_451c2;
extern unsigned int Voice_AdvanceLFOPhase(unsigned char *p);
extern unsigned int EGEnv_Compute_A(int n);
extern unsigned int EGEnv_Compute_B(int n);
extern void Voice_Freq_WriteLeft(int n);
extern void ToneGen_WriteExtParam_600(int ch, unsigned int *p);
extern void ToneGen_WrExtParam_1C0_Single(int ch, unsigned int *p);
extern void ToneGen_WrExtParam_TypeDisp_Sgl(int ch, unsigned int *p);
void Voice_UpdateAllLFO(void)
{
    unsigned int i;
    unsigned char *p;
    unsigned int r;
    unsigned long t;
    for (i = 0; i < 0x80; i++) {
        p = ram_44202 + (unsigned long)i * 27;
        if (*p & 0x18) {
            r = Voice_AdvanceLFOPhase(p);
            if (r != 0) {
                ram_451c0 = EGEnv_Compute_A((unsigned char)i);
                if (r != 0x100) {
                    t = (unsigned long)ram_451c0 & 0x1fff;
                    t *= r;
                    ram_451c0 &= 0xe000;
                    ram_451c0 |= (unsigned int)(t >> 8);
                }
                ToneGen_WriteExtParam_600(i, ram_45180);
            }
        }
    }
    for (i = 0; i < 0x40; i++) {
        p = (unsigned char *)((unsigned long)ram_4420b + (unsigned long)i * 27);
        if (*p & 0x18) {
            r = Voice_AdvanceLFOPhase(p);
            if (r != 0) {
                ram_451b8 = EGEnv_Compute_B((unsigned char)i);
                if (r != 0x100) {
                    t = (unsigned long)ram_451b8 & 0x1fff;
                    t *= r;
                    ram_451b8 &= 0xe000;
                    ram_451b8 |= (unsigned int)(t >> 8);
                }
                ToneGen_WrExtParam_1C0_Single(i, ram_45180);
            }
        }
    }
    for (i = 0; i < 0x80; i++) {
        p = (unsigned char *)((unsigned long)ram_44214 + (unsigned long)i * 27);
        if (*p & 0x18) {
            r = Voice_AdvanceLFOPhase(p);
            if (r != 0) {
                Voice_Freq_WriteLeft((unsigned char)i);
                if (r != 0x100) {
                    if (i < 0x40) {
                        t = (unsigned long)ram_451b8 & 0x1fff;
                        t *= r;
                        ram_451b8 &= 0xe000;
                        ram_451b8 |= (unsigned int)(t >> 8);
                    } else {
                        t = (unsigned long)ram_451c2 & 0x1fff;
                        t *= r;
                        ram_451c2 &= 0xe000;
                        ram_451c2 |= (unsigned int)(t >> 8);
                    }
                }
                ToneGen_WrExtParam_TypeDisp_Sgl(i, ram_45180);
            }
        }
    }
}
