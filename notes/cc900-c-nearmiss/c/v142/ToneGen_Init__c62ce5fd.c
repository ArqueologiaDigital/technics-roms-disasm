/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_3a.c (2026-11-16-58-sub-r3)
   sha256 c62ce5fddcf8b613845ab6dee451222d9696446cb538d0e863a5815dd894a1aa (name+funcs); compiled at -Xr */
extern unsigned char __near ram_4a48;
extern void ToneGen_Poll_Init(void);
void ToneGen_Init(void)
{
    ram_4a48 = 6;
    ToneGen_Poll_Init();
}
