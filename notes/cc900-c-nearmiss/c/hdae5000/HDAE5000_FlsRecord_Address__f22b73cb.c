/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r2_sa.c (2026-11-16-46-hd-r2)
   sha256 f22b73cb3afdbf85fcd3d7dffd37d05cc78579c6e234ff1cad43a2f0eafce6b3 (tar-sha256); compiled at -Xr */
#define HD_TABLES ((unsigned char *)0x201632)
unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls)
{
    return HD_TABLES + ((unsigned long)fls * 144 + 0x24180L);
}
