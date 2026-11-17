/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_12m159.c (2026-11-16-92-p6-r18)
   sha256 c7a8b3d13c33b323d9a85d19d55105529a6be6c2caa0de5b0d23ee8a6f529372 (tar-sha256); compiled at -Xr
   cc900-name: FDStr_A_IMMUNITY_TST=FDLoadSaveTest_Str_A_IMMUNITY_TST
   cc900-name: FDStr_CannotOpenReadFile=FDTest_String_CannotOpenReadFile
   cc900-name: FDStr_File_Read=FDTest_CloseAndReopen_Str_File_Read
   cc900-name: FDStr_File_Write=FDTest_WriteBuffer_Str_File_Write
   cc900-name: FDStr_Not_Enough_memory=FDTest_AllocBuffer_Str_Not_Enough_memory
   cc900-name: FDStr_cannot_open_write=FDTest_OpenForWrite_Str_cannot_open_write_file */
extern char FDStr_A_IMMUNITY_TST[];
extern char FDLoadSaveTest_Str_error[];
extern char FDLoadSaveTest_Str_File_remove[];
extern char FDStr_Not_Enough_memory[];
extern char FDStr_File_Read[];
extern char FDTest_CloseAndReopen_Str_OK[];
extern char FDTest_CloseAndReopen_Str_rb[];
extern char FDTest_CompareResult_Str_Error[];
extern char FDTest_OpenFailed_Str_OK[];
extern char FDStr_cannot_open_write[];
extern char FDTest_OpenForWrite_Str_wb[];
extern char FDTest_Pass_Str_OK[];
extern char FDTest_ReadBack_Str_error[];
extern char FDStr_CannotOpenReadFile[];
extern char FDTest_String_DataCompare[];
extern char FDTest_VerifyData_Str_OK[];
extern char FDTest_WriteBuffer_Str_Error[];
extern char FDStr_File_Write[];
extern void FDTest_PrintDiag(char *);
extern int __cdecl FileOpenDefault(char *);
extern void *__cdecl Malloc(int);
extern void __cdecl Free(void *);
extern void *__cdecl FileOpen(char *, char *);
extern int __cdecl FileWrite(void *, int, int, void *);
extern int __cdecl FileRead(void *, int, int, void *);
extern void __cdecl FileClose(void *);
extern void __cdecl Memset(void *, int, int);
int FDLoadSaveTest(void)
{
    unsigned int *buf;
    unsigned int *p;
    void *fp;
    unsigned int i;
    int bad;
    FDTest_PrintDiag(FDLoadSaveTest_Str_File_remove);
    if (FileOpenDefault(FDStr_A_IMMUNITY_TST) != 0) FDTest_PrintDiag(FDLoadSaveTest_Str_error);
    else FDTest_PrintDiag(FDTest_OpenFailed_Str_OK);
    buf = Malloc(0x800);
    if (buf == 0) {
        FDTest_PrintDiag(FDStr_Not_Enough_memory);
        Free(buf);
        return -1;
    }
    p = buf;
    for (i = 0; i < 0x400; i++) *p++ = i;
    fp = FileOpen(FDStr_A_IMMUNITY_TST, FDTest_OpenForWrite_Str_wb);
    if (fp == 0) {
        FDTest_PrintDiag(FDStr_cannot_open_write);
        Free(buf);
        return -1;
    }
    FDTest_PrintDiag(FDStr_File_Write);
    if (FileWrite(buf, 1, 0x800, fp) != 0x800) {
        FDTest_PrintDiag(FDTest_WriteBuffer_Str_Error);
        Free(buf);
        return -1;
    }
    FDTest_PrintDiag(FDTest_CloseAndReopen_Str_OK);
    FileClose(fp);
    Memset(buf, 0, 0x800);
    FDTest_PrintDiag(FDStr_File_Read);
    fp = FileOpen(FDStr_A_IMMUNITY_TST, FDTest_CloseAndReopen_Str_rb);
    if (fp == 0) {
        FDTest_PrintDiag(FDStr_CannotOpenReadFile);
        Free(buf);
        return -1;
    }
    if (FileRead(buf, 1, 0x800, fp) != 0x800) {
        FDTest_PrintDiag(FDTest_ReadBack_Str_error);
        Free(buf);
        return -1;
    }
    FDTest_PrintDiag(FDTest_VerifyData_Str_OK);
    FileClose(fp);
    p = buf;
    bad = 0;
    for (i = 0; i < 0x400; i++)
        if (*p++ != i) bad++;
    FDTest_PrintDiag(FDTest_String_DataCompare);
    if (bad != 0) {
        FDTest_PrintDiag(FDTest_CompareResult_Str_Error);
        Free(buf);
        return -1;
    }
    Free(buf);
    FDTest_PrintDiag(FDTest_Pass_Str_OK);
    return 0;
}
