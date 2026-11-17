/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2c.c (2026-11-16-47-sub-r2)
   sha256 675d49d3eeeea79e327148ffdc5c5179606a08452f10204af09a37e964ae4c72 (name+funcs); compiled at -Xr */
extern unsigned char ram_451cc[];
extern unsigned char ram_4308e[];
void Voice_Calc_LevelPair_Silence(unsigned char *v);
void ToneGen_WriteLevelBurst(int n, unsigned char *blk);
void Voice_ReleaseSingle(unsigned char n)
{
    unsigned char *v;
    v = ram_4308e + n * 71;
    v[5] &= 0x7f;
    if (v[70] != 0) {
        Voice_Calc_LevelPair_Silence(v);
        ToneGen_WriteLevelBurst(n, ram_451cc);
    }
}
