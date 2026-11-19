/* hdae5000_v1_15i: per-tree C written from the tree's hand source, MATCH in run 2026-11-19-60-hd-r72-v1parts (hd_r72p_pport_svc2__svc21_svc24.c).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r72p_pport_svc2__svc21_svc24.c.
   cc900-options: -Xr
   cc900-name: PP_Svc21=HDAE5000_PPORT_Svc21_WriteOpenHD
   cc900-name: PP_Svc24=HDAE5000_PPORT_Svc24_ReadOpenHD
   cc900-module: HDAE5000_DebugTrace
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct SongRec { unsigned char name[26]; unsigned char part[10]; unsigned long slot[9]; unsigned char tail[4]; };

extern unsigned char HDAE5000_RAM_PportInfoBlock[];
extern unsigned char HDAE5000_RAM_PportReadState;
extern unsigned char HDAE5000_RAM_DirNames[];

#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SREC(d, s) ((struct SongRec *)(HDAE5000_RAM_DirNames + SONG_OFS(d, s)))

/* trace banners (HDAE5000_PPORT_SvcNN_*_Str_<name>), passed in XWA: lda */
extern char ram_2e0de6[];                                                 /* Svc21 */
extern char ram_2e0e3a[];                                                 /* Svc24 */

/* format string, stacked SPrintf argument: pushw hi16 / pushw lo16 */
extern char ram_2e0dfe[];
#define F_SUFFIX ram_2e0dfe

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
extern int HDAE5000_HD_WriteOpen(unsigned long *slot);
extern void HDAE5000_DebugTrace(char *s);

/* v1.15i: eight song parts, so the part loop runs i < 8 */
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

/* v1.15i: eight parts (i < 8), and the read slot pointer lives at PportInfoBlock + 4288 (0x23c4c0; v2.06i +206) */
int PP_Svc24(unsigned int dir, unsigned int song)
{
    int ret;
    unsigned char i;
    unsigned int mask;

    ret = 1;
    HDAE5000_DebugTrace(ram_2e0e3a);
    mask = PP_W(0);
    for (i = 0; i < 8; i++) {
        if (mask & 1) {
            *(unsigned long **)(PPIB + 4288) = &SREC(dir, song)->slot[i];
            HDAE5000_RAM_PportReadState = 1;
            ret = 0;
            break;
        }
        mask >>= 1;
    }
    return ret;
}
