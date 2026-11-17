/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_11a.c (2026-11-16-94-sub-r11)
   sha256 ed920ea2b231ae3287c18888289ba3ac2708960998565da7a53f61cc953904fd (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern void DSP_ParamWrite_BlockCopy(unsigned int, unsigned char *, unsigned char *);
int DSP_WriteVoiceParam(unsigned int part, unsigned int off, unsigned int n, unsigned char *src)
{
    switch ((*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f))[16] & 0xc0) {
    case 0x00:
        DSP_ParamWrite_BlockCopy(n, (*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f)) + off, src);
        return n;
    case 0x40:
        return 0;
    case 0x80:
        DSP_ParamWrite_BlockCopy(n, (*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f)) + off, src);
        return n;
    case 0xc0:
        return 0;
    }
}
