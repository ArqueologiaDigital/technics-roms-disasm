/* lane_hd round 5: the nine DeleteSongPart_* and FlsItem_Clear with run 2026-11-16-52-hd-r4v's integer-address
   idiom (DelPartSqt_i2 and FlsItemClear_i2 matched).  Song record fields: part byte k at +26+k, first-cluster
   slot k at +36+4k; k = 0 LSW, 1 PMT, 2 SQT, 3 CMP, 4 TM, 5 MSP, 6 RCM, 7 MD, 8 TLX. */

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_FlsRecords[];
extern void HDAE5000_HD_FreeChain(unsigned long first);

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(unsigned long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define PART(k, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[26 + (k)] + SONG_OFS(d, s)))
#define DELETE_PART(k)                                   \
    if (SLOT(k, dir, song) != 0xffffffffUL) {            \
        HDAE5000_HD_FreeChain(SLOT(k, dir, song));       \
        SLOT(k, dir, song) = 0xffffffffUL;               \
        PART(k, dir, song) = 0;                          \
    }

void HDAE5000_DeleteSongPart_Lsw(unsigned int dir, unsigned int song) { DELETE_PART(0) }
void HDAE5000_DeleteSongPart_Pmt(unsigned int dir, unsigned int song) { DELETE_PART(1) }
void HDAE5000_DeleteSongPart_Sqt(unsigned int dir, unsigned int song) { DELETE_PART(2) }
void HDAE5000_DeleteSongPart_Cmp(unsigned int dir, unsigned int song) { DELETE_PART(3) }
void HDAE5000_DeleteSongPart_Tm(unsigned int dir, unsigned int song) { DELETE_PART(4) }
void HDAE5000_DeleteSongPart_Msp(unsigned int dir, unsigned int song) { DELETE_PART(5) }
void HDAE5000_DeleteSongPart_Rcm(unsigned int dir, unsigned int song) { DELETE_PART(6) }
void HDAE5000_DeleteSongPart_Md(unsigned int dir, unsigned int song) { DELETE_PART(7) }
void HDAE5000_DeleteSongPart_Tlx(unsigned int dir, unsigned int song) { DELETE_PART(8) }

#define FLS(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))

int HDAE5000_FlsItem_Clear(unsigned int fls, unsigned int item)
{
    FLS(16, fls, item) = 0;
    FLS(48, fls, item) = 0;
    FLS(80, fls, item) = 0;
    FLS(112, fls, item) = 0;
    return 0;
}
