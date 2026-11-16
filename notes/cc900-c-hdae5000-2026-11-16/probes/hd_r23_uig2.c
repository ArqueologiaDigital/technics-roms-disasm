/* hd_r23_uig2.c (helper h_nm3b, lane_hd round 23): second form of hd_r23_uig.c.  Differences from it: the
   conversions are explicit casts instead of prototype conversions: `(int)` on the length (StrNCmp's third
   parameter unsigned), buf a plain `char *` with `(char *)HDAE5000_RAM_HdStreamBuffer` at each call, and
   `(char *)ff` for findfirst.  Otherwise as hd_r23_uig.c, whose notes follow.
   hd_r23_uig.c: the calr group HDAE5000_CheckFileSignature +
   HDAE5000_FdSong_CheckFiles (hdae5000_ui_display.s), in ROM order; round 20's hd_r20_uig.c with these changes:
   - CheckFileSignature: the table index as a SHIFT, `(unsigned long)part << 3` (the ROM shifts the extended part in
     place, `sll xde,3`; `* 8` copied it first, `ld xhl,xde; sll xhl,3`); the length passed to an `int` parameter
     of HDAE5000_StrNCmp (a conversion: the ROM loads it, `ld de,(xhl); pushw de`, where V4.23 pushed the memory
     word, `pushw (xde)`); one exit through a local, `r = 0` / `r = -1` (the ROM's `ld hl,0; jr t,Return`, as
     CPanel_CheckSpecialCombos); buf a `const unsigned char *`, so the caller's HdStreamBuffer argument is
     converted (the ROM evaluates it first: `lda xwa,(buf); ld xbc,xwa; ld wa,k`).
   - FdSong_CheckFiles: ff declared before path (V4.23 put path at xsp+270; the ROM has path at xsp+4, ff at +18);
     ff converted for findfirst, `(void *)ff` (the ROM evaluates it first, `lda xwa,(xsp+18); ld xbc,xwa`); the
     pushed extensions are EXTERN symbols ram_<hex> (an extern pushed directly gives `pushw X@hi16 / @lo16`; the
     numeric `(char *)0x2f8e9cL` gave `ld xwa,imm; push xwa`).  The labels HDAE5000_FdSong_CheckFiles_Str_* share
     their first 31 characters, hence ram_<hex>.
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
extern char ram_2f8e9c[], ram_2f8ea2[], ram_2f8ea8[], ram_2f8eb2[], ram_2f8ebc[], ram_2f8ec6[];
extern char ram_2f8ed0[], ram_2f8ed8[], ram_2f8ee2[], ram_2f8eec[], ram_2f8ef4[];
extern char ram_2f8eae[], ram_2f8eb8[], ram_2f8ec2[], ram_2f8ecc[], ram_2f8ed4[];
extern char ram_2f8ede[], ram_2f8ee8[], ram_2f8ef0[], ram_2f8efa[];

int HDAE5000_CheckFileSignature(unsigned int part, char *buf)
{
    int r;
    if (HDAE5000_StrNCmp(HDAE5000_PartSignatureTable[part].sig,
                         buf + *(unsigned int *)((unsigned long)&HDAE5000_PartSignatureTable_FileOffset[0] + ((unsigned long)part << 3)),
                         (int)*(unsigned int *)((unsigned long)&HDAE5000_PartSignatureTable_Length[0] + ((unsigned long)part << 3))) == 0)
        r = 0;
    else
        r = -1;
    return r;
}

int HDAE5000_FdSong_CheckFiles(char *name, unsigned int mask)
{
    long h;
    unsigned char ff[266];
    char path[13];

    HDAE5000_MemFill(path, 0, 13);
    HDAE5000_MemCopy(path, name, 8);
    HDAE5000_StrCpy(&path[8], ram_2f8e9c);
    if ((h = CALLR(long, HAMA->findfirst)(path, (char *)ff)) != -1L) {
        CALLV(HAMA->findclose)(h);
        return -1;
    }
    HDAE5000_StrCpy(&path[8], ram_2f8ea2);
    if ((h = CALLR(long, HAMA->findfirst)(path, (char *)ff)) != -1L) {
        CALLV(HAMA->findclose)(h);
        return -1;
    }
    if (mask & 0x001) {
        HDAE5000_StrCpy(&path[8], ram_2f8ea8);
        CALLV(HAMA->fopen_ext)(path, ram_2f8eae);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(0, (char *)HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x002) {
        HDAE5000_StrCpy(&path[8], ram_2f8eb2);
        CALLV(HAMA->fopen_ext)(path, ram_2f8eb8);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(1, (char *)HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x004) {
        HDAE5000_StrCpy(&path[8], ram_2f8ebc);
        CALLV(HAMA->fopen_ext)(path, ram_2f8ec2);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(2, (char *)HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x008) {
        HDAE5000_StrCpy(&path[8], ram_2f8ec6);
        CALLV(HAMA->fopen_ext)(path, ram_2f8ecc);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(3, (char *)HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x010) {
        HDAE5000_StrCpy(&path[8], ram_2f8ed0);
        CALLV(HAMA->fopen_ext)(path, ram_2f8ed4);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(4, (char *)HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x020) {
        HDAE5000_StrCpy(&path[8], ram_2f8ed8);
        CALLV(HAMA->fopen_ext)(path, ram_2f8ede);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(5, (char *)HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x040) {
        HDAE5000_StrCpy(&path[8], ram_2f8ee2);
        CALLV(HAMA->fopen_ext)(path, ram_2f8ee8);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(6, (char *)HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x080) {
        HDAE5000_StrCpy(&path[8], ram_2f8eec);
        CALLV(HAMA->fopen_ext)(path, ram_2f8ef0);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(7, (char *)HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x100) {
        HDAE5000_StrCpy(&path[8], ram_2f8ef4);
        CALLV(HAMA->fopen_ext)(path, ram_2f8efa);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(8, (char *)HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    return 0;
}
