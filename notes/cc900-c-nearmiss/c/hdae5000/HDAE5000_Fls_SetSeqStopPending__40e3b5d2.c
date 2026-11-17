/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_ui_display.c (2026-11-16-78-hd-r15-ports)
   sha256 40e3b5d21bd62b3b641f04dd0a04e540a222400640e18ed3c33d25071d1b65c7 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_FlsSeqStopPending;
void HDAE5000_Fls_SetSeqStopPending(unsigned char v)
{
    HDAE5000_RAM_FlsSeqStopPending = v;
}
