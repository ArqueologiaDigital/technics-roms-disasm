/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_3m266b.c (2026-11-16-87-p6-r15)
   sha256 ba04cd2758ae3dbed7561438e9f63ed5f676d378170ee3db4767fed362da5ff4 (tar-sha256); compiled at -O3 -XS -Xr */
extern int FileIO_SeekAndReadBlock(unsigned long, int);
extern int FileIO_ReadByte(void);
extern void FileIO_SeekRead_ExtReturn(void);
extern char *FileIO_HeaderAt4_ExpectedPtr;
int FileIO_ReadHeaderAt4(void)
{
    int ok;
    int n;

    ok = 1;
    FileIO_SeekAndReadBlock(4, 0);
    n = FileIO_ReadByte();
    if (n < 0 || (unsigned char)*FileIO_HeaderAt4_ExpectedPtr != (unsigned char)n) ok = 0;
    FileIO_SeekRead_ExtReturn();
    return ok;
}
