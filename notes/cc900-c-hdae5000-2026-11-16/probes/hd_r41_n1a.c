/* lane_hd round 41, helper h_n1, file a: HDAE5000_LoadSong_Sqt (song module) with four variants.
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
   What the five forms of run 2026-11-17-10-hd-r39 (hd_r39_m1b.c) showed, read against the hand source:
   - registers: the ROM keeps the bank byte in E and the pointer in XBC.  Only LdSqt_a had that (locals declared
     bank, p, n); the others (n, p, bank) had C and XDE.  So: bank, p, n.
   - the size: only LdSqt_b had the ROM's store / shift in the register / store (`n <<= 4; size = n;`, the form that
     matched LoadSong_Cmp and _Msp); `size = n << 4` reloads size.  So: the _b form.
   - the pointer step, wrong in all five.  ROM: the bank widened to a word, shifted ARITHMETICALLY by 10 in the word,
     sign-extended to 32 bits, doubled in 32 bits and added to the pointer register.  `p += bank << 10` shifted the
     byte itself, widened it unsigned and scaled it in 16 bits inside the address (LdSqt_d folded all of it).  The
     arithmetic shift says a signed int product (bank * 1024 rather than a shift of the unsigned char), the sign
     extension says that int converted to long before it is scaled by the pointer's element size.
   All forms here have the locals bank, p, n and `n <<= 4; size = n;`; they differ in the pointer step only:
     main:    p += (long)(bank * 1024);
     LdSqt_e: p += (long)((int)bank << 10);
     LdSqt_f: p += bank * 1024;                  (int index, no long)
     LdSqt_g: p += (int)bank << 10;
     LdSqt_h: a byte pointer, q += (long)(bank * 1024) * 2; q = q + 78; n = *(unsigned int *)q;
   Unsure: whether V4.23 shifts or multiplies for `* 1024`, and whether a long index is doubled by an add.
   cc900-name: LdSqt_e=HDAE5000_LoadSong_Sqt
   cc900-name: LdSqt_f=HDAE5000_LoadSong_Sqt
   cc900-name: LdSqt_g=HDAE5000_LoadSong_Sqt
   cc900-name: LdSqt_h=HDAE5000_LoadSong_Sqt
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ResInfo { unsigned long addr; unsigned long size; };
struct SqtHdr { unsigned char pad[198]; unsigned char pad198; unsigned char bank; };

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];

extern int HDAE5000_HD_ReadFile();

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
/* the address as an integer, (unsigned long)&sym[field] + record offset (run 2026-11-16-52-hd-r4v) */
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
/* the workspace's object 0x148 (ws + 0x11fa), function +0x18 */
#define OBJ148_FN6 (((void **)HDAE5000_RAM_MainWorkspacePtr->tab[0x148].fns)[6])

#define SQT_BANK (((struct SqtHdr *)HDAE5000_RAM_HdStreamBuffer)->bank)

/* part 2 (SQT): a 0x5000-byte read into the stream buffer gives the length word of the current bank
   (header byte 199 selects a 2048-byte bank; the word at +78 of it, in 16-byte units), added to resource 3's size */
int HDAE5000_LoadSong_Sqt(unsigned int dir, unsigned int song)
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
        p += (long)(bank * 1024);
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

/* the bank shifted as an int, then long */
int LdSqt_e(unsigned int dir, unsigned int song)
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
        p += (long)((int)bank << 10);
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

/* an int index: bank * 1024 */
int LdSqt_f(unsigned int dir, unsigned int song)
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
        p += bank * 1024;
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

/* an int index: (int)bank << 10 */
int LdSqt_g(unsigned int dir, unsigned int song)
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
        p += (int)bank << 10;
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

/* a byte pointer, the long offset doubled in the C */
int LdSqt_h(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info3;
    struct ResInfo info4;
    unsigned long size;
    unsigned char bank;
    unsigned char *q;
    unsigned long n;

    if (SLOT(2, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(3, (char *)&info3);
        CALLV(HAMA->GetResouceInfo)(4, (char *)&info4);
        if (HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x5000L, &SLOT(2, dir, song)) == -1)
            return -1;
        bank = SQT_BANK;
        q = HDAE5000_RAM_HdStreamBuffer;
        q += (long)(bank * 1024) * 2;
        q = q + 78;
        n = *(unsigned int *)q;
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
