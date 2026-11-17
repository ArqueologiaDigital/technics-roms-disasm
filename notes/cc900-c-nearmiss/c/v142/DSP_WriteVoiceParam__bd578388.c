/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_11b.c (2026-11-16-94-sub-r11)
   sha256 bd5783887b95ef5eafc767a653a0a38f9363723a2758927b050ad92af2b06c6f (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern void DSP_ParamWrite_BlockCopy(unsigned int, unsigned char *, unsigned char *);
int DSP_WriteVoiceParam(unsigned int part, unsigned int off, unsigned int n, unsigned char *src)
{
    switch ((*(unsigned char **)((unsigned long)&ram_4136e[0] + (unsigned long)part * 0x11f))[16] & 0xc0) {
    case 0x00:
        DSP_ParamWrite_BlockCopy(n, &(*(unsigned char **)((unsigned long)&ram_4136e[0] + (unsigned long)part * 0x11f))[off], src);
        return n;
    case 0x40:
        return 0;
    case 0x80:
        DSP_ParamWrite_BlockCopy(n, &(*(unsigned char **)((unsigned long)&ram_4136e[0] + (unsigned long)part * 0x11f))[off], src);
        return n;
    case 0xc0:
        return 0;
    }
}
