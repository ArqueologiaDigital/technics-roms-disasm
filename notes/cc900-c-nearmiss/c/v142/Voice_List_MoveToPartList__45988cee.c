/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_8a.c (2026-11-16-82-sub-r8)
   sha256 45988cee248268643a64a4f7c2c639e4eeefbcdc285480358c8ff1adf1d94b44 (name+funcs); compiled at -Xr
   cc900-name: VList_MoveToPartList=Voice_List_MoveToPartList */
#define P(p, o) (*(unsigned char **)((p) + (o)))
void DList_Unlink_SelfLink_Offsets8(unsigned char *n);
void DList_InsertAfter_Offsets8(unsigned char *n, unsigned char *q);
void VList_MoveToPartList(unsigned char *n, unsigned char *list, unsigned char k)
{
    unsigned char *o;
    unsigned char c;
    o = P(n, 24);
    c = n[28];
    if (*(unsigned char **)(o + ((int)c * 4 + 4)) == n) {
        if (P(n, 8) != n) *(unsigned char **)(o + ((int)c * 4 + 4)) = P(n, 8);
        else *(unsigned char **)(o + ((int)c * 4 + 4)) = 0;
    }
    if (*(unsigned char **)(list + ((int)k * 4 + 4)) == 0) {
        *(unsigned char **)(list + ((int)k * 4 + 4)) = n;
        DList_Unlink_SelfLink_Offsets8(n);
    } else DList_InsertAfter_Offsets8(n, *(unsigned char **)(list + ((int)k * 4 + 4)));
    P(n, 24) = list;
    n[28] = k;
}
