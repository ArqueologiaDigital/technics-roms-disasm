/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_pport_services3.c (2026-11-16-119-hd-r30)
   sha256 f36374cb8afe9465f3927de19de80a4da61ab24af776dfcd0fbcc794271fe51c (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: PP_Svc27=HDAE5000_PPORT_Svc27_DeleteSongParts */
extern unsigned char HDAE5000_RAM_PportInfoBlock[];
#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
extern int HDAE5000_DeleteSongParts(unsigned int dir, unsigned int song, unsigned int mask, int spin, int sleep);
int PP_Svc27(unsigned int dir, unsigned int song)
{
    HDAE5000_DeleteSongParts(dir, song, PP_W(0), 0, 1);
    return 0;
}
