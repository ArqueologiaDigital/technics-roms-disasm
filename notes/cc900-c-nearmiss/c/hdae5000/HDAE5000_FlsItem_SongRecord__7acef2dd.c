/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_flsitem2.c (2026-11-17-17-hd-r45-ports)
   sha256 7acef2dd73a6f56c2491dd150c7817f8a84715aaa667857864a17956dbcea9d9 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_FlsRecords[];
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_FlsItem_SongRecord_Str_Blank26[];
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define DIRPART(f, i) ((unsigned long)(unsigned char)(FLSB(16, f, i) - 1) * 0x4c0 + 0x780)
int HDAE5000_FlsItem_IsSet(unsigned int fls, unsigned int item);
unsigned char *HDAE5000_FlsItem_SongRecord(unsigned int fls, unsigned int item)
{
    int r;
    int sofs;
    (void)&sofs;
    (void)&fls;
    r = HDAE5000_FlsItem_IsSet(fls, item);
    if (r != -1) {
        sofs = (int)(FLSB(48, fls, item) - 1) * 76;
        return (void *)(HDAE5000_RAM_DirNames + ((long)sofs + DIRPART(fls, item)));
    } else
        return HDAE5000_FlsItem_SongRecord_Str_Blank26;
}
