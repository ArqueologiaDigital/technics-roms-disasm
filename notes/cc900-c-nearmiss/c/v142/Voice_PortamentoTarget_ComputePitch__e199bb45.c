/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_J_15b.c (2026-11-16-106-sub-r15)
   sha256 e199bb4560049b8118a8582cd4489263612e735d814f9e8df555baeff6c6d16c (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned long ram_45310;
extern unsigned char *ram_45314;
struct pslot3 { unsigned char *src; unsigned char *tone; unsigned long pitch; };
void Voice_PortamentoTarget_ComputePitch(unsigned char part, unsigned char slot)
{
    struct pslot3 *s;
    unsigned int k;
    unsigned long l;
    unsigned int w;
    k = ((*(unsigned char **)&((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287))[(int)slot * 37 + 0x6e])[3]
         & 0x30) >> 4;
    l = *(unsigned long *)(ram_45314 + 112);
    w = *(unsigned int *)(ram_45314 + 236);
    s = (struct pslot3 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287))[(int)slot * 37 + 0x6e];
    s->pitch = (unsigned long)w * k + l + ram_45310;
}
