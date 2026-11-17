/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_7b.c (2026-11-16-79-sub-r7)
   sha256 bef3833963878e0910cfc435c5744015fa3834273d8d4314fee65c98fc8c4c31 (name+funcs); compiled at -Xr */
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern unsigned char __near ram_132b[];
extern unsigned char __near ram_1481[];
void Voice_List_MoveToPool(unsigned char *n, unsigned char *list, int k);
void Voice_List_MoveToPartList(unsigned char *n, unsigned char *list, int k);
void DList_Unlink_SelfLink_Offsets16(unsigned char *n);
void Voice_Retire_ToFreePool(unsigned char *v)
{
    if (!(v[34] & 1)) {
        if (P(v, 29)[1] != 0) --P(v, 29)[1];
        Voice_List_MoveToPool(v, ram_132b, 6);
        Voice_List_MoveToPartList(v, ram_1481, 1);
        DList_Unlink_SelfLink_Offsets16(v);
        v[34] = 1;
        v[37] = 0;
        if (P(v, 29)[1] < P(v, 29)[0]) P(v, 29)[1]++;
    }
}
