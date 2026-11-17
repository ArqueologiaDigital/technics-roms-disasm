/* lane_hd round 39, helper h_m1: HDAE5000_LoadSong_Sqt, _Cmp, _Msp (from hd_r13_na.c) and HDAE5000_Fls_ForgetSong
   (from hd_r2_sb.c / hd_r2_sc.c), in ROM address order, with variants.  They belong to the song module.
   cc900-options: -Xr
   cc900-module: HDAE5000_Song_IsUsed HDAE5000_Song_CheckFreeSpace HDAE5000_Song_PartMask
   cc900-module: HDAE5000_LoadSong_Lsw HDAE5000_LoadSong_Pmt HDAE5000_LoadSong_Sqt HDAE5000_LoadSong_Cmp HDAE5000_LoadSong_Tm
   cc900-module: HDAE5000_LoadSong_Msp HDAE5000_LoadSong_Rcm HDAE5000_LoadSong_Md HDAE5000_LoadSong_Tlx
   cc900-module: HDAE5000_SaveSong_Lsw HDAE5000_SaveSong_Pmt HDAE5000_SaveSong_Sqt HDAE5000_SaveSong_Cmp HDAE5000_SaveSong_Tm
   cc900-module: HDAE5000_SaveSong_Msp HDAE5000_SaveSong_Rcm HDAE5000_SaveSong_Md HDAE5000_SaveSong_Tlx
   cc900-module: HDAE5000_CopyFdSongToHd_Lsw HDAE5000_CopyFdSongToHd_Pmt HDAE5000_CopyFdSongToHd_Sqt HDAE5000_CopyFdSongToHd_Cmp
   cc900-module: HDAE5000_CopyFdSongToHd_Tm HDAE5000_CopyFdSongToHd_Msp HDAE5000_CopyFdSongToHd_Rcm HDAE5000_CopyFdSongToHd_Md
   cc900-module: HDAE5000_CopyFdSongToHd_Tlx
   cc900-module: HDAE5000_DeleteSongPart_Lsw HDAE5000_DeleteSongPart_Pmt HDAE5000_DeleteSongPart_Sqt HDAE5000_DeleteSongPart_Cmp
   cc900-module: HDAE5000_DeleteSongPart_Tm HDAE5000_DeleteSongPart_Msp HDAE5000_DeleteSongPart_Rcm HDAE5000_DeleteSongPart_Md
   cc900-module: HDAE5000_DeleteSongPart_Tlx HDAE5000_DeleteSongParts HDAE5000_Fls_ForgetSong
   cc900-module: HDAE5000_RoundUpToSector HDAE5000_TlxPart_Describe HDAE5000_HD_WriteOpen HDAE5000_HD_WriteClose
   These three loaders keep their result in a stack word and the first product in XIZ (LoadSong_Tlx's IZ result is a
   different frame), so `int ret = 0;` first stays as it matched.  What run 2026-11-16-74 left:
   - LoadSong_Cmp / _Msp, one instruction (`ld xwa,(xsp+4)` too many): the ROM widens the block count, stores it in
     size, shifts the register it still holds and stores again.  Every spelling on size alone reloads it.  lane_sub's
     idiom (run 2026-11-16-99-sub-r13-idioms, TVF_Build_Short): a second plain local receives the value, the kept
     local is assigned FROM it and the next use goes through the second one; that local lives in XWA and gets no
     stack slot: `n = blocks; size = n; size = n << 4;`.
   - LoadSong_Sqt: the same store / shift / store, and before it three more values held in registers only: the bank
     byte in E (`lda xwa,(Buf); ld e,(xwa+199)`), a pointer in XBC that is loaded with the buffer, advanced by
     bank << 10 words (`ld a,e; extz wa; sla wa,10; exts xwa; add xwa,xwa; add xbc,xwa`) and then by 78 bytes
     through XWA (`lda xwa,(xbc+78); ld xbc,xwa`), and the word read through it (`ld wa,(xbc)`).  Written as three
     short-lived locals: bank, p (unsigned int *, so the int index is doubled) and n.
   - Fls_ForgetSong (run 2026-11-16-46, older than the address idiom): the columns through the integer address,
     `*(unsigned char *)((unsigned long)&FlsRecords[16 + 32 * c] + (f * 144 + i))` (FlsItem_Clear's matched macro:
     `lda xde,(sym+16:24); add xde,xix`); the record byte on the LEFT of the compare (hd_r2_sc.c gave the ROM's
     `ld l,e; extz hl; ld de,wa; inc 1,de; cp de,hl` that way); i declared before j (i in IZ, hd_r2_sb.c).
   Variants (cc900-name lines below):
     LdSqt_a: the three locals declared bank, p, n (main: n, p, bank), in case the registers follow that order;
     LdSqt_b: the shift on the local, `n <<= 4; size = n;`;
     LdSqt_c: the 78-byte step through a byte pointer, p = (unsigned int *)((unsigned char *)p + 78);
     LdSqt_d: the pointer in one statement, p = (unsigned int *)Buf + (bank << 10);
     LdCmp_b / LdMsp_b: `n <<= 4; size = n;`;
     LdCmp_c / LdMsp_c: n declared first of all the locals;
     LdCmp_d / LdMsp_d: `size = n = blocks; size = n << 4;`;
     Forget_c: the two tests as `if (..) continue;` with != (main: one if with &&).
   cc900-name: LdSqt_a=HDAE5000_LoadSong_Sqt
   cc900-name: LdSqt_b=HDAE5000_LoadSong_Sqt
   cc900-name: LdSqt_c=HDAE5000_LoadSong_Sqt
   cc900-name: LdSqt_d=HDAE5000_LoadSong_Sqt
   cc900-name: LdCmp_b=HDAE5000_LoadSong_Cmp
   cc900-name: LdCmp_c=HDAE5000_LoadSong_Cmp
   cc900-name: LdCmp_d=HDAE5000_LoadSong_Cmp
   cc900-name: LdMsp_b=HDAE5000_LoadSong_Msp
   cc900-name: LdMsp_c=HDAE5000_LoadSong_Msp
   cc900-name: LdMsp_d=HDAE5000_LoadSong_Msp
   cc900-name: Forget_c=HDAE5000_Fls_ForgetSong
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ResInfo { unsigned long addr; unsigned long size; };
struct CmpHdr { unsigned char pad[46]; unsigned int blocks; };
struct MspHdr { unsigned char pad[28]; unsigned int blocks; };
struct SqtHdr { unsigned char pad[198]; unsigned char pad198; unsigned char bank; };

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_FlsRecords[];
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];

extern int HDAE5000_HD_ReadFile();

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
/* the address as an integer, (unsigned long)&sym[field] + record offset: V4.23 then writes the ROM's
   lda xR,(sym+field) after the offset (run 2026-11-16-52-hd-r4v, DeleteSongPart_Sqt and FlsItem_Clear) */
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
/* the workspace's object 0x148 (ws + 0x11fa), function +0x18 (hd_r4_ppa.c PP_Svc16 gave the single load, run 56) */
#define OBJ148_FN6 (((void **)HDAE5000_RAM_MainWorkspacePtr->tab[0x148].fns)[6])
/* FLS record f, column byte at o + i (hdae5000/cc900/hdae5000_ui_display.c, FlsItem_Clear) */
#define FLS(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))

