/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_7a.c (2026-11-16-79-sub-r7)
   sha256 143de7409dae35d7976fc4f35166d64c5f696ce04cd1c3c30aec77c5887d93f4 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern void DSP_ParamWrite_BlockCopy(unsigned int n, unsigned char *s, unsigned char *d);
int DSP_WriteVoiceParam(unsigned int part, unsigned int off, unsigned int n, unsigned char *buf)
{
    switch ((*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f))[16] & 0xc0) {
    case 0:
        DSP_ParamWrite_BlockCopy(n, (unsigned long)off + *(unsigned char **)((unsigned long)ram_4136e
                                                                              + (unsigned long)part * 0x11f), buf);
        return n;
    case 0x40:
        return 0;
    case 0x80:
        DSP_ParamWrite_BlockCopy(n, (unsigned long)off + *(unsigned char **)((unsigned long)ram_4136e
                                                                              + (unsigned long)part * 0x11f), buf);
        return n;
    case 0xc0:
        return 0;
    }
}
