/* Phase 6, lane_p6 helper C, round 12, module 159 (modules_v10.tsv): v10 factory_test/fd_test_code.s's FDLoadSaveTest,
   the floppy write / read-back self test.  FDTest_PrintDiag (module 159) is called by calr; the file and memory
   routines are the library's stack-argument (cdecl) ones, called by call.  Strings are the ROM's own labels; the ones
   longer than 31 characters have short C names. */
/* cc900-module: FDTest_PrintDiag */

/* cc900-name: FDStr_A_IMMUNITY_TST=FDLoadSaveTest_Str_A_IMMUNITY_TST */
extern char FDStr_A_IMMUNITY_TST[];
extern char FDLoadSaveTest_Str_error[];
extern char FDLoadSaveTest_Str_File_remove[];
/* cc900-name: FDStr_Not_Enough_memory=FDTest_AllocBuffer_Str_Not_Enough_memory */
extern char FDStr_Not_Enough_memory[];
/* cc900-name: FDStr_File_Read=FDTest_CloseAndReopen_Str_File_Read */
extern char FDStr_File_Read[];
extern char FDTest_CloseAndReopen_Str_OK[];
extern char FDTest_CloseAndReopen_Str_rb[];
extern char FDTest_CompareResult_Str_Error[];
extern char FDTest_OpenFailed_Str_OK[];
/* cc900-name: FDStr_cannot_open_write=FDTest_OpenForWrite_Str_cannot_open_write_file */
extern char FDStr_cannot_open_write[];
extern char FDTest_OpenForWrite_Str_wb[];
extern char FDTest_Pass_Str_OK[];
extern char FDTest_ReadBack_Str_error[];
/* cc900-name: FDStr_CannotOpenReadFile=FDTest_String_CannotOpenReadFile */
extern char FDStr_CannotOpenReadFile[];
extern char FDTest_String_DataCompare[];
extern char FDTest_VerifyData_Str_OK[];
extern char FDTest_WriteBuffer_Str_Error[];
/* cc900-name: FDStr_File_Write=FDTest_WriteBuffer_Str_File_Write */
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
