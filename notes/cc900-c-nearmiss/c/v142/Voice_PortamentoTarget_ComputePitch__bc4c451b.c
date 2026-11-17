/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_J_14b.c (2026-11-16-101-sub-r14)
   sha256 bc4c451bbb9fb863ec20e0cf12e808971bf6d9c87b958c7ad339bfeaa5661dac (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned long ram_45310;
extern unsigned char *ram_45314;
struct pslot3 { unsigned char *src; unsigned char *tone; unsigned long pitch; };
void Voice_PortamentoTarget_ComputePitch(unsigned char part, unsigned char slot)
{
    unsigned int k;
    unsigned long l;
    unsigned int w;
    k = ((*(unsigned char **)&((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287))[(int)slot * 37 + 0x6e])[3]
         & 0x30) >> 4;
    l = *(unsigned long *)(ram_45314 + 112);
    w = *(unsigned int *)(ram_45314 + 236);
    ((struct pslot3 *)((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287) + ((int)slot * 37 + 0x6e)))->pitch =
        (unsigned long)w * k + l + ram_45310;
}
