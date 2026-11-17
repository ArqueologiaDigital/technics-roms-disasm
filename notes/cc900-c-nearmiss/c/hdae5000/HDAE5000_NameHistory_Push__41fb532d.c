/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_small2.c (2026-11-17-13-hd-r42-ports)
   sha256 41fb532d04b1cddcad2b89adfb641aa4f14ab58d55121e6a1f2ac49d2d663760 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: NameHistPush_s=HDAE5000_NameHistory_Push */
struct NameHist { unsigned char count; unsigned char recall; unsigned char next; unsigned char pad; char names[5][27]; };
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern void HDAE5000_NameHistory_AfterPushNop(unsigned char *hist);
void NameHistPush_s(struct NameHist *hist, char *name)
{
    HDAE5000_StrCpy(hist->names[hist->next], name);
    hist->recall = hist->next;
    if (++hist->next >= 5)
        hist->next = 0;
    if (hist->count < 5)
        hist->count++;
    HDAE5000_NameHistory_AfterPushNop((unsigned char *)hist);
}
