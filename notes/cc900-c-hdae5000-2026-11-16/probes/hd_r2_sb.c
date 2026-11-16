/* lane_hd round 2, form b (helper s): the functions of hd_r2_sa.c (same names), spelled as explicit byte-pointer
   arithmetic: the base (symbol + field offset) is the left operand, the long offset in parentheses the right one,
   so that an evaluator that does the right operand first computes the offset before loading the base, as the
   ROM does.  The address functions take the constant as an integer sum cast to a pointer. */

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_FlsRecords[];
extern void HDAE5000_HD_FreeChain(unsigned long first);

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(unsigned long *)(HDAE5000_RAM_DirNames + (36 + 4 * (k)) + SONG_OFS(d, s)))
#define PART(k, d, s) (*(HDAE5000_RAM_DirNames + (26 + (k)) + SONG_OFS(d, s)))
#define FLS_COL(c, f, i) (*(HDAE5000_RAM_FlsRecords + (16 + 32 * (c)) + ((unsigned long)(f) * 144 + (i))))

unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song)
{
    return (unsigned char *)(0x201632L + ((unsigned long)dir * 0x4c0 + 0x780 + (unsigned long)song * 76));
}

unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls)
{
    return (unsigned char *)(0x201632L + ((unsigned long)fls * 144 + 0x24180L));
}

unsigned char *HDAE5000_DirName_Address(unsigned int dir)
{
    return (unsigned char *)(0x201632L + (unsigned long)dir * 16);
}

#define DELETE_PART(k)                                  \
    if (SLOT(k, dir, song) != 0xffffffffUL) {           \
        HDAE5000_HD_FreeChain(SLOT(k, dir, song));      \
        SLOT(k, dir, song) = 0xffffffffUL;              \
        PART(k, dir, song) = 0;                         \
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
    FLS_COL(0, fls, item) = 0;
    FLS_COL(1, fls, item) = 0;
    FLS_COL(2, fls, item) = 0;
    FLS_COL(3, fls, item) = 0;
    return 0;
}

void HDAE5000_Fls_ForgetSong(unsigned int dir, unsigned int song)
{
    unsigned int i, j;

    for (i = 0; i < 120; i++) {
        for (j = 0; j < 32; j++) {
            if (dir + 1 != FLS_COL(0, i, j))
                continue;
            if (song + 1 != FLS_COL(1, i, j))
                continue;
            FLS_COL(0, i, j) = 0;
            FLS_COL(1, i, j) = 0;
            FLS_COL(2, i, j) = 0;
            FLS_COL(3, i, j) = 0;
        }
    }
}
