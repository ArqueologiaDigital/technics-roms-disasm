/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_P_17b.c (2026-11-16-126-sub-r17)
   sha256 0e0a840326316c81afba23a05abfb073bad3f8133f4552d566393030e1a46134 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
void Voice_PortamentoTargets_SetAll(unsigned char part)
{
    unsigned int i;
    unsigned int v;
    for (i = 0; i < 4; i++) {
        v = (*(unsigned char **)((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287) + ((unsigned long)i * 37 + 0x6e)))[2];
        v |= (unsigned int)(*(unsigned char **)((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287) + ((unsigned long)i * 37 + 0x6e)))[3] << 8;
        *(unsigned int *)&((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287))[(unsigned long)i * 2 + 0x102] = v & 0xfff;
    }
}
