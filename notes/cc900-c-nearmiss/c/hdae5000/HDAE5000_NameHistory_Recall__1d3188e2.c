/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r54_misc_fls.c (2026-11-18-20-hd-r55)
   sha256 1d3188e2f76bcc604c417e618ea07e1847791ea24fcf89aea36f53ddde9e68ff (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct NameHist { unsigned char count; unsigned char idx; unsigned char pad[2]; char name[5][27]; };
char *HDAE5000_NameHistory_Recall(struct NameHist *h)
{
    char *p;

    if (h->count != 0) {
        p = h->name[h->idx];
        if (h->idx == 0) {
            if (h->count == 5)
                h->idx = 4;
            else
                h->idx = h->count - 1;
        } else
            h->idx--;
    } else
        p = 0;
    return p;
}
