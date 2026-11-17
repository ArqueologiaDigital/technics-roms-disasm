/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/midi_dispatch_handlers.c (2026-11-16-38-p6-r6)
   sha256 429cfe28602b61900a641694fd6d0c64a92d390061dd94703531cfc9e0fc58cf (tar-sha256); compiled at -O3 -XS -Xr
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
