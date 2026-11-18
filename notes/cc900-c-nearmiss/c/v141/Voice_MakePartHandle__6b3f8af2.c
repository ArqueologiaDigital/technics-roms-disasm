/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/voice_params_and_tvf_ah_20a.c (2026-11-18-19-sub-r21b-staged)
   sha256 6b3f8af2abcce04ac419010256687e8e5d1b4cc182fb02195851be7208f2ef54 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
void Voice_ScanSlots_ReassignSources(unsigned char a);
unsigned int Voice_MakePartHandle(unsigned char a, unsigned char c)
{
    c &= 0x3f;
    if (a >= 0x40) return (unsigned int)c << 8 | 0xff;
    Voice_ScanSlots_ReassignSources(a);
    return (unsigned int)c << 8 | 0xff;
}
