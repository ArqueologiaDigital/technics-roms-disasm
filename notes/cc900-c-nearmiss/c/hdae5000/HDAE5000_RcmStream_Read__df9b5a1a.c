/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_store_ui.c (2026-11-17-13-hd-r42-ports)
   sha256 df9b5a1a905e09bf99d76951dfbda2595d55e5a89d590d33d74f99cac837ec24 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: RcmRead_b=HDAE5000_RcmStream_Read */
extern int HDAE5000_HD_ReadFile();
extern int HDAE5000_HD_ReadFileNext();
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned int HDAE5000_RAM_RcmStreamState;
extern unsigned int HDAE5000_RAM_RcmStreamDir;
extern unsigned int HDAE5000_RAM_RcmStreamSong;
extern int HDAE5000_RAM_RcmStreamResult;
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define RCM_SLOT SLOT(6, HDAE5000_RAM_RcmStreamDir, HDAE5000_RAM_RcmStreamSong)
unsigned long RcmRead_b(unsigned char *buf, unsigned long n)
{
    unsigned char *p;
    unsigned long cnt;

    switch (HDAE5000_RAM_RcmStreamState) {
    case 0:
        p = buf;
        cnt = n;
        HDAE5000_RAM_RcmStreamResult = HDAE5000_HD_ReadFile(p, cnt, &RCM_SLOT);
        HDAE5000_RAM_RcmStreamState = 1;
        break;
    case 1:
        p = buf;
        cnt = n;
        HDAE5000_RAM_RcmStreamResult = HDAE5000_HD_ReadFileNext(p, cnt, &RCM_SLOT);
        HDAE5000_RAM_RcmStreamState = 1;
        break;
    default:
        HDAE5000_RAM_RcmStreamResult = -1;
        HDAE5000_RAM_RcmStreamState = 0;
        break;
    }
    return n;
}
