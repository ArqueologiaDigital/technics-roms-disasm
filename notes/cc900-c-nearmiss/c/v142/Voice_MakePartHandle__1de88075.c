/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_params_and_tvf_ah_20a.c (2026-11-18-19-sub-r21b-staged)
   sha256 1de880758c1f363e9cac269c2c1db4dcc9590427c6239b101a40f61e415b98bc (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
void Voice_ScanSlots_ReassignSources(unsigned char a);
unsigned int Voice_MakePartHandle(unsigned char a, unsigned char c)
{
    c &= 0x3f;
    if (a >= 0x40) return (unsigned int)c << 8 | 0xff;
    Voice_ScanSlots_ReassignSources(a);
    return (unsigned int)c << 8 | 0xff;
}
