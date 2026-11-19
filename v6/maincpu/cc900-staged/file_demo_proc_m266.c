/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

struct ffblk { unsigned char b[266]; };
extern int GetFirstPageBase(void);
extern char *GetRecordPtrForFile(int);
extern long _findfirst(char *, struct ffblk *);
extern void _findclose(long);
extern int FileIO_CopyAndOpen(char *, char *);
extern int SearchAndOpen(char *name);

int SearchAndOpen(char *name)
{
    struct ffblk f;
    int pg;
    long h;
    pg = GetFirstPageBase();
    if (pg < 0) return -104;
    h = _findfirst(name, &f);
    if (h < 0) return FileIO_CopyAndOpen(GetRecordPtrForFile(pg), name);
    _findclose(h);
    return -10;
}
