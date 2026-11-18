/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/voice_noteon_and_tonegen_ai_21a.c (2026-11-18-21-sub-r21c-staged)
   sha256 f46a99d4a9c7cf7bdd516b265d0c44a4654ba5ea6dc978fe85363dc820e0c2d9 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41356[];
int CheckStatusBits_Zero(unsigned int part)
{
    return ((*(unsigned char **)((unsigned long)ram_41356 + (unsigned long)part * 0x11f))[16] & 0xc0) == 0;
}
