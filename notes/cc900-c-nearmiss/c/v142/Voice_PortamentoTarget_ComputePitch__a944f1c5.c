/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_J_14a.c (2026-11-16-101-sub-r14)
   sha256 a944f1c52415e6e1c03fb4623e52d68614c4bd36f48256be4e7ae26f3d432bdd (name+funcs); compiled at -Xr */
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
    *(unsigned long *)(&((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287))[(int)slot * 37 + 0x6e] + 8) =
        (unsigned long)w * k + l + ram_45310;
}
