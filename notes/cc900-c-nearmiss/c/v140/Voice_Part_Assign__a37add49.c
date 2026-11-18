/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/voice_params_and_tvf_ah_21a.c (2026-11-18-32-sub-r21g-staged)
   sha256 a37add49af078a28de9716956c77c27c5f411d7825833dbcef37b3006c208cc3 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
unsigned int Voice_MakePartHandle(unsigned char a, unsigned char c);
void ExtVoice_Alloc_StreamSlot(unsigned char a, unsigned char c, unsigned char e);
void Voice_Part_Assign(unsigned char a, unsigned char c, unsigned char e, unsigned char s)
{
    Voice_MakePartHandle(c, e);
    ExtVoice_Alloc_StreamSlot(a, c, s);
}
