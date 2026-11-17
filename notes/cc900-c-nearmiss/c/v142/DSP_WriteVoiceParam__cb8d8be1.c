/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17c.c (2026-11-16-126-sub-r17)
   sha256 cb8d8be11508728097d9e78ae3bf4fbe5f7b1c76f6a92dd24928a8442d7e7268 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern void DSP_ParamWrite_BlockCopy(unsigned int, unsigned char *, unsigned char *);
int DSP_WriteVoiceParam(unsigned int part, unsigned int off, unsigned int n, unsigned char *buf)
{
    switch ((*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f))[16] & 0xc0) {
    case 0:
        DSP_ParamWrite_BlockCopy(n, off + *(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f),
                                 buf);
        return n;
    case 0x40:
        return 0;
    case 0x80:
        DSP_ParamWrite_BlockCopy(n, off + *(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f),
                                 buf);
        return n;
    case 0xc0:
        return 0;
    }
}
