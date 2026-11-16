/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_8b.c (2026-11-16-53-p6-r11)
   sha256 2e653ef8b65fbca41cde47c6cf85f0d99977fce6cf00e855ff8dcb59f7554120 (tar-sha256); compiled at -O3 -Xr */
extern int GetFirstPageBase(void);
extern char *GetRecordPtrForFile(int);
extern int FileIO_OpenWithMode(char *, char *);
extern int FileIO_ReturnError(void);
extern int SMF_SelectBankAndLoad(int, int);
extern void FileIO_CloseHandle(void);
extern void FileIO_WriteRecordName(char *);
int LoadFileSMF(int a, unsigned char b)
{
    char *rec;
    int r, pg;
    pg = GetFirstPageBase();
    if (pg < 0) return -104;
    if (FileIO_OpenWithMode(rec = GetRecordPtrForFile(pg), (char *)0xea0240) < 0) return FileIO_ReturnError();
    r = SMF_SelectBankAndLoad(a & 0xff, b);
    FileIO_CloseHandle();
    FileIO_WriteRecordName(rec);
    return r;
}
