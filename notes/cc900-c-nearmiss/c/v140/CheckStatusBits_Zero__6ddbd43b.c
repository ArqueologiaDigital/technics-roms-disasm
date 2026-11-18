/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/voice_noteon_and_tonegen_ai_21a.c (2026-11-18-21-sub-r21c-staged)
   sha256 6ddbd43b62ac8490240dc47dc0dc1f2c9fd95cb9d4fd2e1bfd7c62b7e5081977 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41322[];
int CheckStatusBits_Zero(unsigned int part)
{
    return ((*(unsigned char **)((unsigned long)ram_41322 + (unsigned long)part * 0x11f))[16] & 0xc0) == 0;
}
