/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_noteon_and_tonegen_ai_21a.c (2026-11-18-21-sub-r21c-staged)
   sha256 558d8211f529222834a1661dd528698e0f76c7c6a270f492ecd6fbe32bf8943b (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_4136e[];
int CheckStatusBits_Zero(unsigned int part)
{
    return ((*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f))[16] & 0xc0) == 0;
}
