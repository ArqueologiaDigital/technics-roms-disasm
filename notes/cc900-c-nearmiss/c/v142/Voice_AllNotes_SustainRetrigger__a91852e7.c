/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_10c.c (2026-11-16-90-sub-r10)
   sha256 a91852e7df6052d66d113884c14ac20750eedb4cf632503b076234d13b67661d (name+funcs); compiled at -Xr */
extern unsigned char ram_4308e[][0x47];
extern unsigned int ram_451cc[];
extern void Voice_Calc_LevelPair_EGA(unsigned char *v);
extern void Voice_Calc_LevelPair_EGB(unsigned char *v);
extern void Voice_Calc_LevelPair_EGC(unsigned char *v);
extern void Voice_WriteVolume_SetFlag(unsigned char *v);
extern void Voice_WriteVolume_OrPan(unsigned char *v);
extern void ToneGen_WriteSegRegs_SameLevel(int ch, unsigned int *blk);
extern void Voice_Clear_HoldBit(int ch);
extern void ToneGen_WriteVoice_Direct(unsigned int a, unsigned int d);
extern void ToneGen_WriteVoice_6Words(unsigned int ch, unsigned int *p);
extern void ToneGen_WriteNote2ch(unsigned int ch, unsigned int *p);
void Voice_AllNotes_SustainRetrigger(unsigned char *list, unsigned char flag)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    base = ram_4308e;
    for (q = list + 5; *q < 0x40; q++) {
        v = base[*q];
        switch (*(unsigned int *)(v + 1) & 0x3c) {
        case 4:
        case 8:
        case 0x20:
            if ((*(unsigned int *)(v + 1) & 32768) || !(*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 1)) {
                if (*(unsigned int *)(v + 1) & 0x100) {
                    Voice_Calc_LevelPair_EGA(v);
                    ToneGen_WriteSegRegs_SameLevel(*q, ram_451cc);
                    ToneGen_WriteVoice_Direct(*q, *(unsigned int *)(v + 45));
                    Voice_Clear_HoldBit(*q);
                    *(unsigned int *)(v + 1) &= ~0x100;
                } else {
                    Voice_Calc_LevelPair_EGA(v);
                    Voice_Calc_LevelPair_EGB(v);
                    Voice_Calc_LevelPair_EGC(v);
                    ToneGen_WriteVoice_6Words(*q, ram_451cc);
                }
            } else if (*(unsigned int *)(v + 1) & 0x100) {
                Voice_Calc_LevelPair_EGA(v);
                ToneGen_WriteSegRegs_SameLevel(*q, ram_451cc);
                ToneGen_WriteVoice_Direct(*q, *(unsigned int *)(v + 45));
                Voice_Clear_HoldBit(*q);
                *(unsigned int *)(v + 1) &= ~0x100;
            } else if (!(*(unsigned int *)(v + 64) & 0xff)) {
                Voice_WriteVolume_SetFlag(v);
                ToneGen_WriteNote2ch(*q, ram_451cc);
            }
            break;
        case 0x10:
            if (flag != 0) {
                Voice_WriteVolume_OrPan(v);
                ToneGen_WriteNote2ch(*q, ram_451cc);
            }
            break;
        }
    }
}
