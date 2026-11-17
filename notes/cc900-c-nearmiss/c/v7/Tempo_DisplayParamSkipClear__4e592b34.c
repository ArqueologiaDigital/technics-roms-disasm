/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/accompaniment_engine_m257.c (2026-11-16-68-p6-r12)
   sha256 4e592b34660168ea39e9e63b5899119450f805c231df4d2ceecb9840f24242f0 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near GLOBAL_ERROR_CODE;
extern void UI_InterruptTitleByIndex(int);
void Tempo_DisplayParamSkipClear(unsigned char a)
{
    GLOBAL_ERROR_CODE = a;
    UI_InterruptTitleByIndex(0xee);
}
