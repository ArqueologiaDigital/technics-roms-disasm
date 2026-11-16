/* lane_hd round 2b, variants: several C spellings of one function, mapped to its label by cc900-name comments.
   Questions (run 2026-11-16-46-hd-r2, helper forms hd_r2_s*.c):
   - DirName_Address: the ROM loads the table base with the 5-byte `ld xhl, imm32` after the index, where V4.23 wrote
     `lda` (r1b) or added the constant (`add xhl, imm`, r2 sc); form sc's DeleteSongPart got `ld xwa, imm` for
     `DirNames + offset`, so the form decides it;
   - DeleteSongPart_Sqt: the ROM folds the field offset into the symbol (`lda xwa,(DirNames+44)`) after computing
     the record offset; `DirNames + 44 + ofs` was reassociated to `DirNames + (44 + ofs)` (form sb);
   - FlsItem_Clear: the same with `lda xde,(FlsRecords+16)`.
   cc900-name: DirNameAddr_v1=HDAE5000_DirName_Address
   cc900-name: DirNameAddr_v2=HDAE5000_DirName_Address
   cc900-name: DirNameAddr_v3=HDAE5000_DirName_Address
   cc900-name: DirNameAddr_v4=HDAE5000_DirName_Address
   cc900-name: DirNameAddr_v5=HDAE5000_DirName_Address
   cc900-name: DelPartSqt_v1=HDAE5000_DeleteSongPart_Sqt
   cc900-name: DelPartSqt_v2=HDAE5000_DeleteSongPart_Sqt
   cc900-name: FlsItemClear_v1=HDAE5000_FlsItem_Clear
   cc900-name: FlsItemClear_v2=HDAE5000_FlsItem_Clear
*/

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_FlsRecords[];
extern void HDAE5000_HD_FreeChain(unsigned long first);

unsigned char *DirNameAddr_v1(unsigned int dir)
{
    unsigned char *p;
    p = HDAE5000_RAM_DirNames + (unsigned long)dir * 16;
    return p;
}

unsigned char *DirNameAddr_v2(unsigned int dir)
{
    return &HDAE5000_RAM_DirNames[(unsigned long)dir * 16];
}

unsigned char *DirNameAddr_v3(unsigned int dir)
{
    return (unsigned char *)(HDAE5000_RAM_DirNames + (unsigned long)dir * 16);
}

unsigned char *DirNameAddr_v4(unsigned int dir)
{
    return HDAE5000_RAM_DirNames + dir * 16L;
}

unsigned char *DirNameAddr_v5(unsigned int dir)
{
    return (unsigned char *)((unsigned long)dir * 16 + HDAE5000_RAM_DirNames);
}

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT1(o, d, s) (*(unsigned long *)(&HDAE5000_RAM_DirNames[o] + SONG_OFS(d, s)))
#define PART1(o, d, s) (*(&HDAE5000_RAM_DirNames[o] + SONG_OFS(d, s)))
#define SLOT2(o, d, s) (*(unsigned long *)((unsigned char *)&HDAE5000_RAM_DirNames[o] + SONG_OFS(d, s)))
#define PART2(o, d, s) ((&HDAE5000_RAM_DirNames[o])[SONG_OFS(d, s)])

void DelPartSqt_v1(unsigned int dir, unsigned int song)
{
    if (SLOT1(44, dir, song) != 0xffffffffUL) {
        HDAE5000_HD_FreeChain(SLOT1(44, dir, song));
        SLOT1(44, dir, song) = 0xffffffffUL;
        PART1(28, dir, song) = 0;
    }
}

void DelPartSqt_v2(unsigned int dir, unsigned int song)
{
    if (SLOT2(44, dir, song) == 0xffffffffUL)
        return;
    HDAE5000_HD_FreeChain(SLOT2(44, dir, song));
    SLOT2(44, dir, song) = 0xffffffffUL;
    PART2(28, dir, song) = 0;
}

int FlsItemClear_v1(unsigned int fls, unsigned int item)
{
    (&HDAE5000_RAM_FlsRecords[16])[(unsigned long)fls * 144 + item] = 0;
    (&HDAE5000_RAM_FlsRecords[48])[(unsigned long)fls * 144 + item] = 0;
    (&HDAE5000_RAM_FlsRecords[80])[(unsigned long)fls * 144 + item] = 0;
    (&HDAE5000_RAM_FlsRecords[112])[(unsigned long)fls * 144 + item] = 0;
    return 0;
}

int FlsItemClear_v2(unsigned int fls, unsigned int item)
{
    *(&HDAE5000_RAM_FlsRecords[16] + ((unsigned long)fls * 144 + item)) = 0;
    *(&HDAE5000_RAM_FlsRecords[48] + ((unsigned long)fls * 144 + item)) = 0;
    *(&HDAE5000_RAM_FlsRecords[80] + ((unsigned long)fls * 144 + item)) = 0;
    *(&HDAE5000_RAM_FlsRecords[112] + ((unsigned long)fls * 144 + item)) = 0;
    return 0;
}
