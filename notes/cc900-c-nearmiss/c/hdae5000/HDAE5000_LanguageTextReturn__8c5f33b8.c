/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_small_procs.c (2026-11-18-24-hd-r56)
   sha256 8c5f33b8d3cb5e62cfb127253f6115ed65e930b9d0b36471bd2014ff1a0d5556 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
#define EVT_GET_LANGUAGE_PTR 0x1e0009fL
extern char *HDAE5000_TextPtrs_LANENG001_to_LANENG006[];
char **HDAE5000_LanguageTextReturn(long obj, long ev, long arg)
{
    if (ev == EVT_GET_LANGUAGE_PTR)
        return HDAE5000_TextPtrs_LANENG001_to_LANENG006;
    return 0;
}
