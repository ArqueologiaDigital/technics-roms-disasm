/* lane_hd round 4, variants of the address-constant question (README "Unsolved: address constants").  Runs 46/48
   (and 50: Toshiba IDE 2003 and V1.10 give the same bytes as V4.23) folded every pointer spelling's constant into the
   index.  Tried here: the address arithmetic done on integers (the symbol cast to unsigned long), and full struct
   indexing of the whole table block.
   cc900-name: DirNameAddr_i1=HDAE5000_DirName_Address
   cc900-name: DirNameAddr_i2=HDAE5000_DirName_Address
   cc900-name: DelPartSqt_i1=HDAE5000_DeleteSongPart_Sqt
   cc900-name: DelPartSqt_i2=HDAE5000_DeleteSongPart_Sqt
   cc900-name: DelPartSqt_i3=HDAE5000_DeleteSongPart_Sqt
   cc900-name: DelPartSqt_s1=HDAE5000_DeleteSongPart_Sqt
   cc900-name: FlsItemClear_i1=HDAE5000_FlsItem_Clear
   cc900-name: FlsItemClear_i2=HDAE5000_FlsItem_Clear
*/

struct SongRec { unsigned char name[26]; unsigned char part[9]; unsigned char pad; unsigned long slot[9];
                 unsigned char tail[4]; };
struct HdTables { unsigned char dir[120][16]; struct SongRec song[120][16]; };
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_FlsRecords[];
extern struct HdTables ram_201632;
extern void HDAE5000_HD_FreeChain(unsigned long first);

unsigned char *DirNameAddr_i1(unsigned int dir)
{
    return (unsigned char *)((unsigned long)HDAE5000_RAM_DirNames + (unsigned long)dir * 16);
}

unsigned char *DirNameAddr_i2(unsigned int dir)
{
    return (unsigned char *)((unsigned long)dir * 16 + (unsigned long)HDAE5000_RAM_DirNames);
}

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT_I1(o, d, s) (*(unsigned long *)((unsigned long)HDAE5000_RAM_DirNames + (o) + SONG_OFS(d, s)))
#define PART_I1(o, d, s) (*(unsigned char *)((unsigned long)HDAE5000_RAM_DirNames + (o) + SONG_OFS(d, s)))
#define SLOT_I2(o, d, s) (*(unsigned long *)((unsigned long)&HDAE5000_RAM_DirNames[o] + SONG_OFS(d, s)))
#define PART_I2(o, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[o] + SONG_OFS(d, s)))
#define SLOT_I3(o, d, s) (*(unsigned long *)(SONG_OFS(d, s) + ((unsigned long)HDAE5000_RAM_DirNames + (o))))
#define PART_I3(o, d, s) (*(unsigned char *)(SONG_OFS(d, s) + ((unsigned long)HDAE5000_RAM_DirNames + (o))))

void DelPartSqt_i1(unsigned int dir, unsigned int song)
{
    if (SLOT_I1(44, dir, song) != 0xffffffffUL) {
        HDAE5000_HD_FreeChain(SLOT_I1(44, dir, song));
        SLOT_I1(44, dir, song) = 0xffffffffUL;
        PART_I1(28, dir, song) = 0;
    }
}

void DelPartSqt_i2(unsigned int dir, unsigned int song)
{
    if (SLOT_I2(44, dir, song) != 0xffffffffUL) {
        HDAE5000_HD_FreeChain(SLOT_I2(44, dir, song));
        SLOT_I2(44, dir, song) = 0xffffffffUL;
        PART_I2(28, dir, song) = 0;
    }
}

void DelPartSqt_i3(unsigned int dir, unsigned int song)
{
    if (SLOT_I3(44, dir, song) != 0xffffffffUL) {
        HDAE5000_HD_FreeChain(SLOT_I3(44, dir, song));
        SLOT_I3(44, dir, song) = 0xffffffffUL;
        PART_I3(28, dir, song) = 0;
    }
}

void DelPartSqt_s1(unsigned int dir, unsigned int song)
{
    if (ram_201632.song[dir][song].slot[2] != 0xffffffffUL) {
        HDAE5000_HD_FreeChain(ram_201632.song[dir][song].slot[2]);
        ram_201632.song[dir][song].slot[2] = 0xffffffffUL;
        ram_201632.song[dir][song].part[2] = 0;
    }
}

#define FLS_I1(o, f, i) (*(unsigned char *)((unsigned long)HDAE5000_RAM_FlsRecords + (o) + ((unsigned long)(f) * 144 + (i))))
#define FLS_I2(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))

int FlsItemClear_i1(unsigned int fls, unsigned int item)
{
    FLS_I1(16, fls, item) = 0;
    FLS_I1(48, fls, item) = 0;
    FLS_I1(80, fls, item) = 0;
    FLS_I1(112, fls, item) = 0;
    return 0;
}

int FlsItemClear_i2(unsigned int fls, unsigned int item)
{
    FLS_I2(16, fls, item) = 0;
    FLS_I2(48, fls, item) = 0;
    FLS_I2(80, fls, item) = 0;
    FLS_I2(112, fls, item) = 0;
    return 0;
}
