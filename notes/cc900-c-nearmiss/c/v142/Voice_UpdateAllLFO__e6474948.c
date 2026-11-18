/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AG_20a.c (2026-11-18-18-sub-r21a)
   sha256 e64749487a5b77e74adcadd02c8847171c6991e4cd15a61fe8c5172fc9c0813c (tar-sha256); compiled at -Xr
   cc900-name: ToneGen_WrExtParam_1C0_Single=ToneGen_WriteExtParam_1C0_Single
   cc900-name: ToneGen_WrExtParam_TypeDisp_Sgl=ToneGen_WriteExtParam_TypeDispatch_Single */
extern unsigned char ram_4424e[];
extern unsigned char ram_44257[];
extern unsigned char ram_44260[];
extern unsigned int ram_451cc[];
extern unsigned int ram_45204;
extern unsigned int ram_4520c;
extern unsigned int ram_4520e;
extern unsigned int Voice_AdvanceLFOPhase(unsigned char *p);
extern unsigned int EGEnv_Compute_A(unsigned char n);
extern unsigned int EGEnv_Compute_B(unsigned char n);
extern void Voice_Freq_WriteLeft(unsigned char n);
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
        p = ram_4424e + (unsigned long)i * 27;
        if (*p & 0x18) {
            r = Voice_AdvanceLFOPhase(p);
            if (r != 0) {
                ram_4520c = EGEnv_Compute_A(i);
                if (r != 1) {
                    t = ((unsigned long)ram_4520c & 0x1fff) * r;
                    ram_4520c &= 0xe000;
                    ram_4520c |= (unsigned int)(t >> 8);
                }
                ToneGen_WriteExtParam_600(i, ram_451cc);
            }
        }
    }
    for (i = 0; i < 0x40; i++) {
        p = ram_44257 + (unsigned long)i * 27;
        if (*p & 0x18) {
            r = Voice_AdvanceLFOPhase(p);
            if (r != 0) {
                ram_45204 = EGEnv_Compute_B(i);
                if (r != 1) {
                    t = ((unsigned long)ram_45204 & 0x1fff) * r;
                    ram_45204 &= 0xe000;
                    ram_45204 |= (unsigned int)(t >> 8);
                }
                ToneGen_WrExtParam_1C0_Single(i, ram_451cc);
            }
        }
    }
    for (i = 0; i < 0x80; i++) {
        p = ram_44260 + (unsigned long)i * 27;
        if (*p & 0x18) {
            r = Voice_AdvanceLFOPhase(p);
            if (r != 0) {
                Voice_Freq_WriteLeft(i);
                if (r != 1) {
                    if (i < 0x40) {
                        t = ((unsigned long)ram_45204 & 0x1fff) * r;
                        ram_45204 &= 0xe000;
                        ram_45204 |= (unsigned int)(t >> 8);
                    } else {
                        t = ((unsigned long)ram_4520e & 0x1fff) * r;
                        ram_4520e &= 0xe000;
                        ram_4520e |= (unsigned int)(t >> 8);
                    }
                }
                ToneGen_WrExtParam_TypeDisp_Sgl(i, ram_451cc);
            }
        }
    }
}
