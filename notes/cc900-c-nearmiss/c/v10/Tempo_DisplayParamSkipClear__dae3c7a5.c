/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_8m257.c (2026-11-16-53-p6-r11)
   sha256 dae3c7a597b6107330c19f6dfe81e9195fa225548090f20c7765ae637027af8b (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near GLOBAL_ERROR_CODE;
extern void UI_InterruptTitleByIndex(int);
void Tempo_DisplayParamSkipClear(unsigned char a)
{
    GLOBAL_ERROR_CODE = a;
    UI_InterruptTitleByIndex(0xee);
}