#define SQT_BANK (((struct SqtHdr *)HDAE5000_RAM_HdStreamBuffer)->bank)
#define CMP_BLOCKS (((struct CmpHdr *)HDAE5000_RAM_HdStreamBuffer)->blocks)
#define MSP_BLOCKS (((struct MspHdr *)HDAE5000_RAM_HdStreamBuffer)->blocks)

/* part 2 (SQT): a 0x5000-byte read into the stream buffer gives the length word of the current bank (header byte 199
   selects a 2048-byte bank; the word at +78 of it, in 16-byte units), added to resource 3's size */
int HDAE5000_LoadSong_Sqt(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info3;
    struct ResInfo info4;
    unsigned long size;
    unsigned long n;
    unsigned int *p;
    unsigned char bank;

    if (SLOT(2, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(3, (char *)&info3);
        CALLV(HAMA->GetResouceInfo)(4, (char *)&info4);
        if (HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x5000L, &SLOT(2, dir, song)) == -1)
            return -1;
        bank = SQT_BANK;
        p = (unsigned int *)HDAE5000_RAM_HdStreamBuffer;
        p += bank << 10;
        p = p + 39;
        n = *p;
        size = n;
        size = n << 4;
        size += info3.size;
        CALLV(HAMA->SeqLoadPre)();
        ret = HDAE5000_HD_ReadFile(info3.addr, size, &SLOT(2, dir, song));
        CALLV(HAMA->SeqLoadPost)(ret);
        CALLV(OBJ148_FN6)(-1L, EVT_ACTIVATE_STATE, 0L);
    }
    return ret;
}

