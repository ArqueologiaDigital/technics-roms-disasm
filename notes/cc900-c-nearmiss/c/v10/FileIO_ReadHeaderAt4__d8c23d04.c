/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_6b.c (2026-11-16-45-p6-r9)
   sha256 d8c23d04522aec171aa28df55c10e94ff12aceb37e57c0c9258fc07955f44d2f (tar-sha256); compiled at -O3 -Xr */
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
    if (c < 0 || (char)c != (char)*FileIO_HeaderAt4_ExpectedPtr) ok = 0;
    FileIO_SeekRead_ExtReturn();
    return ok;
}
