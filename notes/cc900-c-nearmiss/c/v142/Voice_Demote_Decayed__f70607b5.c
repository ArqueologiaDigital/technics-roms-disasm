/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_7a.c (2026-11-16-79-sub-r7)
   sha256 f70607b5111b1b73ae470351c728e34d55ce40ce7a9d878e58e34960dca5e443 (name+funcs); compiled at -Xr */
void Voice_List_MoveToPool(unsigned char *n, unsigned char *list, int k);
void Voice_Demote_Decayed(unsigned char *p)
{
    if (p[34] & 3) return;
    p[34] &= 0xf3;
    p[34] |= 2;
    Voice_List_MoveToPool(p, (*(unsigned char **)((p) + (29))), 6);
}
