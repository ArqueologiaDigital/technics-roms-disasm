/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r54_misc_fls.c (2026-11-18-20-hd-r55)
   sha256 1d3188e2f76bcc604c417e618ea07e1847791ea24fcf89aea36f53ddde9e68ff (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: FlsItemSetSong_b=HDAE5000_FlsItem_SetSong */
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
int FlsItemSetSong_b(unsigned int fls, unsigned int item, unsigned char song)
{
    FLSB(48, fls, item) = song + 1;
    return 0;
}
