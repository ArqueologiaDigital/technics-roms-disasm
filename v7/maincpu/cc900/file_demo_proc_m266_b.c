/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FileIO_CheckRegionSignature FileIO_ReadHeaderAt4 */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int FileIO_SeekAndReadBlock(unsigned long, int);
extern int FileIO_ReadByte(void);
extern void FileIO_SeekRead_ExtReturn(void);
struct SigRec { char *sig; unsigned int off; unsigned int len; };
extern struct SigRec FileIO_RegionSignatures[];
extern int FileIO_CheckRegionSignature(unsigned char r);

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
