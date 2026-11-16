/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern long ram_25d6c;
extern long FileIO_DiskInfoInit;
extern unsigned int FILE_ERROR;

int FileIO_ValidateRecord_CheckSize(unsigned char a)
{
    if (format_FD(a) != 0) return 0;
    if (FILE_ERROR == 31) return -11;
    return -6;
}

long GetEncodedFreeSpaceData(void)
{
    long *p = &ram_25d6c;
    if (FileIO_DiskInfoInit == *p) GetDiskFreeSpace(p, p + 1);
    return ram_25d6c;
}

int ReadVariableLengthInt(void)
{
    unsigned long v = 0;
    int c;
    while ((c = FileIO_ReadByte()) > 0x7f) {
        v += (long)(c & 0x7f);
        v <<= 7;
    }
    if (c < 0) return -1;
    v += (long)c;
    return (int)(v > 0x7fff ? 0x7fff : v);
}

void Demo_ParseSlideHeader(unsigned char i)
{
    long v;
    if ((v = ((long *)0x9c4000)[i]) != 0) SLIDE_Parse_Header(v, (unsigned char *)0x69800);
}
