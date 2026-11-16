/* lane_hd round 2, form c (helper s): third guesses for some functions of hd_r2_sa.c (same names):
   - SongRecord_Address with song * 76 as the LEFT operand (in case the order rule is "left first" and round 1's
     match came from something else);
   - DirName_Address as a constant pointer to 16-byte rows;
   - DeleteSongPart_* with an early return and a signed (long, compared with -1L) slot;
   - Fls_ForgetSong with the compares' operands swapped and the loop counters declared j, i. */

struct SongRec {
    unsigned char name[26];
    unsigned char part[9];          /* +26 .. +34 */
    unsigned char pad;
    long slot[9];                   /* +36 .. +71 */
    unsigned char tail[4];
};                                  /* 76 bytes */

struct FlsRec {
    unsigned char name[16];
    unsigned char dir1[32];         /* +16 */
    unsigned char song1[32];        /* +48 */
    unsigned char col80[32];        /* +80 */
    unsigned char col112[32];       /* +112 */
};                                  /* 144 bytes */

extern unsigned char HDAE5000_RAM_DirNames[];
extern struct FlsRec HDAE5000_RAM_FlsRecords[120];
extern void HDAE5000_HD_FreeChain(long first);

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SONGREC(d, s) ((struct SongRec *)(HDAE5000_RAM_DirNames + SONG_OFS(d, s)))

unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song)
{
    return (unsigned char *)0x201632 + ((unsigned long)song * 76 + ((unsigned long)dir * 0x4c0 + 0x780));
}

unsigned char *HDAE5000_DirName_Address(unsigned int dir)
{
    return ((unsigned char (*)[16])0x201632)[dir];
}

#define DELETE_PART(k)                                  \
    if (SONGREC(dir, song)->slot[k] == -1L)             \
        return;                                         \
    HDAE5000_HD_FreeChain(SONGREC(dir, song)->slot[k]); \
    SONGREC(dir, song)->slot[k] = -1L;                  \
    SONGREC(dir, song)->part[k] = 0;

void HDAE5000_DeleteSongPart_Lsw(unsigned int dir, unsigned int song) { DELETE_PART(0) }
void HDAE5000_DeleteSongPart_Pmt(unsigned int dir, unsigned int song) { DELETE_PART(1) }
void HDAE5000_DeleteSongPart_Sqt(unsigned int dir, unsigned int song) { DELETE_PART(2) }
void HDAE5000_DeleteSongPart_Cmp(unsigned int dir, unsigned int song) { DELETE_PART(3) }
void HDAE5000_DeleteSongPart_Tm(unsigned int dir, unsigned int song)  { DELETE_PART(4) }
void HDAE5000_DeleteSongPart_Msp(unsigned int dir, unsigned int song) { DELETE_PART(5) }
void HDAE5000_DeleteSongPart_Rcm(unsigned int dir, unsigned int song) { DELETE_PART(6) }
void HDAE5000_DeleteSongPart_Md(unsigned int dir, unsigned int song)  { DELETE_PART(7) }
void HDAE5000_DeleteSongPart_Tlx(unsigned int dir, unsigned int song) { DELETE_PART(8) }

void HDAE5000_Fls_ForgetSong(unsigned int dir, unsigned int song)
{
    unsigned int j, i;

    for (i = 0; i < 120; i++)
        for (j = 0; j < 32; j++)
            if (HDAE5000_RAM_FlsRecords[i].dir1[j] == dir + 1 && HDAE5000_RAM_FlsRecords[i].song1[j] == song + 1) {
                HDAE5000_RAM_FlsRecords[i].dir1[j] = 0;
                HDAE5000_RAM_FlsRecords[i].song1[j] = 0;
                HDAE5000_RAM_FlsRecords[i].col80[j] = 0;
                HDAE5000_RAM_FlsRecords[i].col112[j] = 0;
            }
}
