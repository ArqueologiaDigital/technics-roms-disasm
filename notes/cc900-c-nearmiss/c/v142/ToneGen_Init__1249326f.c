/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_6a.c (2026-11-16-73-sub-r6)
   sha256 1249326f8ca11987596854d16d2a694ae8f2a5dc0418eaae612666ec2f2e7448 (name+funcs); compiled at -Xr */
extern unsigned char __near ram_4a48;
extern void ToneGen_Poll_Init(void);
void ToneGen_Init(void)
{
    ram_4a48 = 6;
    ToneGen_Poll_Init();
}
