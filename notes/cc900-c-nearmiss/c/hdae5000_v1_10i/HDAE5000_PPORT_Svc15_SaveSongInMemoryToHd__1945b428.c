/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_pport_services3.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 1945b4284c5b3d14a25d4ea91b610a8cbe68d48a535930762493d2e9becad956 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: PP_Svc15=HDAE5000_PPORT_Svc15_SaveSongInMemoryToHd */
extern unsigned char HDAE5000_RAM_PportInfoBlock[];
#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
extern char ram_2f922c[], ram_2f924c[];
extern int HDAE5000_SaveSong(unsigned int dir, unsigned int song, char *name, unsigned int mask, int sleep,
                             int spin);
int PP_Svc15(unsigned int dir, unsigned int song)
{
    int ret;

    ret = 0;
    if (HDAE5000_SaveSong(dir, song, (char *)(PPIB + 2), PP_W(0), 0, 1) == -1)
        ret = 1;
    HDAE5000_DebugTrace(ram_2f922c);
    HDAE5000_DebugTrace(ram_2f924c);
    return ret;
}
