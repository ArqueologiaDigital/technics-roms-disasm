/* lane_hd round 13: DirName_Address returns its row's address; the ROM computes the index and then loads the
   table base as an immediate (ld xhl, sym; add xhl, xwa) where V4.23 wrote lda for every value spelling so far
   (runs 48, 52, 54).  Spellings suggested by the coordinator and lane_hd: integer arithmetic with a shift, &arr[0],
   a register offset, an integer constant, the symbol as the integer addend, a row struct, a local pointer, an
   integer return, a void * return, a pointer-typed constant (s10: HDAE5000_RAM_DirPtr is a #define).
   cc900-name: DNA_s1=HDAE5000_DirName_Address
   cc900-name: DNA_s2=HDAE5000_DirName_Address
   cc900-name: DNA_s3=HDAE5000_DirName_Address
   cc900-name: DNA_s4=HDAE5000_DirName_Address
   cc900-name: DNA_s5=HDAE5000_DirName_Address
   cc900-name: DNA_s6=HDAE5000_DirName_Address
   cc900-name: DNA_s7=HDAE5000_DirName_Address
   cc900-name: DNA_s8=HDAE5000_DirName_Address
   cc900-name: DNA_s9=HDAE5000_DirName_Address
   cc900-name: DNA_s10=HDAE5000_DirName_Address
*/

struct DirRow { unsigned char n[16]; };
extern unsigned char HDAE5000_RAM_DirNames[];
#define HDAE5000_RAM_DirPtr ((unsigned char *)HDAE5000_RAM_DirNames)

unsigned char *DNA_s1(unsigned int dir)
{
    return (unsigned char *)((unsigned long)HDAE5000_RAM_DirNames + ((unsigned long)dir << 4));
}

unsigned char *DNA_s2(unsigned int dir)
{
    return &HDAE5000_RAM_DirNames[0] + (unsigned long)dir * 16;
}

unsigned char *DNA_s3(unsigned int dir)
{
    unsigned long o;
    o = (unsigned long)dir * 16;
    return HDAE5000_RAM_DirNames + o;
}

unsigned char *DNA_s4(unsigned int dir)
{
    return (unsigned char *)(0x201632L + (unsigned long)dir * 16);
}

unsigned char *DNA_s5(unsigned int dir)
{
    return (unsigned char *)((unsigned long)dir * 16) + (unsigned long)HDAE5000_RAM_DirNames;
}

unsigned char *DNA_s6(unsigned int dir)
{
    return ((struct DirRow *)HDAE5000_RAM_DirNames + dir)->n;
}

unsigned char *DNA_s7(unsigned int dir)
{
    unsigned char *p;
    p = HDAE5000_RAM_DirNames;
    p += (unsigned long)dir * 16;
    return p;
}

unsigned long DNA_s8(unsigned int dir)
{
    return (unsigned long)&HDAE5000_RAM_DirNames[(unsigned long)dir * 16];
}

void *DNA_s9(unsigned int dir)
{
    return (void *)(HDAE5000_RAM_DirNames + (unsigned long)dir * 16);
}

unsigned char *DNA_s10(unsigned int dir)
{
    return HDAE5000_RAM_DirPtr + (unsigned long)dir * 16;
}
