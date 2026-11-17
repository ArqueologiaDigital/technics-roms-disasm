/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/voice_noteon_and_tonegen_runtime.c (2026-11-16-80-sub-staged2)
   sha256 f8caa32a7d5baea432b1da68dc92b8c564aa7ea8b29575c25409601e4688a59b (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_4136e[];
int Voice_Part_Mode_Is_C0(unsigned int part)
{
    return ((*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f))[16] & 0xc0) == 0xc0;
}
