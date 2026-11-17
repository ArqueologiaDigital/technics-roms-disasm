/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/file_demo_proc_m266.c (2026-11-16-92-p6-r18)
   sha256 0528750542936aeb728fc2988d744df8834207d0254fe3c6071e61e209a55923 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern int FileIO_SeekAndReadBlock(unsigned long, int);
extern int FileIO_ReadByte(void);
extern void FileIO_SeekRead_ExtReturn(void);
struct SigRec { char *sig; unsigned int off; unsigned int len; };
extern struct SigRec FileIO_RegionSignatures[];
int FileIO_CheckRegionSignature(unsigned char r)
{
    int i;
    int ok;
    int n;

    FileIO_SeekAndReadBlock(FileIO_RegionSignatures[r].off, 0);
    ok = 1;
    for (i = 0; i < FileIO_RegionSignatures[r].len; i++) {
        n = FileIO_ReadByte();
        if (n < 0 || (unsigned char)n != (unsigned char)FileIO_RegionSignatures[r].sig[i]) {
            ok = 0;
            break;
        }
    }
    FileIO_SeekRead_ExtReturn();
    return ok;
}
