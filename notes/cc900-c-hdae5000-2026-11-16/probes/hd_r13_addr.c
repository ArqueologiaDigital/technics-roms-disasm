/* lane_hd round 13: the three record-address functions with a converted return value.  Run 2026-11-16-70-hd-r13v:
   DirName_Address's ROM (the index, then `ld xhl, sym` as an immediate, `add xhl, xwa`) comes from a return
   value converted to void * (DNA_s9) or to an integer (DNA_s8); an unconverted pointer gives lda.
   cc900-name: FlsRecAddr_b=HDAE5000_FlsRecord_Address
   cc900-name: SongRecAddr_b=HDAE5000_SongRecord_Address
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

void *FlsRecAddr_b(unsigned int fls)
{
    return (void *)(HDAE5000_RAM_DirNames + (unsigned long)fls * 144 + 0x24180L);
}

void *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song)
{
    return (void *)(HDAE5000_RAM_DirNames + ((unsigned long)dir * 0x4c0 + 0x780 + (unsigned long)song * 76));
}

void *SongRecAddr_b(unsigned int dir, unsigned int song)
{
    return (void *)(HDAE5000_RAM_DirNames + ((unsigned long)song * 76 + ((unsigned long)dir * 0x4c0 + 0x780)));
}
