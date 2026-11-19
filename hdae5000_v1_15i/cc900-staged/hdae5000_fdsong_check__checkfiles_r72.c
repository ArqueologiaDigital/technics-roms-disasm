/* hdae5000_v1_15i: per-tree C written from the tree's hand source, MATCH in run 2026-11-19-60-hd-r72-v1parts (hd_r72p_fdsong_check__checkfiles.c).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r72p_fdsong_check__checkfiles.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_CheckFileSignature
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);     /* no const: the pushed extensions stay constants */

extern unsigned char HDAE5000_RAM_HdStreamBuffer[];

/* HDAE5000_FdSong_CheckFiles_Str_<EXT> (pushed) and _Str_rb, _Str_rb_2 .. _rb_8 (lda), v1.15i addresses */
extern char ram_2e09be[], ram_2e09c4[], ram_2e09ca[], ram_2e09d4[], ram_2e09de[], ram_2e09e8[];
extern char ram_2e09f2[], ram_2e09fa[], ram_2e0a04[], ram_2e0a0e[];
extern char ram_2e09d0[], ram_2e09da[], ram_2e09e4[], ram_2e09ee[], ram_2e09f6[];
extern char ram_2e0a00[], ram_2e0a0a[], ram_2e0a12[];

/* defined in hdae5000_fdsong_sig.c (same original module: cc900-module above); its prototype decides how the
   buffer argument is converted, so it must be visible here */
extern int HDAE5000_CheckFileSignature(unsigned int part, const unsigned char *buf);

/* v1.15i: eight song parts, so no "mask & 0x100" (TLX) block */
int HDAE5000_FdSong_CheckFiles(char *name, unsigned int mask)
{
    long h;
    unsigned char ff[266];
    char path[13];

    HDAE5000_MemFill(path, 0, 13);
    HDAE5000_MemCopy(path, name, 8);
    HDAE5000_StrCpy(&path[8], ram_2e09be);
    if ((h = CALLR(long, HAMA->findfirst)(path, (void *)ff)) != -1L) {
        CALLV(HAMA->findclose)(h);
        return -1;
    }
    HDAE5000_StrCpy(&path[8], ram_2e09c4);
    if ((h = CALLR(long, HAMA->findfirst)(path, (void *)ff)) != -1L) {
        CALLV(HAMA->findclose)(h);
        return -1;
    }
    if (mask & 0x001) {
        HDAE5000_StrCpy(&path[8], ram_2e09ca);
        CALLV(HAMA->fopen_ext)(path, ram_2e09d0);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(0, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x002) {
        HDAE5000_StrCpy(&path[8], ram_2e09d4);
        CALLV(HAMA->fopen_ext)(path, ram_2e09da);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(1, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x004) {
        HDAE5000_StrCpy(&path[8], ram_2e09de);
        CALLV(HAMA->fopen_ext)(path, ram_2e09e4);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(2, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x008) {
        HDAE5000_StrCpy(&path[8], ram_2e09e8);
        CALLV(HAMA->fopen_ext)(path, ram_2e09ee);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(3, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x010) {
        HDAE5000_StrCpy(&path[8], ram_2e09f2);
        CALLV(HAMA->fopen_ext)(path, ram_2e09f6);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(4, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x020) {
        HDAE5000_StrCpy(&path[8], ram_2e09fa);
        CALLV(HAMA->fopen_ext)(path, ram_2e0a00);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(5, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x040) {
        HDAE5000_StrCpy(&path[8], ram_2e0a04);
        CALLV(HAMA->fopen_ext)(path, ram_2e0a0a);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(6, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x080) {
        HDAE5000_StrCpy(&path[8], ram_2e0a0e);
        CALLV(HAMA->fopen_ext)(path, ram_2e0a12);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(7, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    return 0;
}
