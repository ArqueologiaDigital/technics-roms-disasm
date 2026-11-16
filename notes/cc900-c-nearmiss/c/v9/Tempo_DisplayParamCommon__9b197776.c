/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/accompaniment_engine_m257.c (2026-11-16-68-p6-r12)
   sha256 9b197776eb4223e1007e1e6fb8c684454317b2937a6d531c58d6b9e3d45cb922 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_e3e2;
extern unsigned char __near ram_e3e4;
extern unsigned char __near ram_e3e6;
void Tempo_DisplayParamCommon(unsigned char a, unsigned char c)
{
    ram_e3e2 |= 9;
    ram_e3e4 = a;
    ram_e3e6 = c;
}
