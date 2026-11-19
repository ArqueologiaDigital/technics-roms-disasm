/* hdae5000_v2_01i: the functions of hdae5000/cc900/hdae5000_fdlyric_addtlx.c that V4.23 reproduces in HD-AE5000 v2.01i with the tree's own object ids and ram_ addresses (port_built.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_fdlyric_addtlx.c.
   cc900-options: -Xr
   cc900-name: AddTlx_b=HDAE5000_FdLyricList_AddTlx
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
/* HDAE5000_RAM_FdLyricNames as a flat char array, and the row before it (HDAE5000_RAM_FdLyricNames - 9) */
extern char ram_230828[], ram_23081f[];
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

/* the names as a flat char array: indexed with the int product */
#define FLAT ((char *)HDAE5000_RAM_FdLyricNames)

/* AddTlx_b: flat extern arrays, no cast; the row before the first is its own extern */
long AddTlx_b(char *name)
{
    int j;
    int k;
    char tmp[50];
    char base[50];

    HDAE5000_StrCpy(tmp, name);
    HDAE5000_StrRev(tmp);
    HDAE5000_StrUpr(tmp);
    if (HDAE5000_StrNCmp(tmp, HDAE5000_Str_XLT, 4) == 0) {
        if (HDAE5000_RAM_FdLyricCount >= 40)
            return -1L;
        HDAE5000_StrRev(tmp);
        HDAE5000_StrCpy(base, tmp);
        base[HDAE5000_StrLen(base) - 4] = 0;
        if (HDAE5000_RAM_FdLyricCount == 0) {
            HDAE5000_StrCpy((char *)HDAE5000_RAM_FdLyricNames, base);
            HDAE5000_RAM_FdLyricCount++;
            return 0;
        }
        for (j = 0; j < HDAE5000_RAM_FdLyricCount; j++) {
            if (HDAE5000_StrPrefixCmp(base, &ram_230828[j * 9]) < 0) {
                for (k = HDAE5000_RAM_FdLyricCount; k > j; k--)
                    HDAE5000_StrCpy(&ram_230828[k * 9], &ram_23081f[k * 9]);
                HDAE5000_StrCpy(&ram_230828[j * 9], base);
                HDAE5000_RAM_FdLyricCount++;
                return 0;
            }
        }
        HDAE5000_StrCpy((char *)HDAE5000_RAM_FdLyricNames[HDAE5000_RAM_FdLyricCount], base);
        HDAE5000_RAM_FdLyricCount++;
        return 0;
    }
    return 0;
}

/* AddTlx_c: the int product on the LEFT of a pointer sum */

/* AddTlx_d: an INTEGER sum, the int product (converted implicitly) + the address as an unsigned long */

/* AddTlx_e: a pointer plus the int product converted to long by a cast */
