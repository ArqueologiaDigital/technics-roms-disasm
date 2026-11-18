/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/voice_envelopes_and_channels_ag_21a.c (2026-11-18-32-sub-r21g-staged)
   sha256 1b4bb0d186058d9acd2018736b641e21f68bf71d32d6b7249cfa49e3ef574558 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: ToneGen_WrExtParam_1C0_Single=ToneGen_WriteExtParam_1C0_Single
   cc900-name: ToneGen_WrExtParam_TypeDisp_Sgl=ToneGen_WriteExtParam_TypeDispatch_Single */
extern unsigned char ram_44236[];
extern unsigned char ram_4423f[];
extern unsigned char ram_44248[];
extern unsigned int ram_451b4[];
extern unsigned int ram_451ec;
extern unsigned int ram_451f4;
extern unsigned int ram_451f6;
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
        p = ram_44236 + (unsigned long)i * 27;
        if (*p & 0x18) {
            r = Voice_AdvanceLFOPhase(p);
            if (r != 0) {
                ram_451f4 = EGEnv_Compute_A((unsigned char)i);
                if (r != 0x100) {
                    t = (unsigned long)ram_451f4 & 0x1fff;
                    t *= r;
                    ram_451f4 &= 0xe000;
                    ram_451f4 |= (unsigned int)(t >> 8);
                }
                ToneGen_WriteExtParam_600(i, ram_451b4);
            }
        }
    }
    for (i = 0; i < 0x40; i++) {
        p = (unsigned char *)((unsigned long)ram_4423f + (unsigned long)i * 27);
        if (*p & 0x18) {
            r = Voice_AdvanceLFOPhase(p);
            if (r != 0) {
                ram_451ec = EGEnv_Compute_B((unsigned char)i);
                if (r != 0x100) {
                    t = (unsigned long)ram_451ec & 0x1fff;
                    t *= r;
                    ram_451ec &= 0xe000;
                    ram_451ec |= (unsigned int)(t >> 8);
                }
                ToneGen_WrExtParam_1C0_Single(i, ram_451b4);
            }
        }
    }
    for (i = 0; i < 0x80; i++) {
        p = (unsigned char *)((unsigned long)ram_44248 + (unsigned long)i * 27);
        if (*p & 0x18) {
            r = Voice_AdvanceLFOPhase(p);
            if (r != 0) {
                Voice_Freq_WriteLeft((unsigned char)i);
                if (r != 0x100) {
                    if (i < 0x40) {
                        t = (unsigned long)ram_451ec & 0x1fff;
                        t *= r;
                        ram_451ec &= 0xe000;
                        ram_451ec |= (unsigned int)(t >> 8);
                    } else {
                        t = (unsigned long)ram_451f6 & 0x1fff;
                        t *= r;
                        ram_451f6 &= 0xe000;
                        ram_451f6 |= (unsigned int)(t >> 8);
                    }
                }
                ToneGen_WrExtParam_TypeDisp_Sgl(i, ram_451b4);
            }
        }
    }
}
