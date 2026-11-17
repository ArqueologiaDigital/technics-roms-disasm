/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17b.c (2026-11-16-126-sub-r17)
   sha256 103952cb479afdc1c60db40fc3853c5ae181d89a51e462c0596d12a2a476ff39 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern void DSP_ParamWrite_BlockCopy(unsigned int, unsigned char *, unsigned char *);
int DSP_WriteVoiceParam(unsigned int part, unsigned int off, unsigned int n, unsigned char *buf)
{
    switch ((*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f))[16] & 0xc0) {
    case 0:
        DSP_ParamWrite_BlockCopy(n, &(*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f))[off],
                                 buf);
        return n;
    case 0x40:
        return 0;
    case 0x80:
        DSP_ParamWrite_BlockCopy(n, &(*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f))[off],
                                 buf);
        return n;
    case 0xc0:
        return 0;
    }
}
