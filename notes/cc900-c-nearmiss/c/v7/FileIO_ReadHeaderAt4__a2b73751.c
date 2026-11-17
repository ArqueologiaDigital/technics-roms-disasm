/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/file_demo_proc_m266.c (2026-11-16-68-p6-r12)
   sha256 a2b7375184f6dfe24c5caf7137098511a5df716d30ac6f43c5d420d3e8fce430 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void FileIO_SeekAndReadBlock(long, int);
extern int FileIO_ReadByte(void);
extern void FileIO_SeekRead_ExtReturn(void);
extern unsigned char *FileIO_HeaderAt4_ExpectedPtr;
int FileIO_ReadHeaderAt4(void)
{
    int ok = 1;
    int c;
    FileIO_SeekAndReadBlock(4, 0);
    c = FileIO_ReadByte();
    if (c < 0 || (char)c != (char)*FileIO_HeaderAt4_ExpectedPtr) ok = 0;
    FileIO_SeekRead_ExtReturn();
    return ok;
}
