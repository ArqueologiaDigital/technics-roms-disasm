/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r2b_v.c (2026-11-16-48-hd-r2b)
   sha256 49540712cd213461f2e0e6eb09ea564cb2aba3301e433f679d2e79c412a1caf6 (tar-sha256); compiled at -Xr
   cc900-name: FlsItemClear_v1=HDAE5000_FlsItem_Clear */
extern unsigned char HDAE5000_RAM_FlsRecords[];
int FlsItemClear_v1(unsigned int fls, unsigned int item)
{
    (&HDAE5000_RAM_FlsRecords[16])[(unsigned long)fls * 144 + item] = 0;
    (&HDAE5000_RAM_FlsRecords[48])[(unsigned long)fls * 144 + item] = 0;
    (&HDAE5000_RAM_FlsRecords[80])[(unsigned long)fls * 144 + item] = 0;
    (&HDAE5000_RAM_FlsRecords[112])[(unsigned long)fls * 144 + item] = 0;
    return 0;
}
