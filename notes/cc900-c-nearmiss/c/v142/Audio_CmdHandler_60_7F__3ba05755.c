/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2b.c (2026-11-16-47-sub-r2)
   sha256 3ba05755c2798de91f6133ff8f8917993908146ceb144365284b065fc249c7a9 (name+funcs); compiled at -Xr */
struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
extern unsigned int __near ram_4488;
extern unsigned int __near ram_448a;
extern unsigned int __near ram_448c;
extern struct ring2k __near ram_3b60;
int __cdecl Audio_CmdHandler_60_7F(int n, unsigned char *p)
{
    unsigned int i;

    if (ram_448c != 0) {
        if (ram_448c > 1)
            i = 0;
        if (ram_448a + n < ram_4488) {
            ram_448a += n;
            ram_448c++;
        } else {
            ram_448a = 0;
            ram_448c = 0;
        }
    } else if (n == 0x20) {
        ram_4488 = ((p[5] & 0x7ff) << 7) + p[6] + 8;
        ram_448a += 32;
        ram_448c = 1;
    } else {
        ram_448a = 0;
        ram_448c = 0;
    }
    for (i = 0; i < n; i++) {
        ram_3b60.buf[ram_3b60.w++ & 0x7ff] = *p++;
        ram_3b60.n++;
    }
    return 0;
}
