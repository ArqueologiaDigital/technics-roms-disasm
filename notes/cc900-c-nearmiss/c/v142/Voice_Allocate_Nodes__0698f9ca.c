/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AK_23b.c (2026-11-19-11-sub-r23h-helpers)
   sha256 0698f9ca782ce17a5cc1b5e31a7d86c061435b71cd238ca979dd16ad2273fde5 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char * __near ram_1129;
extern unsigned char __near ram_1349[];
extern unsigned char __near ram_130d[];
extern unsigned int __near ram_2936[];
extern unsigned int __near ram_292e[];
extern unsigned char Voice_LayerClassTable[];
void RingBuf_CheckOffset_ClearFlags(unsigned char *p);
unsigned char *Voice_Find_Candidate(unsigned char *list, unsigned char *s);
unsigned char *Voice_FindStealCandidate(unsigned char *p);
void Voice_List_MoveToPool(unsigned char *n, unsigned char *list, unsigned char k);
void Voice_List_MoveToPartList(unsigned char *n, unsigned char *list, unsigned char k);
void DList_Relink_Adjacent_Offsets16(unsigned char *p, unsigned char *q);
void DList_Unlink_SelfLink_Offsets16(unsigned char *p);
void Voice_ScanSlots_ReassignSources(unsigned char a);
void Voice_Allocate_Nodes(unsigned char *v)
{
    unsigned char s;
    unsigned char i;
    unsigned char *cls;
    unsigned char *list;
    unsigned char part;
    unsigned char *n;
    unsigned char *q;
    unsigned char *u;
    unsigned char *c2;

    if (!(v[6] & 0x40)) ram_1129 = 0;
    part = (*(unsigned int *)v & 0x1f00) >> 8;
    if (part < 0x1a) {
        RingBuf_CheckOffset_ClearFlags(v);
        list = ram_1349 + (int)part * 12;
        for (i = 0; i < 4; i++) {
            if (v[(int)i + 2] & 0x80) {
                c2 = Voice_LayerClassTable + (int)(v[(int)i + 2] & 0xf) * 6;
                cls = c2;
                n = Voice_Find_Candidate(list, *(unsigned char **)c2);
                if (n != 0) {
                    s = n[36];
                    if ((*(unsigned char **)(n + 29))[1] != 0) (*(unsigned char **)(n + 29))[1]--;
                    n[35] = *(unsigned int *)v & 0x7f;
                    n[37] = 0xff;
                    n[38] = cls[5];
                    if (v[(int)i + 6] & 0x80) {
                        n[34] = 0x88;
                        ram_2936[s >> 4] |= 1 << (s & 0xf);
                    } else {
                        n[34] = 0x08;
                        ram_2936[s >> 4] &= ~(1 << (s & 0xf));
                        ram_292e[s >> 4] |= 1 << (s & 0xf);
                    }
                    Voice_List_MoveToPool(n, *(unsigned char **)list, (char)cls[4]);
                    Voice_List_MoveToPartList(n, list, 0);
                    if (ram_1129 != 0) DList_Relink_Adjacent_Offsets16(n, ram_1129);
                    else {
                        ram_1129 = n;
                        DList_Unlink_SelfLink_Offsets16(n);
                    }
                    u = *(unsigned char **)(n + 29);
                    q = u;
                    if (u[1] < *q) (*(unsigned char **)(n + 29))[1]++;
                    else {
                        n = Voice_FindStealCandidate(*(unsigned char **)(n + 29));
                        if (n != 0) {
                            Voice_List_MoveToPool(n, (unsigned char *)(void *)ram_130d, n[33]);
                            (*(unsigned char **)(n + 29))[1]++;
                            n[34] |= 0x10;
                        }
                    }
                    Voice_ScanSlots_ReassignSources(s);
                    v[(int)i + 10] = s;
                } else v[(int)i + 10] = 0xff;
            } else v[(int)i + 10] = 0xff;
        }
    } else {
        for (i = 0; i < 4; i++) v[(int)i + 10] = 0xff;
    }
}
