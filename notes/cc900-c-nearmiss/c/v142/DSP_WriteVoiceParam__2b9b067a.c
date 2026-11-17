/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_W_18b.c (2026-11-17-7-sub-r18)
   sha256 2b9b067aa3f5d6c5692fafb23e49ef5089f738ea67d405a1f19b2166fe4e7881 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern void DSP_ParamWrite_BlockCopy(unsigned int, unsigned char *, unsigned char *);
int DSP_WriteVoiceParam(unsigned int part, unsigned int off, unsigned int n, unsigned char *buf)
{
    switch ((*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f))[16] & 0xc0) {
    case 0:
        DSP_ParamWrite_BlockCopy(n, *(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f)
                                     + (unsigned long)off, buf);
        return n;
    case 0x40:
        return 0;
    case 0x80:
        DSP_ParamWrite_BlockCopy(n, *(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f)
                                     + (unsigned long)off, buf);
        return n;
    case 0xc0:
        return 0;
    }
}
