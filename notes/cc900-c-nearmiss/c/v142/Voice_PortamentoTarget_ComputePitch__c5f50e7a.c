/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_J_15a.c (2026-11-16-106-sub-r15)
   sha256 c5f50e7a88fe21210df62b5741f6457969891b530386c788ce6a775e3ef002bc (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned long ram_45310;
extern unsigned char *ram_45314;
struct pslot3 { unsigned char *src; unsigned char *tone; unsigned long pitch; };
void Voice_PortamentoTarget_ComputePitch(unsigned char part, unsigned char slot)
{
    unsigned int k;
    unsigned long l;
    unsigned int w;
    struct pslot3 *s;
    k = ((*(unsigned char **)&((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287))[(int)slot * 37 + 0x6e])[3]
         & 0x30) >> 4;
    l = *(unsigned long *)(ram_45314 + 112);
    w = *(unsigned int *)(ram_45314 + 236);
    s = (struct pslot3 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287))[(int)slot * 37 + 0x6e];
    s->pitch = (unsigned long)w * k + l + ram_45310;
}
