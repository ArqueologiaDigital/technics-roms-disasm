/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_2b.c (2026-11-16-33-p6-r2)
   sha256 6466b0db5cc304449e230b5c4768605e1ab3bae7d08d95327934985fddd8f094 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near ram_3980;
extern unsigned int __near ram_3984;
unsigned char *Voice_ResolveTableAddr(void)
{
    return (unsigned char *)0x95c00 + ((unsigned long)ram_3980 << 8) + ram_3984;
}
