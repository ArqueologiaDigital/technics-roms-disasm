/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r39_m4c.c (2026-11-17-10-hd-r39)
   sha256 a156162aaeb59eb88ab8cd69df2728adb822f9731fc6c9976271bbb46e41cff9 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern char *__cdecl HDAE5000_StrCpy(unsigned char *, char *);
extern void HDAE5000_NameHistory_AfterPushNop(unsigned char *hist);
void HDAE5000_NameHistory_Push(unsigned char *hist, char *name)
{
    HDAE5000_StrCpy(&hist[hist[2] * 27 + 4], name);
    hist[1] = hist[2];
    if (++hist[2] >= 5)
        hist[2] = 0;
    if (hist[0] < 5)
        hist[0]++;
    HDAE5000_NameHistory_AfterPushNop(hist);
}
