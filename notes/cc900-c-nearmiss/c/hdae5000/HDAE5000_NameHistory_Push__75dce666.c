/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r39_m4b.c (2026-11-17-10-hd-r39)
   sha256 75dce666262ad6245a0cf470aa3b9500bd5e6bf9fa418e9e48fad6c1296568a0 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern void HDAE5000_NameHistory_AfterPushNop(unsigned char *hist);
void HDAE5000_NameHistory_Push(unsigned char *hist, char *name)
{
    HDAE5000_StrCpy((char *)&hist[hist[2] * 27 + 4], name);
    hist[1] = hist[2];
    if (++hist[2] >= 5)
        hist[2] = 0;
    if (hist[0] < 5)
        hist[0]++;
    HDAE5000_NameHistory_AfterPushNop(hist);
}
