/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_7c.c (2026-11-16-79-sub-r7)
   sha256 00220d49c918c71ccd87f5bf36078c78c47fac4fecc2bbf39af41da8ff8ad5f9 (name+funcs); compiled at -Xr */
void Voice_List_MoveToPool(unsigned char *n, unsigned char *list, int k);
void Voice_Demote_Decayed(unsigned char *p)
{
    if ((p[34] & 3) == 0) {
        p[34] &= 0xf3;
        p[34] |= 2;
        Voice_List_MoveToPool(p, (*(unsigned char **)((p) + (29))), 6);
    }
}
