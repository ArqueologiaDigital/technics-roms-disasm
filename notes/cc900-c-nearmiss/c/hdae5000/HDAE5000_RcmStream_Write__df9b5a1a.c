/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_store_ui.c (2026-11-17-13-hd-r42-ports)
   sha256 df9b5a1a905e09bf99d76951dfbda2595d55e5a89d590d33d74f99cac837ec24 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern int HDAE5000_HD_WriteStream(void *src, unsigned long n);
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned int HDAE5000_RAM_RcmStreamState;
extern unsigned int HDAE5000_RAM_RcmStreamDir;
extern unsigned int HDAE5000_RAM_RcmStreamSong;
extern int HDAE5000_RAM_RcmStreamResult;
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define HAS(k, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[26 + (k)] + SONG_OFS(d, s)))
#define RCM_HAS HAS(6, HDAE5000_RAM_RcmStreamDir, HDAE5000_RAM_RcmStreamSong)
unsigned long HDAE5000_RcmStream_Write(unsigned char *data, unsigned long n)
{
    int ret;

    switch (HDAE5000_RAM_RcmStreamState) {
    case 0:
        if (HDAE5000_HD_WriteStream(data, n) != -1) {
            ret = 0;
            RCM_HAS = 1;
            HDAE5000_RAM_RcmStreamState = 2;
        } else {
            ret = -1;
        }
        HDAE5000_RAM_RcmStreamResult = ret;
        break;
    case 2:
        if (HDAE5000_HD_WriteStream(data, n) != -1) {
            ret = 0;
            RCM_HAS = 1;
            HDAE5000_RAM_RcmStreamState = 2;
        } else {
            ret = -1;
        }
        HDAE5000_RAM_RcmStreamResult = ret;
        break;
    default:
        HDAE5000_RAM_RcmStreamResult = -1;
        HDAE5000_RAM_RcmStreamState = 0;
        break;
    }
    return n;
}
