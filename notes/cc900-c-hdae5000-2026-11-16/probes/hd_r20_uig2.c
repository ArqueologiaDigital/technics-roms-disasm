/* hd_r20_uig2.c (helper h_ui, lane_hd round 20): second form of hd_r20_uig.c (HDAE5000_CheckFileSignature +
   HDAE5000_FdSong_CheckFiles).  The ROM's literal pool HDAE5000_FdSong_CheckFiles_Str_SEQ .. _Str_rb_9 holds a fresh
   "rb" for every fopen and the strings in the order of use, which is what V4.23 emits for string literals written in
   place; so here they are literals (V4.23's own data, operands masked by the checker if it treats them as sdata).
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
    HDAE5000_StrCpy(&path[8], ".SEQ");
    if ((h = CALLR(long, HAMA->findfirst)(path, ff)) != -1L) {
        CALLV(HAMA->findclose)(h);
        return -1;
    }
    HDAE5000_StrCpy(&path[8], ".SQF");
    if ((h = CALLR(long, HAMA->findfirst)(path, ff)) != -1L) {
        CALLV(HAMA->findclose)(h);
        return -1;
    }
    if (mask & 0x001) {
        HDAE5000_StrCpy(&path[8], ".LSW");
        CALLV(HAMA->fopen_ext)(path, "rb");
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(0, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x002) {
        HDAE5000_StrCpy(&path[8], ".PMT");
        CALLV(HAMA->fopen_ext)(path, "rb");
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(1, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x004) {
        HDAE5000_StrCpy(&path[8], ".SQT");
        CALLV(HAMA->fopen_ext)(path, "rb");
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(2, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x008) {
        HDAE5000_StrCpy(&path[8], ".CMP");
        CALLV(HAMA->fopen_ext)(path, "rb");
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(3, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x010) {
        HDAE5000_StrCpy(&path[8], ".TM");
        CALLV(HAMA->fopen_ext)(path, "rb");
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(4, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x020) {
        HDAE5000_StrCpy(&path[8], ".MSP");
        CALLV(HAMA->fopen_ext)(path, "rb");
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(5, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x040) {
        HDAE5000_StrCpy(&path[8], ".RCM");
        CALLV(HAMA->fopen_ext)(path, "rb");
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(6, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x080) {
        HDAE5000_StrCpy(&path[8], ".MD");
        CALLV(HAMA->fopen_ext)(path, "rb");
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(7, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x100) {
        HDAE5000_StrCpy(&path[8], ".TLX");
        CALLV(HAMA->fopen_ext)(path, "rb");
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(8, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    return 0;
}
