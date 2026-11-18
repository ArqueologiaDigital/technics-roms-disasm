/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_6a.c (2026-11-16-45-p6-r9)
   sha256 0aba4f340e3599d581d783318d3005acf17c6d64d605c3d6dbff3c5f63208f2d (tar-sha256); compiled at -O3 -Xr */
struct ffblk { unsigned char b[266]; };
extern int GetFirstPageBase(void);
extern char *GetRecordPtrForFile(int);
extern long _findfirst(char *, struct ffblk *);
extern void _findclose(long);
extern int FileIO_CopyAndOpen(char *, char *);
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
