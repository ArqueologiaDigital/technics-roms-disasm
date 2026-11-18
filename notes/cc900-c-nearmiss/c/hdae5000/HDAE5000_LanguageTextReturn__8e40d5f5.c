/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_small_procs.c (2026-11-18-26-hd-r56-ports)
   sha256 8e40d5f5afcc4103ca26ecc335d947e4cd9d326d5dbbd3b1d74513568e206137 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
#define EVT_GET_LANGUAGE_PTR 0x1e0009fL
extern char *HDAE5000_TextPtrs_LANENG001_to_LANENG006[];
char **HDAE5000_LanguageTextReturn(long obj, long ev, long arg)
{
    if (ev == EVT_GET_LANGUAGE_PTR)
        return HDAE5000_TextPtrs_LANENG001_to_LANENG006;
    return 0;
}
