/* Functions of hdae5000_ui_display.s.  (hdae5000_record_addr.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_record_addr.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
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
