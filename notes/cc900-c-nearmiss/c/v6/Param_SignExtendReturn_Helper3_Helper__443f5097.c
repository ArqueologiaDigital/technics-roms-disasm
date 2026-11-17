/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/midi_dispatch_handlers.c (2026-11-16-40-p6-r8)
   sha256 443f509779a72f5a86c67ed9a7873444ecb44c4a755f1b9067a263e42c368c1d (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr
   cc900-name: Param_SignExt_H3_Helper=Param_SignExtendReturn_Helper3_Helper */
unsigned char Param_SignExt_H3_Helper(unsigned char *p, unsigned int n)
{
    unsigned char s = 0;
    p++;
    n--;
    while (n--) s += *p++;
    return -s & 0x7f;
}
