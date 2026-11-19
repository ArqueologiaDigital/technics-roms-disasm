/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/file_demo_proc_m266.c (2026-11-19-29-p6-r46)
   sha256 d8b4511ebb7d09d58f543ad2407bd6007c0edfa880abb78797db7a20c970a65d (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
