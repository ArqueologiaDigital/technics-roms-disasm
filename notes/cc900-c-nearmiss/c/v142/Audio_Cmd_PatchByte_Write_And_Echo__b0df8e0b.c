/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_4b.c (2026-11-16-62-sub-r4)
   sha256 b0df8e0b49e3477310bfbc8eb1db4d0a27fc8cbcb08ab817f13c8569d38158d2 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern void InterCPU_E1_DMA_Transfer(unsigned char *src, unsigned int n, unsigned char *dst);
void Audio_Cmd_PatchByte_Write_And_Echo(unsigned char *m)
{
    unsigned char *p;
    unsigned char *mm;
    p = *(unsigned char **)(ram_4136e + m[1] * 0x11f);
    p += (unsigned long)m[2];
    *p = m[4];
    mm = (unsigned char *)0x1e0000;
    InterCPU_E1_DMA_Transfer(p, 1, &mm[0x4980] + (unsigned long)m[2]);
}
