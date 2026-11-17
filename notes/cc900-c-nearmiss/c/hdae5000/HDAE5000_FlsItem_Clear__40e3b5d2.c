/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_ui_display.c (2026-11-16-78-hd-r15-ports)
   sha256 40e3b5d21bd62b3b641f04dd0a04e540a222400640e18ed3c33d25071d1b65c7 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLS(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
int HDAE5000_FlsItem_Clear(unsigned int fls, unsigned int item)
{
    FLS(16, fls, item) = 0;
    FLS(48, fls, item) = 0;
    FLS(80, fls, item) = 0;
    FLS(112, fls, item) = 0;
    return 0;
}
