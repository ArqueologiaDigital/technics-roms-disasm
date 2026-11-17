/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_2a.c (2026-11-16-47-sub-r2)
   sha256 317481c6cc0b0362eb3d69ef64a520bc9035dd3312d59f39df1c5ca8e5f184c4 (name+funcs); compiled at -Xr */
extern unsigned int ram_451f8;
extern unsigned int ram_451fa;
extern unsigned int ram_451fc;
extern unsigned int ram_451fe;
extern unsigned int ram_45200;
extern unsigned int ram_45202;
struct lvl70 { char pad[70]; unsigned char v; };
void Voice_Calc_LevelPair_Silence(struct lvl70 *p)
{
    ram_451fc = 0;
    ram_451fe = 0;
    ram_451f8 = (p->v << 8) | 0x80;
    ram_451fa = p->v << 8;
    ram_45200 = 0;
    ram_45202 = 0;
}
