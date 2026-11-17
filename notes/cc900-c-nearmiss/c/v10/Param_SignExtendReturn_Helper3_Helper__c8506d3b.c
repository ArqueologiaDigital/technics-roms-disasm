/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/midi_dispatch_handlers.c (2026-11-16-40-p6-r8)
   sha256 c8506d3b1427959e38673461679326677060071b4d9806189c04338306408d18 (tar-sha256); compiled at -O3 -XS -Xr
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
