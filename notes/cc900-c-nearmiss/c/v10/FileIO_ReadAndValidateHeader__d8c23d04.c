/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_6b.c (2026-11-16-45-p6-r9)
   sha256 d8c23d04522aec171aa28df55c10e94ff12aceb37e57c0c9258fc07955f44d2f (tar-sha256); compiled at -O3 -Xr
   cc900-name: HdrStr_G=FileIO_ReadValidateHdr_Store_Str_G
   cc900-name: HdrStr_H=FileIO_ReadValidateHdr_Store_Str_H
   cc900-name: HdrStr_LKE=FileIO_ReadValidateHdr_Store_Str_LKE */
extern char HdrStr_G[];
extern char HdrStr_LKE[];
extern char HdrStr_H[];
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
    r = FileIO_Search_SkipEntry(buf, HdrStr_H, 3) == 0 || FileIO_Search_SkipEntry(buf, HdrStr_G, 3) == 0
        || FileIO_Search_SkipEntry(buf, HdrStr_LKE, 3) == 0;
    return r;
}
