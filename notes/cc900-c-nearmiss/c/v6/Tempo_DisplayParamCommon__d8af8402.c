/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/accompaniment_engine_m257.c (2026-11-16-68-p6-r12)
   sha256 d8af84021c751008b94ac2072b36820ec36a1c6e852fd642ebe2c787dad9a9e0 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_e2f8;
extern unsigned char __near ram_e2fa;
extern unsigned char __near ram_e2fc;
void Tempo_DisplayParamCommon(unsigned char a, unsigned char c)
{
    ram_e2f8 |= 9;
    ram_e2fa = a;
    ram_e2fc = c;
}
