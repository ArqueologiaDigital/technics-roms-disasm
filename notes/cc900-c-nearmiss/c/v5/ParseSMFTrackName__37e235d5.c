/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/file_demo_proc_m268.c (2026-11-18-34-p6-r38-staged)
   sha256 37e235d5d02e9b9f3b20ba24a55a27c7a808391da024823d4a02be942531db12 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
