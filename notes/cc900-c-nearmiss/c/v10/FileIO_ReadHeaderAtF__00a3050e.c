/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_2m266a.c (2026-11-16-72-p6-r13)
   sha256 00a3050edbce2126ea4971740c663aeb953b28ceeeca880ccd8150667bf4e0e6 (tar-sha256); compiled at -O3 -XS -Xr */
extern int FileIO_SeekAndReadBlock(unsigned long, int);
extern int FileIO_ReadByte(void);
extern void FileIO_SeekRead_ExtReturn(void);
int FileIO_ReadHeaderAtF(void)
{
    int ok;
    int n;

    ok = 1;
    FileIO_SeekAndReadBlock(0xf, 0);
    n = FileIO_ReadByte();
    if (n < 0 || (unsigned char)n != 8) ok = 0;
    FileIO_SeekRead_ExtReturn();
    return ok;
}
