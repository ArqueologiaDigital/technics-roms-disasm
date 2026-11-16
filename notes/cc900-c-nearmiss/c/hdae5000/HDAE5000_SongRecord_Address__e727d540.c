/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_record_addr.c (2026-11-16-78-hd-r15-ports)
   sha256 e727d540b359b7fbaa5252753cd1a651bbaa302170093541f1e99c0a286590f8 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_DirNames[];
void *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song)
{
    return (void *)(HDAE5000_RAM_DirNames + ((unsigned long)dir * 0x4c0 + 0x780 + (unsigned long)song * 76));
}
