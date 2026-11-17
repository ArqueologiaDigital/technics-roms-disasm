/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_4a.c (2026-11-16-62-sub-r4)
   sha256 8761cd5b09c02ab4a3dcf319bf8f33d0a140160a7f99178b636c4330cd768909 (name+funcs); compiled at -Xr */
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern unsigned char ram_451cc[];
extern unsigned char ram_4308e[];
void ToneGen_WriteLevelBurst(int n, unsigned char *blk);
void ToneGen_WriteSegRegs_SameLevel(int n, unsigned char *blk);
void ToneGen_WriteEnvSegments(int n, unsigned char *blk);
void ToneGen_WriteSingleReg(int n, int v);
void Voice_Clear_HoldBit(int n);
void Voice_Stage_EnvSegments(unsigned char *v);
void Voice_Calc_LevelPair_EGA(unsigned char *v);
void Voice_Calc_LevelPair_EGB(unsigned char *v);
void Voice_Calc_LevelPair_EGC(unsigned char *v);
void Voice_Reload_Levels(unsigned char n)
{
    unsigned char *v;
    v = &ram_4308e[(int)n * 71];
    v[5] &= 0x7f;
    if ((W(v, 1) & 0x8000L) || !(W(P(v, 35), 10) & 1)) {
        if (W(v, 1) & 0x100) {
            Voice_Calc_LevelPair_EGA(v);
            ToneGen_WriteSegRegs_SameLevel(n, ram_451cc);
            ToneGen_WriteSingleReg(n, SW(v, 45));
            Voice_Clear_HoldBit(n);
            W(v, 1) &= ~0x100;
        } else {
            Voice_Calc_LevelPair_EGA(v);
            Voice_Calc_LevelPair_EGB(v);
            Voice_Calc_LevelPair_EGC(v);
            ToneGen_WriteLevelBurst(n, ram_451cc);
        }
    } else {
        if (W(v, 1) & 0x100) {
            Voice_Calc_LevelPair_EGA(v);
            ToneGen_WriteSegRegs_SameLevel(n, ram_451cc);
            ToneGen_WriteSingleReg(n, SW(v, 45));
            Voice_Clear_HoldBit(n);
            W(v, 1) &= ~0x100;
        } else {
            Voice_Stage_EnvSegments(v);
            ToneGen_WriteEnvSegments(n, ram_451cc);
        }
    }
}
