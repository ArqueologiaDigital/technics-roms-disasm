/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_3m266b.c (2026-11-16-87-p6-r15)
   sha256 ba04cd2758ae3dbed7561438e9f63ed5f676d378170ee3db4767fed362da5ff4 (tar-sha256); compiled at -O3 -XS -Xr */
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
        if (n < 0 || (unsigned char)FileIO_RegionSignatures[r].sig[i] != (unsigned char)n) {
            ok = 0;
            break;
        }
    }
    FileIO_SeekRead_ExtReturn();
    return ok;
}
