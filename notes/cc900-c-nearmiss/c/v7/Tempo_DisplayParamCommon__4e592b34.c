/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/accompaniment_engine_m257.c (2026-11-16-68-p6-r12)
   sha256 4e592b34660168ea39e9e63b5899119450f805c231df4d2ceecb9840f24242f0 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_e31c;
extern unsigned char __near ram_e31e;
extern unsigned char __near ram_e320;
void Tempo_DisplayParamCommon(unsigned char a, unsigned char c)
{
    ram_e31c |= 9;
    ram_e31e = a;
    ram_e320 = c;
}
