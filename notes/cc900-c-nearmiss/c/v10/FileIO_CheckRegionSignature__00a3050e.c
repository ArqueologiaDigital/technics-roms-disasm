/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_2m266a.c (2026-11-16-72-p6-r13)
   sha256 00a3050edbce2126ea4971740c663aeb953b28ceeeca880ccd8150667bf4e0e6 (tar-sha256); compiled at -O3 -Xr */
extern int FileIO_SeekAndReadBlock(unsigned long, int);
extern int FileIO_ReadByte(void);
extern void FileIO_SeekRead_ExtReturn(void);
struct SigRec { unsigned char *sig; unsigned int off; unsigned int len; };
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
        if (n < 0 || (unsigned char)n != FileIO_RegionSignatures[r].sig[i]) {
            ok = 0;
            break;
        }
    }
    FileIO_SeekRead_ExtReturn();
    return ok;
}
