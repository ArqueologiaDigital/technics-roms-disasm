/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_P_17a.c (2026-11-16-126-sub-r17)
   sha256 4236702b3d6d2cd4a34bd2c4b4787b866c2680f5404a1df78ec1c7768ec2066d (name+funcs); compiled at -Xr */
void Voice_Reprioritise(unsigned char *p);
void Voice_List_MoveToPartList(unsigned char *n, unsigned char *list, int k);
void DList_Unlink_SelfLink_Offsets16(unsigned char *n);
void OutputBuf_Flush_B(unsigned char **pp, unsigned char *head, unsigned char key, char all)
{
    unsigned char *n;
    unsigned char *next;
    if (head != 0) {
        n = head;
        do {
            if (all != 0 || n[35] == key) {
                for (;;) {
                    Voice_List_MoveToPartList(n, (*(unsigned char **)((n) + (24))), 1);
                    Voice_Reprioritise(n);
                    **pp = n[36];
                    *pp += 1;
                    if (n == (*(unsigned char **)((n) + (16)))) goto done;
                    next = (*(unsigned char **)((n) + (16)));
                    DList_Unlink_SelfLink_Offsets16(n);
                    n = next;
                }
            }
            n = (*(unsigned char **)((n) + (8)));
        } while (n != head);
    }
done:
    **pp = 0xff;
}
