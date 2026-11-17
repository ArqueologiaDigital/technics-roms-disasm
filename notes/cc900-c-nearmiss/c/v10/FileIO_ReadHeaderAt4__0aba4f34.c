/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_6a.c (2026-11-16-45-p6-r9)
   sha256 0aba4f340e3599d581d783318d3005acf17c6d64d605c3d6dbff3c5f63208f2d (tar-sha256); compiled at -O3 -Xr */
extern unsigned char *FileIO_HeaderAt4_ExpectedPtr;
extern void FileIO_SeekAndReadBlock(long, int);
extern int FileIO_ReadByte(void);
extern void FileIO_SeekRead_ExtReturn(void);
int FileIO_ReadHeaderAt4(void)
{
    int ok = 1;
    int c;
    FileIO_SeekAndReadBlock(4, 0);
    c = FileIO_ReadByte();
    if (c < 0 || (unsigned char)c != *FileIO_HeaderAt4_ExpectedPtr) ok = 0;
    FileIO_SeekRead_ExtReturn();
    return ok;
}
