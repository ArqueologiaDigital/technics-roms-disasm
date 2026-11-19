/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hd_r72p_pport_svc2__svc21_svc24.c (2026-11-19-60-hd-r72-v1parts)
   sha256 9e30e54b8db6e2798723466689ef2dc048e094a925388705848c46e9e2c3e72d (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: PP_Svc21=HDAE5000_PPORT_Svc21_WriteOpenHD */
struct SongRec { unsigned char name[26]; unsigned char part[10]; unsigned long slot[9]; unsigned char tail[4]; };
extern unsigned char HDAE5000_RAM_PportInfoBlock[];
extern unsigned char HDAE5000_RAM_DirNames[];
#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SREC(d, s) ((struct SongRec *)(HDAE5000_RAM_DirNames + SONG_OFS(d, s)))
extern char ram_2e0de6[];
extern char ram_2e0dfe[];
#define F_SUFFIX ram_2e0dfe
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
extern int HDAE5000_HD_WriteOpen(unsigned long *slot);
extern void HDAE5000_DebugTrace(char *s);
int PP_Svc21(unsigned int dir, unsigned int song)
{
    char buf[20];
    int ret;
    unsigned char i;
    unsigned int mask;

    ret = 1;
    HDAE5000_DebugTrace(ram_2e0de6);
    mask = PP_W(0);
    for (i = 0; i < 8; i++) {
        if (mask & 1) {
            if (HDAE5000_HD_WriteOpen(&SREC(dir, song)->slot[i]) != -1) {
                HDAE5000_StrNCpy((char *)SREC(dir, song)->name, (char *)(PPIB + 2), 26);
                SREC(dir, song)->part[i] = 1;
                ret = 0;
            }
            HDAE5000_SPrintf(buf, F_SUFFIX, i);
            HDAE5000_DebugTrace(buf);
            break;
        }
        mask >>= 1;
    }
    return ret;
}
