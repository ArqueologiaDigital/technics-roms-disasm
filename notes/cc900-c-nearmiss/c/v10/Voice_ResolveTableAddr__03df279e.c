/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_3a.c (2026-11-16-37-p6-r5)
   sha256 03df279e08d061b6a4b0bf032cc68e2919a4e28fd5d0f440994c7569f8fd9bf8 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near ram_3980;
extern unsigned int __near ram_3984;
unsigned char *Voice_ResolveTableAddr(void)
{
    unsigned long o;
    o = ram_3984;
    return (unsigned char *)(((unsigned long)ram_3980 << 8) + 0x95c00 + o);
}
