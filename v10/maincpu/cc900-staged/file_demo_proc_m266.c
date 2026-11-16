/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void SLIDE_Parse_Header(long, unsigned char *);
extern void FileIO_SeekAndReadBlock(long, int);
extern int FileIO_ReadByte(void);
extern void FileIO_SeekRead_ExtReturn(void);
extern unsigned char *FileIO_HeaderAt4_ExpectedPtr;

void Demo_ParseSlideHeader(unsigned char i)
{
    long v;
    if ((v = ((long *)0x9c4000)[i]) != 0) SLIDE_Parse_Header(v, (unsigned char *)0x69800);
}

int FileIO_ReadHeaderAtF(void)
{
    int ok = 1;
    int c;
    FileIO_SeekAndReadBlock(15, 0);
    c = FileIO_ReadByte();
    if (c < 0 || (unsigned char)c != 8) ok = 0;
    FileIO_SeekRead_ExtReturn();
    return ok;
}

int FileIO_ReadHeaderAt4(void)
{
    int ok = 1;
    int c;
    FileIO_SeekAndReadBlock(4, 0);
    c = FileIO_ReadByte();
    if (c < 0 || (char)c != (char)*FileIO_HeaderAt4_ExpectedPtr) ok = 0;
    FileIO_SeekRead_ExtReturn();
    return ok;
}
