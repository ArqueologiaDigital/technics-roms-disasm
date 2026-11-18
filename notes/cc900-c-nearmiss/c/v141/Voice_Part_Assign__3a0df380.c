/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/voice_params_and_tvf_ah_21a.c (2026-11-18-32-sub-r21g-staged)
   sha256 3a0df380df456a482e00c3dd555aec5e877379c245f449a5bbcd77f1ad05b354 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
unsigned int Voice_MakePartHandle(unsigned char a, unsigned char c);
void ExtVoice_Alloc_StreamSlot(unsigned char a, unsigned char c, unsigned char e);
void Voice_Part_Assign(unsigned char a, unsigned char c, unsigned char e, unsigned char s)
{
    Voice_MakePartHandle(c, e);
    ExtVoice_Alloc_StreamSlot(a, c, s);
}
