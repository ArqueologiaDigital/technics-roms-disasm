/* hdae5000_v2_01i: the functions of hdae5000/cc900/hdae5000_fdlyric.c that V4.23 reproduces in HD-AE5000 v2.01i with the tree's own object ids and ram_ addresses (port_built.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_fdlyric.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_FdLyricList_AddTlx
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrCat(char *, char *);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern int __cdecl HDAE5000_StrNCmp(char *, char *, unsigned int);
extern int __cdecl HDAE5000_StrPrefixCmp(char *, char *);
extern char *__cdecl HDAE5000_StrRev(char *);
extern char *__cdecl HDAE5000_StrUpr(char *);

extern unsigned char HDAE5000_RAM_FdLyricNames[][9];
extern char HDAE5000_RAM_FdLyricTitles[][27];
extern unsigned char HDAE5000_RAM_FdLyricHasMid[];
extern unsigned int HDAE5000_RAM_FdLyricCount;
extern char HDAE5000_RAM_FdVolumeLabel[];
extern unsigned char ram_230e26;                /* HDAE5000_RAM_FdVolumeLabel + 8 */

extern char HDAE5000_Str_Chr202D3E[];           /* " ->" */
extern unsigned char HDAE5000_Str_Chr2A2E2A[];  /* "*.*", passed converted: the ROM evaluates it first */
extern char HDAE5000_Str_TTX[];
extern char HDAE5000_Str_Rb_FdLyricTtx[];
extern char HDAE5000_Str_MID[];
extern char HDAE5000_Str_Rb_FdLyricMid[];
extern char HDAE5000_Str_XLT[];

long HDAE5000_FdLyricList_AddTlx(char *name);

long HDAE5000_FdLyricList_Scan(void)
{
    long r;
    char fname[100];
    char ff[266];
    char *label;
    long h;
    unsigned int i;

    r = 0;
    switch (CALLR(unsigned char, HAMA->GetMediaType)()) {
    case 2:
    case 3:
        CALLV(ROOT->SleepMainTask)();
        if ((label = CALLR(char *, HAMA->GetVolumeLabel)()) != 0)
            HDAE5000_MemCopy(HDAE5000_RAM_FdVolumeLabel, label, HDAE5000_StrLen(label));
        else
            HDAE5000_RAM_FdVolumeLabel[0] = 0;
        ram_230e26 = 0;
        if (HDAE5000_StrLen(HDAE5000_RAM_FdVolumeLabel) != 0)
            HDAE5000_StrCat(HDAE5000_RAM_FdVolumeLabel, HDAE5000_Str_Chr202D3E);
        h = CALLR(long, HAMA->findfirst)((char *)HDAE5000_Str_Chr2A2E2A, (void *)ff);
        r = HDAE5000_FdLyricList_AddTlx(&ff[6]);
        while (CALLR(int, HAMA->findnext)(h, (void *)ff) == 0)
            r = HDAE5000_FdLyricList_AddTlx(&ff[6]);
        CALLV(HAMA->findclose)(h);
        for (i = 0; i < HDAE5000_RAM_FdLyricCount; i++) {
            HDAE5000_StrCpy(fname, (char *)HDAE5000_RAM_FdLyricNames[i]);
            HDAE5000_StrCat(fname, HDAE5000_Str_TTX);
            CALLV(HAMA->fopen_ext)(fname, HDAE5000_Str_Rb_FdLyricTtx);
            CALLV(HAMA->fread_ext)(HDAE5000_RAM_FdLyricTitles[i], 26L);
            CALLV(HAMA->fclose_ext)();
            HDAE5000_StrCpy(fname, (char *)HDAE5000_RAM_FdLyricNames[i]);
            HDAE5000_StrCat(fname, HDAE5000_Str_MID);
            if (CALLR(int, HAMA->fopen_ext)(fname, HDAE5000_Str_Rb_FdLyricMid) >= 0)
                HDAE5000_RAM_FdLyricHasMid[i] = 1;
            else
                HDAE5000_RAM_FdLyricHasMid[i] = 0;
            CALLV(HAMA->fclose_ext)();
        }
        CALLV(ROOT->WakeUpMainTask)();
    }
    return r;
}
