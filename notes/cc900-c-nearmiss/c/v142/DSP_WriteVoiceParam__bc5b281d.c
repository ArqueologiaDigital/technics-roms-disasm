/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_10b.c (2026-11-16-90-sub-r10)
   sha256 bc5b281dceb985f114d364502d6740cad1d24883855d2a547d3ff9990aa72ca9 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern void DSP_ParamWrite_BlockCopy(unsigned int, unsigned char *, unsigned char *);
int DSP_WriteVoiceParam(unsigned int part, unsigned int off, unsigned int n, unsigned char *src)
{
    switch ((*(unsigned char **)(ram_4136e + (unsigned long)part * 0x11f))[16] & 0xc0) {
    case 0x00:
        DSP_ParamWrite_BlockCopy(n, (*(unsigned char **)(ram_4136e + (unsigned long)part * 0x11f)) + off, src);
        return n;
    case 0x40:
        return 0;
    case 0x80:
        DSP_ParamWrite_BlockCopy(n, (*(unsigned char **)(ram_4136e + (unsigned long)part * 0x11f)) + off, src);
        return n;
    case 0xc0:
        return 0;
    }
}
