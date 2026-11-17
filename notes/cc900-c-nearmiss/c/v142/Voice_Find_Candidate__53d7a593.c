/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2a.c (2026-11-16-47-sub-r2)
   sha256 53d7a593968fb87f84af530bceae3e1c306174f47db7d2c6980e60b72454f307 (name+funcs); compiled at -Xr */
extern unsigned char __near ram_112d[];
extern long __near ram_1345;
void *Voice_Find_Candidate(unsigned char **p, unsigned char *s)
{
    void **q2;
    void **q1;
    unsigned char k;
    if (ram_1345 != 0) return (void *)ram_1345;
    q2 = (void **)(ram_112d + 482);
    q1 = (void **)(*p + 2);
    for (; *s != 0xff; s++) {
        if (*s & 0x80) {
            k = *s & 0x7f;
            if (q2[k] != 0) return q2[k];
        } else {
            if (q1[*s] != 0) return q1[*s];
        }
    }
    return 0;
}
