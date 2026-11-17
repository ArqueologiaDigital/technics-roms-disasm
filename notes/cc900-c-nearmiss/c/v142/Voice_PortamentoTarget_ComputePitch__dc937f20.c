/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_J_14c.c (2026-11-16-101-sub-r14)
   sha256 dc937f2048fd4906c0f315df818549a7a69e4fdc94fcd4dd4fbfec9013710cd3 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned long ram_45310;
extern unsigned char *ram_45314;
void Voice_PortamentoTarget_ComputePitch(unsigned char part, unsigned char slot)
{
    unsigned int k;
    unsigned long l;
    unsigned int w;
    k = ((*(unsigned char **)&((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287))[(int)slot * 37 + 0x6e])[3]
         & 0x30) >> 4;
    l = *(unsigned long *)(ram_45314 + 112);
    w = *(unsigned int *)(ram_45314 + 236);
    ((unsigned long *)&((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287))[(int)slot * 37 + 0x6e])[2] =
        (unsigned long)w * k + l + ram_45310;
}
