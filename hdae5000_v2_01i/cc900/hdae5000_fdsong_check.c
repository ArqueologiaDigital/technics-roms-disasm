/* Functions of hdae5000_ui_display.s.  (hdae5000_fdsong_check.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_fdsong_check.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-module: HDAE5000_CheckFileSignature
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);     /* no const: the pushed extensions stay constants */
extern int __cdecl HDAE5000_StrNCmp(char *, char *, int);

struct PartSig { char *sig; unsigned int offset; unsigned int len; };
extern struct PartSig HDAE5000_PartSignatureTable[];
extern unsigned char HDAE5000_PartSignatureTable_FileOffset[];
extern unsigned char HDAE5000_PartSignatureTable_Length[];

extern unsigned char HDAE5000_RAM_HdStreamBuffer[];

/* HDAE5000_FdSong_CheckFiles_Str_<EXT> (pushed) and _Str_rb, _Str_rb_2 .. _rb_9 (lda) */
extern char ram_2f8392[], ram_2f8398[], ram_2f839e[], ram_2f83a8[], ram_2f83b2[], ram_2f83bc[];
extern char ram_2f83c6[], ram_2f83ce[], ram_2f83d8[], ram_2f83e2[], ram_2f83ea[];
extern char ram_2f83a4[], ram_2f83ae[], ram_2f83b8[], ram_2f83c2[], ram_2f83ca[];
extern char ram_2f83d4[], ram_2f83de[], ram_2f83e6[], ram_2f83f0[];

/* defined in hdae5000_fdsong_sig.c (same original module: cc900-module above); its prototype decides how the
   buffer argument is converted, so it must be visible here */
extern int HDAE5000_CheckFileSignature(unsigned int part, const unsigned char *buf);

int HDAE5000_FdSong_CheckFiles(char *name, unsigned int mask)
{
    long h;
    unsigned char ff[266];
    char path[13];

    HDAE5000_MemFill(path, 0, 13);
    HDAE5000_MemCopy(path, name, 8);
    HDAE5000_StrCpy(&path[8], ram_2f8392);
    if ((h = CALLR(long, HAMA->findfirst)(path, (void *)ff)) != -1L) {
        CALLV(HAMA->findclose)(h);
        return -1;
    }
    HDAE5000_StrCpy(&path[8], ram_2f8398);
    if ((h = CALLR(long, HAMA->findfirst)(path, (void *)ff)) != -1L) {
        CALLV(HAMA->findclose)(h);
        return -1;
    }
    if (mask & 0x001) {
        HDAE5000_StrCpy(&path[8], ram_2f839e);
        CALLV(HAMA->fopen_ext)(path, ram_2f83a4);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(0, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x002) {
        HDAE5000_StrCpy(&path[8], ram_2f83a8);
        CALLV(HAMA->fopen_ext)(path, ram_2f83ae);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(1, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x004) {
        HDAE5000_StrCpy(&path[8], ram_2f83b2);
        CALLV(HAMA->fopen_ext)(path, ram_2f83b8);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(2, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x008) {
        HDAE5000_StrCpy(&path[8], ram_2f83bc);
        CALLV(HAMA->fopen_ext)(path, ram_2f83c2);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(3, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x010) {
        HDAE5000_StrCpy(&path[8], ram_2f83c6);
        CALLV(HAMA->fopen_ext)(path, ram_2f83ca);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(4, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x020) {
        HDAE5000_StrCpy(&path[8], ram_2f83ce);
        CALLV(HAMA->fopen_ext)(path, ram_2f83d4);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(5, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x040) {
        HDAE5000_StrCpy(&path[8], ram_2f83d8);
        CALLV(HAMA->fopen_ext)(path, ram_2f83de);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(6, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x080) {
        HDAE5000_StrCpy(&path[8], ram_2f83e2);
        CALLV(HAMA->fopen_ext)(path, ram_2f83e6);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(7, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x100) {
        HDAE5000_StrCpy(&path[8], ram_2f83ea);
        CALLV(HAMA->fopen_ext)(path, ram_2f83f0);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(8, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    return 0;
}
