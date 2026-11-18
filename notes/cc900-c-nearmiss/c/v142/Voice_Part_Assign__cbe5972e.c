/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_params_and_tvf_ah_21a.c (2026-11-18-32-sub-r21g-staged)
   sha256 cbe5972e34a6e8dc3dd469d5058e8c0400ad9376363f0bfb1f6ae45270c58621 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
unsigned int Voice_MakePartHandle(unsigned char a, unsigned char c);
void ExtVoice_Alloc_StreamSlot(unsigned char a, unsigned char c, unsigned char e);
void Voice_Part_Assign(unsigned char a, unsigned char c, unsigned char e, unsigned char s)
{
    Voice_MakePartHandle(c, e);
    ExtVoice_Alloc_StreamSlot(a, c, s);
}
