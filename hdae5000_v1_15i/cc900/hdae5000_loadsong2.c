/* Functions of hdae5000_ui_display.s.  (hdae5000_loadsong2.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_loadsong2.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-name: LdCmp_b=HDAE5000_LoadSong_Cmp
   cc900-name: LdMsp_b=HDAE5000_LoadSong_Msp
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

/* the locals declared bank, p, n */

/* the shift on the local */

/* the 78-byte step through a byte pointer */

/* the pointer in one statement */

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