/* the locals declared bank, p, n */
int LdSqt_a(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info3;
    struct ResInfo info4;
    unsigned long size;
    unsigned char bank;
    unsigned int *p;
    unsigned long n;

    if (SLOT(2, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(3, (char *)&info3);
        CALLV(HAMA->GetResouceInfo)(4, (char *)&info4);
        if (HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x5000L, &SLOT(2, dir, song)) == -1)
            return -1;
        bank = SQT_BANK;
        p = (unsigned int *)HDAE5000_RAM_HdStreamBuffer;
        p += bank << 10;
        p = p + 39;
        n = *p;
        size = n;
        size = n << 4;
        size += info3.size;
        CALLV(HAMA->SeqLoadPre)();
        ret = HDAE5000_HD_ReadFile(info3.addr, size, &SLOT(2, dir, song));
        CALLV(HAMA->SeqLoadPost)(ret);
        CALLV(OBJ148_FN6)(-1L, EVT_ACTIVATE_STATE, 0L);
    }
    return ret;
}

/* the shift on the local */
int LdSqt_b(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info3;
    struct ResInfo info4;
    unsigned long size;
    unsigned long n;
    unsigned int *p;
    unsigned char bank;

    if (SLOT(2, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(3, (char *)&info3);
        CALLV(HAMA->GetResouceInfo)(4, (char *)&info4);
        if (HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x5000L, &SLOT(2, dir, song)) == -1)
            return -1;
        bank = SQT_BANK;
        p = (unsigned int *)HDAE5000_RAM_HdStreamBuffer;
        p += bank << 10;
        p = p + 39;
        n = *p;
        size = n;
        n <<= 4;
        size = n;
        size += info3.size;
        CALLV(HAMA->SeqLoadPre)();
        ret = HDAE5000_HD_ReadFile(info3.addr, size, &SLOT(2, dir, song));
        CALLV(HAMA->SeqLoadPost)(ret);
        CALLV(OBJ148_FN6)(-1L, EVT_ACTIVATE_STATE, 0L);
    }
    return ret;
}

/* the 78-byte step through a byte pointer */
int LdSqt_c(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info3;
    struct ResInfo info4;
    unsigned long size;
    unsigned long n;
    unsigned int *p;
    unsigned char bank;

    if (SLOT(2, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(3, (char *)&info3);
        CALLV(HAMA->GetResouceInfo)(4, (char *)&info4);
        if (HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x5000L, &SLOT(2, dir, song)) == -1)
            return -1;
        bank = SQT_BANK;
        p = (unsigned int *)HDAE5000_RAM_HdStreamBuffer;
        p += bank << 10;
        p = (unsigned int *)((unsigned char *)p + 78);
        n = *p;
        size = n;
        size = n << 4;
        size += info3.size;
        CALLV(HAMA->SeqLoadPre)();
        ret = HDAE5000_HD_ReadFile(info3.addr, size, &SLOT(2, dir, song));
        CALLV(HAMA->SeqLoadPost)(ret);
        CALLV(OBJ148_FN6)(-1L, EVT_ACTIVATE_STATE, 0L);
    }
    return ret;
}

/* the pointer in one statement */
int LdSqt_d(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info3;
    struct ResInfo info4;
    unsigned long size;
    unsigned long n;
    unsigned int *p;
    unsigned char bank;

    if (SLOT(2, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(3, (char *)&info3);
        CALLV(HAMA->GetResouceInfo)(4, (char *)&info4);
        if (HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x5000L, &SLOT(2, dir, song)) == -1)
            return -1;
        bank = SQT_BANK;
        p = (unsigned int *)HDAE5000_RAM_HdStreamBuffer + (bank << 10);
        p = p + 39;
        n = *p;
        size = n;
        size = n << 4;
        size += info3.size;
        CALLV(HAMA->SeqLoadPre)();
        ret = HDAE5000_HD_ReadFile(info3.addr, size, &SLOT(2, dir, song));
        CALLV(HAMA->SeqLoadPost)(ret);
        CALLV(OBJ148_FN6)(-1L, EVT_ACTIVATE_STATE, 0L);
    }
    return ret;
}

int HDAE5000_LoadSong_Cmp(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;
    unsigned long size;
    unsigned long n;

    if (SLOT(3, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(5, (char *)&info);
        if (HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x200L, &SLOT(3, dir, song)) == -1)
            return -1;
        n = CMP_BLOCKS;
        size = n;
        size = n << 4;
        CALLV(HAMA->cmp_ld_mae)();
        ret = HDAE5000_HD_ReadFile(info.addr, size, &SLOT(3, dir, song));
        CALLV(HAMA->cmp_ld_ato)(ret);
    }
    return ret;
}

int LdCmp_b(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;
    unsigned long size;
    unsigned long n;

    if (SLOT(3, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(5, (char *)&info);
        if (HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x200L, &SLOT(3, dir, song)) == -1)
            return -1;
        n = CMP_BLOCKS;
        size = n;
        n <<= 4;
        size = n;
        CALLV(HAMA->cmp_ld_mae)();
        ret = HDAE5000_HD_ReadFile(info.addr, size, &SLOT(3, dir, song));
        CALLV(HAMA->cmp_ld_ato)(ret);
    }
    return ret;
}

