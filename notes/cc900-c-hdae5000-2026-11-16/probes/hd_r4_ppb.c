/* lane_hd round 4, helper h_pport, form b: second spellings of four functions of the PC-link (PPORT) service module
   (hd_r4_ppa.c holds the whole module and its reasoning).  Options: -Xr.
   - HDAE5000_DebugTrace with an explicit `return;`: whether V4.23 then leaves the ROM's second `ret` (0x294415);
   - Svc21 / Svc24: the song record addressed with byte arithmetic, the field offset written into the index
     (i * 4 + 36, i + 26), instead of the struct member;
   - Svc22: nested ifs instead of &&.
   cc900-name: PP_Svc21=HDAE5000_PPORT_Svc21_WriteOpenHD
   cc900-name: PP_Svc22=HDAE5000_PPORT_Svc22_WriteCloseHD
   cc900-name: PP_Svc24=HDAE5000_PPORT_Svc24_ReadOpenHD
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern unsigned char HDAE5000_RAM_PportInfoBlock[];
extern unsigned char HDAE5000_RAM_PportReadState;
extern unsigned char HDAE5000_RAM_DirNames[];

#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)

extern char ram_2f92e2[];                                                 /* Svc21 WriteOpenHD banner */
extern char ram_2f9306[];                                                 /* Svc22 */
extern char ram_2f9336[];                                                 /* Svc24 */
#define F_SUFFIX    ((char *)0x2f92faL)

extern int __cdecl HDAE5000_SPrintf(char *, const char *, ...);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
extern int HDAE5000_HD_StoreTables(int spin);
extern int HDAE5000_HD_WriteOpen(unsigned long *slot);
extern int HDAE5000_HD_WriteClose(void);

void HDAE5000_DebugTrace(char *s)
{
    return;
}

int PP_Svc21(unsigned int dir, unsigned int song)
{
    char buf[20];
    unsigned char i;
    int ret;
    unsigned int mask;

    ret = 1;
    HDAE5000_DebugTrace(ram_2f92e2);
    mask = PP_W(0);
    for (i = 0; i < 9; i++) {
        if (mask & 1) {
            if (HDAE5000_HD_WriteOpen((unsigned long *)(HDAE5000_RAM_DirNames + SONG_OFS(dir, song) + (i * 4 + 36)))
                != -1) {
                HDAE5000_StrNCpy((char *)(HDAE5000_RAM_DirNames + SONG_OFS(dir, song)), (char *)(PPIB + 2), 26);
                (HDAE5000_RAM_DirNames + SONG_OFS(dir, song))[i + 26] = 1;
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

int PP_Svc22(void)
{
    int ret;

    ret = 1;
    if (HDAE5000_HD_WriteClose() != -1)
        if (HDAE5000_HD_StoreTables(1) != -1)
            ret = 0;
    HDAE5000_DebugTrace(ram_2f9306);
    return ret;
}

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
            *(unsigned long **)(PPIB + 206) =
                (unsigned long *)(HDAE5000_RAM_DirNames + SONG_OFS(dir, song) + (i * 4 + 36));
            HDAE5000_RAM_PportReadState = 1;
            ret = 0;
            break;
        }
        mask >>= 1;
    }
    return ret;
}
