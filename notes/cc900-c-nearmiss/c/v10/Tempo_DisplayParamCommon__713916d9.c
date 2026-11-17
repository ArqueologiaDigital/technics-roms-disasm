/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_9m257.c (2026-11-16-72-p6-r13)
   sha256 713916d913bedab2d526a1693d909a92cfb5d8d5509f032e4da10dec8744a815 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ram_e3e2;
extern unsigned char __near ram_e3e4;
extern unsigned char __near ram_e3e6;
void Tempo_DisplayParamCommon(unsigned char a, unsigned char c)
{
    ram_e3e2 |= 9;
    ram_e3e4 = a;
    ram_e3e6 = c;
}
