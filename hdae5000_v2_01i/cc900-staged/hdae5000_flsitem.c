/* hdae5000_v2_01i: the functions of hdae5000/cc900-staged/hdae5000_flsitem.c that V4.23 reproduces unchanged in HD-AE5000 v2.01i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_flsitem.c.
   cc900-options: -Xr
*/
extern unsigned char HDAE5000_RAM_FlsRecords[];
extern unsigned char HDAE5000_FlsItem_SongRecord_Str_Blank26[];

struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };

#define HD_TABLES ((unsigned char *)0x201632L)
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))

int HDAE5000_FlsItem_IsSet(unsigned int fls, unsigned int item)
{
    int r = 0;
    if (FLSB(16, fls, item) == 0 || FLSB(48, fls, item) == 0)
        r = -1;
    return r;
}
