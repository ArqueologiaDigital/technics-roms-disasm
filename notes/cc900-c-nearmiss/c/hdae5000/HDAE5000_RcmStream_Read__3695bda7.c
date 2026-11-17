/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r39_m3b.c (2026-11-17-10-hd-r39)
   sha256 3695bda71e64e55cd01ff004d90144df363e3f0394e6ed79b16abe74b7803c5a (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
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
unsigned long HDAE5000_RcmStream_Read(unsigned char *buf, unsigned long n)
{
    unsigned long cnt;
    unsigned char *p;

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
