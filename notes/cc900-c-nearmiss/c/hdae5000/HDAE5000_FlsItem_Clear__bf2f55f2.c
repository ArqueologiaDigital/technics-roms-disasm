/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r4_v.c (2026-11-16-52-hd-r4v)
   sha256 bf2f55f2cf270e39762beedb9ea0ca916ea5999abfe5b3ec7d6722e42ee0aa74 (tar-sha256); compiled at -Xr
   cc900-name: FlsItemClear_i1=HDAE5000_FlsItem_Clear */
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLS_I1(o, f, i) (*(unsigned char *)((unsigned long)HDAE5000_RAM_FlsRecords + (o) + ((unsigned long)(f) * 144 + (i))))
int FlsItemClear_i1(unsigned int fls, unsigned int item)
{
    FLS_I1(16, fls, item) = 0;
    FLS_I1(48, fls, item) = 0;
    FLS_I1(80, fls, item) = 0;
    FLS_I1(112, fls, item) = 0;
    return 0;
}
