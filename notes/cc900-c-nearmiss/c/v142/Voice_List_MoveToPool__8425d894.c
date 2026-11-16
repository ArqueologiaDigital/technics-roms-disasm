/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_8c.c (2026-11-16-82-sub-r8)
   sha256 8425d89435501285c5621aa4eb0c72cc6c86af1f723686ae88429516fe20ee43 (name+funcs); compiled at -Xr
   cc900-name: VList_MoveToPool=Voice_List_MoveToPool */
#define P(p, o) (*(unsigned char **)((p) + (o)))
void DList_Unlink_SelfLink(unsigned char *n);
void DList_InsertAfter_Offsets0(unsigned char *n, unsigned char *q);
void VList_MoveToPool(unsigned char *n, unsigned char *list, char k)
{
    unsigned char *o;
    unsigned char c;
    o = P(n, 29);
    c = n[33];
    if (*(unsigned char **)(o + ((int)c * 4 + 2)) == n) {
        if (P(n, 0) != n) *(unsigned char **)(o + ((int)c * 4 + 2)) = P(n, 0);
        else *(unsigned char **)(o + ((int)c * 4 + 2)) = 0;
    }
    if (*(unsigned char **)(list + ((int)k * 4 + 2)) == 0) {
        *(unsigned char **)(list + ((int)k * 4 + 2)) = n;
        DList_Unlink_SelfLink(n);
    } else DList_InsertAfter_Offsets0(n, *(unsigned char **)(list + ((int)k * 4 + 2)));
    P(n, 29) = list;
    n[33] = k;
}
