/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1a.c (2026-11-16-30-p6-r1)
   sha256 89c854e8d1cefff97d8e3bd7f8dd41e25e56a8bb83e3b643d1a5fe02db8a7c3a (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ram_bc68[], ram_bc64[], PANEL_PART_RT1;
extern unsigned char PANEL_RECALL_BACKUP[];
void TGReg_ClearTerminator(void)
{
    PANEL_RECALL_BACKUP[(long)&PANEL_PART_RT1 - 0xf9b4] = 0xff;
}
