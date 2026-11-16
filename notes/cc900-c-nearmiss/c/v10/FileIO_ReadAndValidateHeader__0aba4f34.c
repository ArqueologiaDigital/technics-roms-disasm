/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_6a.c (2026-11-16-45-p6-r9)
   sha256 0aba4f340e3599d581d783318d3005acf17c6d64d605c3d6dbff3c5f63208f2d (tar-sha256); compiled at -O3 -Xr
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
    i = 0;
    do {
        c = FileIO_ReadByte();
        if (c < 0) c = 0;
        buf[i] = c;
        i++;
    } while (i < 3);
    FileIO_SeekRead_ExtReturn();
    r = 0;
    if (FileIO_Search_SkipEntry(buf, HdrStr_H, 3) == 0 || FileIO_Search_SkipEntry(buf, HdrStr_G, 3) == 0
        || FileIO_Search_SkipEntry(buf, HdrStr_LKE, 3) == 0) r = 1;
    return r;
}
