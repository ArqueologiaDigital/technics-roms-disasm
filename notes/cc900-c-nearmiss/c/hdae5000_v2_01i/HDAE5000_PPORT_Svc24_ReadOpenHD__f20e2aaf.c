/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_pport_svc2.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 f20e2aaf8e26d9a7427909f5a5c99f1dcfb2002cb2365e8473f65bfdaf0db0de (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: PP_Svc24=HDAE5000_PPORT_Svc24_ReadOpenHD */
struct SongRec { unsigned char name[26]; unsigned char part[10]; unsigned long slot[9]; unsigned char tail[4]; };
extern unsigned char HDAE5000_RAM_PportInfoBlock[];
extern unsigned char HDAE5000_RAM_PportReadState;
extern unsigned char HDAE5000_RAM_DirNames[];
#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SREC(d, s) ((struct SongRec *)(HDAE5000_RAM_DirNames + SONG_OFS(d, s)))
extern char ram_2f9336[];
extern void HDAE5000_DebugTrace(char *s);
int PP_Svc24(unsigned int dir, unsigned int song)
{
    int ret;
    unsigned char i;
    unsigned int mask;

    ret = 1;
    HDAE5000_DebugTrace(ram_2f9336);
    mask = PP_W(0);
    for (i = 0; i < 9; i++) {
        if (mask & 1) {
            *(unsigned long **)(PPIB + 206) = &SREC(dir, song)->slot[i];
            HDAE5000_RAM_PportReadState = 1;
            ret = 0;
            break;
        }
        mask >>= 1;
    }
    return ret;
}
