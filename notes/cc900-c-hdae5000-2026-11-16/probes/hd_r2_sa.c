/* lane_hd round 2, form a (helper s): the song-record / FLS-record address functions and the nine
   DeleteSongPart_* siblings of HD-AE5000 v2.06i.

   Layout read from the hand source:
     0x201632  dir names     [120][16]
     +0x780    song records  [120 dirs][16 songs][76 B]   (dir * 0x4c0 + song * 76)
     +0x24180  FLS records   [120][144]                   (= HDAE5000_RAM_FlsRecords, 0x2257b2)
   Song record: part byte k at +26+k, chain slot k (long) at +36+4k, k = 0..8
     (0 LSW, 1 PMT, 2 SQT, 3 CMP, 4 TM, 5 MSP, 6 RCM, 7 MD, 8 TLX).
   FLS record: 16-byte name, then four 32-byte item columns at +16, +48, +80, +112
     (+16 = directory + 1, +48 = song + 1, as Fls_ForgetSong compares them).

   Round 1 (hd_r1b.c) showed that `base + ((unsigned long)dir * 0x4c0 + 0x780 + (unsigned long)song * 76)`
   gives the ROM's evaluation order (song * 76 first); the address functions only need a constant base
   (`ld xhl, imm32`) instead of &extern (`lda`).  The DeleteSongPart_* functions DO use `lda (sym+N)`, so they
   take the extern, with the record field offset folded into the symbol. */

struct SongRec {
    unsigned char name[26];
    unsigned char part[9];          /* +26 .. +34 */
    unsigned char pad;
    unsigned long slot[9];          /* +36 .. +71 */
    unsigned char tail[4];
};                                  /* 76 bytes */

struct FlsRec {
    unsigned char name[16];
    unsigned char dir1[32];         /* +16: directory + 1, 0 = free */
    unsigned char song1[32];        /* +48: song + 1 */
    unsigned char col80[32];        /* +80 */
    unsigned char col112[32];       /* +112 */
};                                  /* 144 bytes */

extern unsigned char HDAE5000_RAM_DirNames[];
extern struct FlsRec HDAE5000_RAM_FlsRecords[120];
extern void HDAE5000_HD_FreeChain(unsigned long first);

#define HD_TABLES ((unsigned char *)0x201632)
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SONGREC(d, s) ((struct SongRec *)(HDAE5000_RAM_DirNames + SONG_OFS(d, s)))

unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song)
{
    return HD_TABLES + ((unsigned long)dir * 0x4c0 + 0x780 + (unsigned long)song * 76);
}

unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls)
{
    return HD_TABLES + ((unsigned long)fls * 144 + 0x24180L);
}

unsigned char *HDAE5000_DirName_Address(unsigned int dir)
{
    return HD_TABLES + (unsigned long)dir * 16;
}

#define DELETE_PART(k)                                          \
    if (SONGREC(dir, song)->slot[k] != 0xffffffffUL) {          \
        HDAE5000_HD_FreeChain(SONGREC(dir, song)->slot[k]);     \
        SONGREC(dir, song)->slot[k] = 0xffffffffUL;             \
        SONGREC(dir, song)->part[k] = 0;                        \
    }

void HDAE5000_DeleteSongPart_Lsw(unsigned int dir, unsigned int song) { DELETE_PART(0) }
void HDAE5000_DeleteSongPart_Pmt(unsigned int dir, unsigned int song) { DELETE_PART(1) }
void HDAE5000_DeleteSongPart_Sqt(unsigned int dir, unsigned int song) { DELETE_PART(2) }
void HDAE5000_DeleteSongPart_Cmp(unsigned int dir, unsigned int song) { DELETE_PART(3) }
void HDAE5000_DeleteSongPart_Tm(unsigned int dir, unsigned int song)  { DELETE_PART(4) }
void HDAE5000_DeleteSongPart_Msp(unsigned int dir, unsigned int song) { DELETE_PART(5) }
void HDAE5000_DeleteSongPart_Rcm(unsigned int dir, unsigned int song) { DELETE_PART(6) }
void HDAE5000_DeleteSongPart_Md(unsigned int dir, unsigned int song)  { DELETE_PART(7) }
void HDAE5000_DeleteSongPart_Tlx(unsigned int dir, unsigned int song) { DELETE_PART(8) }

int HDAE5000_FlsItem_Clear(unsigned int fls, unsigned int item)
{
    HDAE5000_RAM_FlsRecords[fls].dir1[item] = 0;
    HDAE5000_RAM_FlsRecords[fls].song1[item] = 0;
    HDAE5000_RAM_FlsRecords[fls].col80[item] = 0;
    HDAE5000_RAM_FlsRecords[fls].col112[item] = 0;
    return 0;
}

void HDAE5000_Fls_ForgetSong(unsigned int dir, unsigned int song)
{
    unsigned int i, j;

    for (i = 0; i < 120; i++) {
        for (j = 0; j < 32; j++) {
            if (dir + 1 == HDAE5000_RAM_FlsRecords[i].dir1[j] && song + 1 == HDAE5000_RAM_FlsRecords[i].song1[j]) {
                HDAE5000_RAM_FlsRecords[i].dir1[j] = 0;
                HDAE5000_RAM_FlsRecords[i].song1[j] = 0;
                HDAE5000_RAM_FlsRecords[i].col80[j] = 0;
                HDAE5000_RAM_FlsRecords[i].col112[j] = 0;
            }
        }
    }
}
