/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_fls_small.c (2026-11-18-26-hd-r56-ports)
   sha256 2f21fb2fbd9da944370fff660f77c16abdd46a929d52b43872efd1c6dc487e25 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: NameHistRecall_b=HDAE5000_NameHistory_Recall */
struct NameHist { unsigned char count; unsigned char idx; unsigned char pad[2]; char name[5][27]; };
char *NameHistRecall_b(struct NameHist *h)
{
    char *p;

    if (h->count != 0) {
        p = h->name[h->idx];
        if (h->idx == 0) {
            switch (h->count) {
            case 5:
                h->idx = 4;
                break;
            default:
                h->idx = h->count - 1;
                break;
            }
        } else
            h->idx--;
    } else
        p = 0;
    return p;
}
