/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_6a.c (2026-11-16-45-p6-r9)
   sha256 0aba4f340e3599d581d783318d3005acf17c6d64d605c3d6dbff3c5f63208f2d (tar-sha256); compiled at -O3 -Xr */
extern char LoadSMF_GetRecordPtr_Str_rb[];
extern int GetFirstPageBase(void);
extern char *GetRecordPtrForFile(int);
extern int FileIO_OpenWithMode(char *, char *);
extern int FileIO_ReturnError(void);
extern int SMF_SelectBankAndLoad(int, int);
extern void FileIO_CloseHandle(void);
extern void FileIO_WriteRecordName(char *);
int LoadFileSMF(unsigned char a, unsigned char b)
{
    char *rec;
    int r, pg;
    pg = GetFirstPageBase();
    if (pg < 0) return -104;
    rec = GetRecordPtrForFile(pg);
    if (FileIO_OpenWithMode(rec, LoadSMF_GetRecordPtr_Str_rb) < 0) return FileIO_ReturnError();
    r = SMF_SelectBankAndLoad(a, b);
    FileIO_CloseHandle();
    FileIO_WriteRecordName(rec);
    return r;
}
