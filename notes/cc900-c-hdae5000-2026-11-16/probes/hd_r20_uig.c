/* hd_r20_uig.c (helper h_ui, lane_hd round 20): the calr group HDAE5000_CheckFileSignature +
   HDAE5000_FdSong_CheckFiles (hdae5000_ui_display.s), in ROM order.
   The labels HDAE5000_FdSong_CheckFiles_Str_* share their first 31 characters, so (as in
   cc900/hdae5000_song_module.c) the extensions, pushed as 32-bit constants, are numeric constants and the "rb"
   modes, loaded with lda, are ram_<hex> externs.  hd_r20_uig2.c writes them as string literals instead.
   cc900-options: -Xr
   cc900-module: HDAE5000_CheckFileSignature
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);     /* no const: the pushed extensions stay constants */
extern int __cdecl HDAE5000_StrNCmp(char *, char *, unsigned int);

struct PartSig { char *sig; unsigned int offset; unsigned int len; };
extern struct PartSig HDAE5000_PartSignatureTable[];
extern unsigned char HDAE5000_PartSignatureTable_FileOffset[];
extern unsigned char HDAE5000_PartSignatureTable_Length[];

extern unsigned char HDAE5000_RAM_HdStreamBuffer[];

/* HDAE5000_FdSong_CheckFiles_Str_<EXT> (pushed) and _Str_rb, _Str_rb_2 .. _rb_9 (lda) */
#define STR_SEQ ((char *)0x2f8e9cL)
#define STR_SQF ((char *)0x2f8ea2L)
#define STR_LSW ((char *)0x2f8ea8L)
#define STR_PMT ((char *)0x2f8eb2L)
#define STR_SQT ((char *)0x2f8ebcL)
#define STR_CMP ((char *)0x2f8ec6L)
#define STR_TM  ((char *)0x2f8ed0L)
#define STR_MSP ((char *)0x2f8ed8L)
#define STR_RCM ((char *)0x2f8ee2L)
#define STR_MD  ((char *)0x2f8eecL)
#define STR_TLX ((char *)0x2f8ef4L)
extern char ram_2f8eae[], ram_2f8eb8[], ram_2f8ec2[], ram_2f8ecc[], ram_2f8ed4[];
extern char ram_2f8ede[], ram_2f8ee8[], ram_2f8ef0[], ram_2f8efa[];

int HDAE5000_CheckFileSignature(unsigned int part, unsigned char *buf)
{
    if (HDAE5000_StrNCmp(HDAE5000_PartSignatureTable[part].sig,
                         (char *)(buf + *(unsigned int *)((unsigned long)&HDAE5000_PartSignatureTable_FileOffset[0] + (unsigned long)part * 8)),
                         *(unsigned int *)((unsigned long)&HDAE5000_PartSignatureTable_Length[0] + (unsigned long)part * 8)) == 0)
        return 0;
    else
        return -1;
}

int HDAE5000_FdSong_CheckFiles(char *name, unsigned int mask)
{
    long h;
    char path[13];
    unsigned char ff[266];

    HDAE5000_MemFill(path, 0, 13);
    HDAE5000_MemCopy(path, name, 8);
    HDAE5000_StrCpy(&path[8], STR_SEQ);
    if ((h = CALLR(long, HAMA->findfirst)(path, ff)) != -1L) {
        CALLV(HAMA->findclose)(h);
        return -1;
    }
    HDAE5000_StrCpy(&path[8], STR_SQF);
    if ((h = CALLR(long, HAMA->findfirst)(path, ff)) != -1L) {
        CALLV(HAMA->findclose)(h);
        return -1;
    }
    if (mask & 0x001) {
        HDAE5000_StrCpy(&path[8], STR_LSW);
        CALLV(HAMA->fopen_ext)(path, ram_2f8eae);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(0, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x002) {
        HDAE5000_StrCpy(&path[8], STR_PMT);
        CALLV(HAMA->fopen_ext)(path, ram_2f8eb8);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(1, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x004) {
        HDAE5000_StrCpy(&path[8], STR_SQT);
        CALLV(HAMA->fopen_ext)(path, ram_2f8ec2);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(2, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x008) {
        HDAE5000_StrCpy(&path[8], STR_CMP);
        CALLV(HAMA->fopen_ext)(path, ram_2f8ecc);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(3, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x010) {
        HDAE5000_StrCpy(&path[8], STR_TM);
        CALLV(HAMA->fopen_ext)(path, ram_2f8ed4);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(4, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x020) {
        HDAE5000_StrCpy(&path[8], STR_MSP);
        CALLV(HAMA->fopen_ext)(path, ram_2f8ede);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(5, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x040) {
        HDAE5000_StrCpy(&path[8], STR_RCM);
        CALLV(HAMA->fopen_ext)(path, ram_2f8ee8);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(6, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x080) {
        HDAE5000_StrCpy(&path[8], STR_MD);
        CALLV(HAMA->fopen_ext)(path, ram_2f8ef0);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(7, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x100) {
        HDAE5000_StrCpy(&path[8], STR_TLX);
        CALLV(HAMA->fopen_ext)(path, ram_2f8efa);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(8, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    return 0;
}
