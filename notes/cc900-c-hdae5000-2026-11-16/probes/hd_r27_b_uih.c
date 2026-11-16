/* hd_r27_b_uih.c (helper h_r27b, lane_hd round 27): hd_r23_uih.c with AddTlx's row addresses respelled, and four
   named variants of AddTlx.  Run 102: FdLyricList_Scan matched but for its calr target; AddTlx could not be
   checked ("llvm-mc refused the translation"): V4.23's listing wrote the row before the first as
   `lda XWA,_HDAE5000_RAM_FdLyricNames + 0xfffffff7`, which the checker adds without wrapping to 32 bits
   (0x10023087b).  With that patched in memory (h_r27b/rshow4.py) AddTlx departs only in the four row addresses:
   ROM `muls wa,9; lda xbc,(Names:24); exts xwa; add xwa,xbc`, V4.23 (for `(char *)Names[0] + j * 9`)
   `muls; ld bc,wa; lda xwa,(Names); lda xwa,xwa+bc`.  The ROM widens the int product AFTER loading the base and
   adds the base to it.  Spellings here (none uses a negative offset, so the checker gap is avoided too: the row
   before the first is the extern ram_23087b):
   - HDAE5000_FdLyricList_AddTlx: the names as a flat char array through a cast, `&FLAT[j * 9]`, and
     `&FLAT[(k - 1) * 9]` for the shift's source (if V4.23 does not fold the -9 into the address, see _b);
   - AddTlx_b: flat extern arrays, `&ram_230884[j * 9]`, `&ram_23087b[k * 9]`;
   - AddTlx_c: the product on the left of a pointer sum, `j * 9 + ram_230884`;
   - AddTlx_d: an integer sum, `(char *)(j * 9 + (unsigned long)&ram_230884[0])`;
   - AddTlx_e: `ram_230884 + (long)(j * 9)`.
   cc900-name: AddTlx_b=HDAE5000_FdLyricList_AddTlx
   cc900-name: AddTlx_c=HDAE5000_FdLyricList_AddTlx
   cc900-name: AddTlx_d=HDAE5000_FdLyricList_AddTlx
   cc900-name: AddTlx_e=HDAE5000_FdLyricList_AddTlx
   hd_r23_uih.c's header follows.
   hd_r23_uih.c (helper h_nm3b, lane_hd round 23): HDAE5000_FdLyricList_Scan and HDAE5000_FdLyricList_AddTlx
   (hdae5000_ui_display.s), in ROM order; calr group HDAE5000_FDFileSelectProc HDAE5000_FdLyricList_AddTlx
   HDAE5000_FdLyricList_Scan (FDFileSelectProc is not in this file).  Round 20's hd_r20_uih.c with these changes,
   from run 95:
   - Scan: StrLen takes `const char *` (its argument is converted: the ROM evaluates it first, `lda xwa,(sym);
     push xwa` for the volume label and `ld xwa,xiz; push xwa` for the returned label, where V4.23 pushed the
     constant / XIZ); StrCat keeps `char *`, so the volume label it gets is pushed as a constant (`pushw 35;
     pushw 3706` = HDAE5000_RAM_FdVolumeLabel@hi16/@lo16; r20's `(char *)0x230e7aL` gave `ld xwa,imm`).
     The label is tested as an assignment's value, `if ((label = ..()) != 0)` (the ROM reads it back:
     `ld xiz,xhl; ld xwa,xiz; or xwa,xwa`; r20 gave `or xiz,xiz`).  ff is converted for findfirst and findnext,
     `(void *)ff` (the ROM evaluates it first: `lda xwa,(xsp+8); ld xbc,xwa`), and declared after fname (ROM: ff
     at xsp+8, fname at xsp+274; V4.23 lays arrays out in reverse declaration order).
   - AddTlx: tmp declared before base (ROM: base at xsp+4, tmp above it); the sorted-insert rows are addressed as
     `(char *)HDAE5000_RAM_FdLyricNames[0] + j * 9` (the ROM multiplies the int, `muls wa,9`, then adds a converted
     base, `lda xbc,(HDAE5000_RAM_FdLyricNames:24); exts xwa; add xwa,xbc`; r20's `Names[j]` gave `exts; sll;
     add; ld xwa,imm`), the shift loop's source as `(char *)HDAE5000_RAM_FdLyricNames[-1] + k * 9` (the ROM's
     `lda xbc,(HDAE5000_RAM_FdLyricNames-9:24)` after `muls`, no `dec`).
   The library string routines otherwise take char * (not const char *) so that a ROM label pushed as an argument
   is a constant (pushw @hi16 / @lo16).
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
/* HDAE5000_RAM_FdLyricNames as a flat char array, and the row before it (HDAE5000_RAM_FdLyricNames - 9) */
extern char ram_230884[], ram_23087b[];
extern char HDAE5000_RAM_FdVolumeLabel[];
extern unsigned char ram_230e82;                /* HDAE5000_RAM_FdVolumeLabel + 8 */

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
        ram_230e82 = 0;
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

/* the names as a flat char array: indexed with the int product */
#define FLAT ((char *)HDAE5000_RAM_FdLyricNames)

long HDAE5000_FdLyricList_AddTlx(char *name)
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
            if (HDAE5000_StrPrefixCmp(base, &FLAT[j * 9]) < 0) {
                for (k = HDAE5000_RAM_FdLyricCount; k > j; k--)
                    HDAE5000_StrCpy(&FLAT[k * 9], &FLAT[(k - 1) * 9]);
                HDAE5000_StrCpy(&FLAT[j * 9], base);
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
            if (HDAE5000_StrPrefixCmp(base, &ram_230884[j * 9]) < 0) {
                for (k = HDAE5000_RAM_FdLyricCount; k > j; k--)
                    HDAE5000_StrCpy(&ram_230884[k * 9], &ram_23087b[k * 9]);
                HDAE5000_StrCpy(&ram_230884[j * 9], base);
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
long AddTlx_c(char *name)
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
            if (HDAE5000_StrPrefixCmp(base, j * 9 + ram_230884) < 0) {
                for (k = HDAE5000_RAM_FdLyricCount; k > j; k--)
                    HDAE5000_StrCpy(k * 9 + ram_230884, k * 9 + ram_23087b);
                HDAE5000_StrCpy(j * 9 + ram_230884, base);
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

/* AddTlx_d: an INTEGER sum, the int product (converted implicitly) + the address as an unsigned long */
long AddTlx_d(char *name)
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
            if (HDAE5000_StrPrefixCmp(base, (char *)(j * 9 + (unsigned long)&ram_230884[0])) < 0) {
                for (k = HDAE5000_RAM_FdLyricCount; k > j; k--)
                    HDAE5000_StrCpy((char *)(k * 9 + (unsigned long)&ram_230884[0]),
                                    (char *)(k * 9 + (unsigned long)&ram_23087b[0]));
                HDAE5000_StrCpy((char *)(j * 9 + (unsigned long)&ram_230884[0]), base);
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

/* AddTlx_e: a pointer plus the int product converted to long by a cast */
long AddTlx_e(char *name)
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
            if (HDAE5000_StrPrefixCmp(base, ram_230884 + (long)(j * 9)) < 0) {
                for (k = HDAE5000_RAM_FdLyricCount; k > j; k--)
                    HDAE5000_StrCpy(ram_230884 + (long)(k * 9), ram_23087b + (long)(k * 9));
                HDAE5000_StrCpy(ram_230884 + (long)(j * 9), base);
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
