/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_pport_services3.c (2026-11-16-117-hd-r29-staged)
   sha256 d02261e790403f69cc316f78d7152dcfd5ed756f754a464df3598d1d7ee5dd48 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: PP_Svc14=HDAE5000_PPORT_Svc14_LoadSongFromHdToMemory */
extern unsigned char HDAE5000_RAM_PportInfoBlock[];
#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
extern char ram_2f9208[], ram_2f922a[];
extern int HDAE5000_LoadSong(unsigned int dir, unsigned int song, unsigned int mask, int spin, int sleep);
int PP_Svc14(unsigned int dir, unsigned int song)
{
    int ret;

    ret = 0;
    if (HDAE5000_LoadSong(dir, song, PP_W(0), 0, 1) == -1)
        ret = 1;
    HDAE5000_DebugTrace(ram_2f9208);
    HDAE5000_DebugTrace(ram_2f922a);
    return ret;
}
