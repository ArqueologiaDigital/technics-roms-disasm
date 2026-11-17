/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_8a.c (2026-11-16-82-sub-r8)
   sha256 45988cee248268643a64a4f7c2c639e4eeefbcdc285480358c8ff1adf1d94b44 (name+funcs); compiled at -Xr */
#define P(p, o) (*(unsigned char **)((p) + (o)))
void Voice_List_MoveToPool(unsigned char *n, unsigned char *list, int k);
void Voice_Demote_Decayed(unsigned char *p)
{
    if ((p[34] & 3) == 0) {
        p[34] &= 0xf3;
        p[34] |= 2;
        Voice_List_MoveToPool(p, P(p, 29), 6);
    }
}
