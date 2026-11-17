/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_P_17b.c (2026-11-16-126-sub-r17)
   sha256 0e0a840326316c81afba23a05abfb073bad3f8133f4552d566393030e1a46134 (name+funcs); compiled at -Xr */
extern unsigned char __near ram_132b[];
extern unsigned char __near ram_1481[];
void Voice_List_MoveToPool(unsigned char *n, unsigned char *list, int k);
void Voice_List_MoveToPartList(unsigned char *n, unsigned char *list, int k);
void DList_Unlink_SelfLink_Offsets16(unsigned char *n);
void Voice_Retire_ToFreePool(unsigned char *v)
{
    unsigned char *q;
    if (!(v[34] & 1)) {
        if ((*(unsigned char **)((v) + (29)))[1] != 0) (*(unsigned char **)((v) + (29)))[1]--;
        Voice_List_MoveToPool(v, (unsigned char *)(void *)ram_132b, 6);
        Voice_List_MoveToPartList(v, (unsigned char *)(void *)ram_1481, 1);
        DList_Unlink_SelfLink_Offsets16(v);
        v[34] = 1;
        v[37] = 0;
        q = (*(unsigned char **)((v) + (29)));
        if (q[1] < q[0]) (*(unsigned char **)((v) + (29)))[1]++;
    }
}
