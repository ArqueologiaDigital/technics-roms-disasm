/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_8b.c (2026-11-16-53-p6-r11)
   sha256 2e653ef8b65fbca41cde47c6cf85f0d99977fce6cf00e855ff8dcb59f7554120 (tar-sha256); compiled at -O3 -Xr */
extern void FileIO_SeekAndReadBlock(long, int);
extern int FileIO_ReadByte(void);
extern void FileIO_SeekRead_ExtReturn(void);
extern int FileIO_Search_SkipEntry(char *, char *, int);
int FileIO_ReadAndValidateHeader(void)
{
    char buf[3];
    int i, c, r;
    FileIO_SeekAndReadBlock(0, 0);
    for (i = 0; i < 3; i++) {
        if ((c = FileIO_ReadByte()) < 0) c = 0;
        buf[i] = c;
    }
    FileIO_SeekRead_ExtReturn();
    r = 0;
    if (FileIO_Search_SkipEntry(buf, (char *)0xea017e, 3) == 0 || FileIO_Search_SkipEntry(buf, (char *)0xea0176, 3) == 0
        || FileIO_Search_SkipEntry(buf, (char *)0xea017a, 3) == 0) r = 1;
    return r;
}
