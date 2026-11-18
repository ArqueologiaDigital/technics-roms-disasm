/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_4m268b.c (2026-11-18-33-p6-r37)
   sha256 e7ade6145fb3cd2d90fb7b327e0a1787826747b13aa4a904136f46c99c44c130 (tar-sha256); compiled at -O3 -Xr */
extern char ram_25b90[];
extern int ReadVariableLengthInt(void);
extern int FileIO_ReadByte(void);
extern void ReadFieldToBuffer(int len, char *buf);
extern void FileIO_SeekAndReadBlock(long, int);
extern int FileIO_ReturnError(void);
char *ParseSMFTrackName(void)
{
    int len;
    int status;
    int c;

    len = 0;
    ram_25b90[0] = 0;
    status = 0;
    if (ReadVariableLengthInt() != 0)
        return ram_25b90;
    do {
        c = FileIO_ReadByte();
        if (c == 0xff) {
            status = FileIO_ReadByte();
            len = ReadVariableLengthInt();
            if (status == 3) {
                ReadFieldToBuffer(len, ram_25b90);
                len = 0;
            }
            status = 0;
        } else if (c == 0xf0 || c == 0xf7) {
            len = ReadVariableLengthInt();
            status = 0;
        } else if (c >= 0xc0 && c <= 0xdf) {
            len = 2;
            status = c;
        } else if (c >= 0x80 && c <= 0xef) {
            len = 3;
            status = c;
        } else if (c <= 0x7f) {
            if (status >= 0xc0 && status <= 0xdf)
                len = 1;
            else
                len = 2;
        }
        if (len > 0)
            FileIO_SeekAndReadBlock(len, 1);
        if (FileIO_ReturnError() < 0)
            return 0;
    } while (ReadVariableLengthInt() == 0);
    return ram_25b90;
}
