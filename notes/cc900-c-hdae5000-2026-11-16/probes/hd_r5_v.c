/* lane_hd round 5, variants: DirName_Address returns its row's address; the ROM loads the table base as an
   immediate (`ld xhl, sym`) after the index, where every value spelling so far gave `lda` (runs 48, 52).  Under
   V4.23 a dereferenced address took `ld imm` (runs 46, 48), so these try address-of forms over a dereference.
   cc900-name: DirNameAddr_r1=HDAE5000_DirName_Address
   cc900-name: DirNameAddr_r2=HDAE5000_DirName_Address
   cc900-name: DirNameAddr_r3=HDAE5000_DirName_Address
   cc900-name: DirNameAddr_r4=HDAE5000_DirName_Address
*/
struct DirRow { unsigned char name[16]; };
extern unsigned char HDAE5000_RAM_DirNames[];

unsigned char *DirNameAddr_r1(unsigned int dir)
{
    return &((struct DirRow *)HDAE5000_RAM_DirNames)[dir].name[0];
}

unsigned char *DirNameAddr_r2(unsigned int dir)
{
    return ((struct DirRow *)HDAE5000_RAM_DirNames)[dir].name;
}

unsigned char *DirNameAddr_r3(unsigned int dir)
{
    return &*(HDAE5000_RAM_DirNames + (unsigned long)dir * 16);
}

unsigned char *DirNameAddr_r4(unsigned int dir)
{
    return (unsigned char *)&((struct DirRow *)HDAE5000_RAM_DirNames)[dir];
}
