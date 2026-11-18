/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_4m268a.c (2026-11-18-33-p6-r37)
   sha256 a31d89d9b4053c23ae497960140164db5c5fd76553da7fd9601b1e87eb307f3b (tar-sha256); compiled at -Xr */
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
    while (ReadVariableLengthInt() == 0) {
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
    }
    return ram_25b90;
}
