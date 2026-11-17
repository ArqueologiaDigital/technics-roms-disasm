/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_2m266b.c (2026-11-16-72-p6-r13)
   sha256 9c4ec7f6abb5ae90f953dbe91460597c6ac48085d807a5be423c9414b8d5dea5 (tar-sha256); compiled at -O3 -Xr */
extern int FileIO_SeekAndReadBlock(unsigned long, int);
extern int FileIO_ReadByte(void);
extern void FileIO_SeekRead_ExtReturn(void);
extern unsigned char *FileIO_HeaderAt4_ExpectedPtr;
int FileIO_ReadHeaderAt4(void)
{
    int ok;
    int n;

    ok = 1;
    FileIO_SeekAndReadBlock(4, 0);
    n = FileIO_ReadByte();
    if (n < 0 || (unsigned char)n != *FileIO_HeaderAt4_ExpectedPtr) ok = 0;
    FileIO_SeekRead_ExtReturn();
    return ok;
}