int LdCmp_c(unsigned int dir, unsigned int song)
{
    unsigned long n;
    int ret = 0;
    struct ResInfo info;
    unsigned long size;

    if (SLOT(3, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(5, (char *)&info);
        if (HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x200L, &SLOT(3, dir, song)) == -1)
            return -1;
        n = CMP_BLOCKS;
        size = n;
        size = n << 4;
        CALLV(HAMA->cmp_ld_mae)();
        ret = HDAE5000_HD_ReadFile(info.addr, size, &SLOT(3, dir, song));
        CALLV(HAMA->cmp_ld_ato)(ret);
    }
    return ret;
}

int LdCmp_d(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;
    unsigned long size;
    unsigned long n;

    if (SLOT(3, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(5, (char *)&info);
        if (HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x200L, &SLOT(3, dir, song)) == -1)
            return -1;
        size = n = CMP_BLOCKS;
        size = n << 4;
        CALLV(HAMA->cmp_ld_mae)();
        ret = HDAE5000_HD_ReadFile(info.addr, size, &SLOT(3, dir, song));
        CALLV(HAMA->cmp_ld_ato)(ret);
    }
    return ret;
}

int HDAE5000_LoadSong_Msp(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;
    unsigned long size;
    unsigned long n;

    if (SLOT(5, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(7, (char *)&info);
        if (HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x200L, &SLOT(5, dir, song)) == -1)
            return -1;
        n = MSP_BLOCKS;
        size = n;
        size = n << 4;
        CALLV(HAMA->msp_ld_mae)();
        ret = HDAE5000_HD_ReadFile(info.addr, size, &SLOT(5, dir, song));
        CALLV(HAMA->msp_ld_ato)(ret);
    }
    return ret;
}

int LdMsp_b(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;
    unsigned long size;
    unsigned long n;

    if (SLOT(5, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(7, (char *)&info);
        if (HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x200L, &SLOT(5, dir, song)) == -1)
            return -1;
        n = MSP_BLOCKS;
        size = n;
        n <<= 4;
        size = n;
        CALLV(HAMA->msp_ld_mae)();
        ret = HDAE5000_HD_ReadFile(info.addr, size, &SLOT(5, dir, song));
        CALLV(HAMA->msp_ld_ato)(ret);
    }
    return ret;
}

int LdMsp_c(unsigned int dir, unsigned int song)
{
    unsigned long n;
    int ret = 0;
    struct ResInfo info;
    unsigned long size;

    if (SLOT(5, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(7, (char *)&info);
        if (HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x200L, &SLOT(5, dir, song)) == -1)
            return -1;
        n = MSP_BLOCKS;
        size = n;
        size = n << 4;
        CALLV(HAMA->msp_ld_mae)();
        ret = HDAE5000_HD_ReadFile(info.addr, size, &SLOT(5, dir, song));
        CALLV(HAMA->msp_ld_ato)(ret);
    }
    return ret;
}

int LdMsp_d(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;
    unsigned long size;
    unsigned long n;

    if (SLOT(5, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(7, (char *)&info);
        if (HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x200L, &SLOT(5, dir, song)) == -1)
            return -1;
        size = n = MSP_BLOCKS;
        size = n << 4;
        CALLV(HAMA->msp_ld_mae)();
        ret = HDAE5000_HD_ReadFile(info.addr, size, &SLOT(5, dir, song));
        CALLV(HAMA->msp_ld_ato)(ret);
    }
    return ret;
}

/* take a deleted song out of every FLS list: an item whose directory + 1 (column +16) and song + 1 (column +48)
   match has its four column bytes cleared */
void HDAE5000_Fls_ForgetSong(unsigned int dir, unsigned int song)
{
    unsigned int i, j;

    for (i = 0; i < 120; i++) {
        for (j = 0; j < 32; j++) {
            if (FLS(16, i, j) == dir + 1 && FLS(48, i, j) == song + 1) {
                FLS(16, i, j) = 0;
                FLS(48, i, j) = 0;
                FLS(80, i, j) = 0;
                FLS(112, i, j) = 0;
            }
        }
    }
}

void Forget_c(unsigned int dir, unsigned int song)
{
    unsigned int i, j;

    for (i = 0; i < 120; i++) {
        for (j = 0; j < 32; j++) {
            if (FLS(16, i, j) != dir + 1)
                continue;
            if (FLS(48, i, j) != song + 1)
                continue;
            FLS(16, i, j) = 0;
            FLS(48, i, j) = 0;
            FLS(80, i, j) = 0;
            FLS(112, i, j) = 0;
        }
    }
}
