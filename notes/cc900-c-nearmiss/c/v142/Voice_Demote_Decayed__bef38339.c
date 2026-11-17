/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_7b.c (2026-11-16-79-sub-r7)
   sha256 bef3833963878e0910cfc435c5744015fa3834273d8d4314fee65c98fc8c4c31 (name+funcs); compiled at -Xr */
#define P(p, o) (*(unsigned char **)((p) + (o)))
void Voice_List_MoveToPool(unsigned char *n, unsigned char *list, int k);
void Voice_Demote_Decayed(unsigned char *p)
{
    if (p[34] & 3) return;
    p[34] &= 0xf3;
    p[34] |= 2;
    Voice_List_MoveToPool(p, P(p, 29), 6);
}
