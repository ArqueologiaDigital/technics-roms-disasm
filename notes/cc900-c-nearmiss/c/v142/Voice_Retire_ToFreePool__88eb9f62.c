/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_9a.c (2026-11-16-86-sub-r9)
   sha256 88eb9f6250e886eb73d0ea17657ceaba2c1d96ee178a9e302b394fec469d7fa4 (name+funcs); compiled at -Xr */
extern unsigned char __near ram_132b[];
extern unsigned char __near ram_1481[];
void Voice_List_MoveToPool(unsigned char *n, unsigned char *list, int k);
void Voice_List_MoveToPartList(unsigned char *n, unsigned char *list, int k);
void DList_Unlink_SelfLink_Offsets16(unsigned char *n);
void Voice_Retire_ToFreePool(unsigned char *v)
{
    if (!(v[34] & 1)) {
        if ((*(unsigned char **)((v) + (29)))[1] != 0) (*(unsigned char **)((v) + (29)))[1]--;
        Voice_List_MoveToPool(v, ram_132b, 6);
        Voice_List_MoveToPartList(v, ram_1481, 1);
        DList_Unlink_SelfLink_Offsets16(v);
        v[34] = 1;
        v[37] = 0;
        if ((*(unsigned char **)((v) + (29)))[1] < (*(unsigned char **)((v) + (29)))[0]) (*(unsigned char **)((v) + (29)))[1]++;
    }
}
