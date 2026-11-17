/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_8a.c (2026-11-16-53-p6-r11)
   sha256 059fc1dbc74e38faafb386fe8d5405b2a2d3d26241e37ac23ba5310d1dcc5b81 (tar-sha256); compiled at -O3 -Xr */
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
    r = FileIO_Search_SkipEntry(buf, (char *)0xea017e, 3) == 0 || FileIO_Search_SkipEntry(buf, (char *)0xea0176, 3) == 0
        || FileIO_Search_SkipEntry(buf, (char *)0xea017a, 3) == 0;
    return r;
}
