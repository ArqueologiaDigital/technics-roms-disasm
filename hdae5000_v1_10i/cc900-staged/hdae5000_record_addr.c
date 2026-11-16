/* hdae5000_v1_10i: the functions of hdae5000/cc900-staged/hdae5000_record_addr.c that V4.23 reproduces unchanged in HD-AE5000 v1.10i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_record_addr.c.
   cc900-options: -Xr
*/
extern unsigned char HDAE5000_RAM_DirNames[];

void *HDAE5000_DirName_Address(unsigned int dir)
{
    return (void *)(HDAE5000_RAM_DirNames + (unsigned long)dir * 16);
}

void *HDAE5000_FlsRecord_Address(unsigned int fls)
{
    return (void *)(HDAE5000_RAM_DirNames + ((unsigned long)fls * 144 + 0x24180L));
}

void *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song)
{
    return (void *)(HDAE5000_RAM_DirNames + ((unsigned long)dir * 0x4c0 + 0x780 + (unsigned long)song * 76));
}
