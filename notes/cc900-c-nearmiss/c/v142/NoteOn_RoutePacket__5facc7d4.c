/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AM_23a.c (2026-11-19-11-sub-r23h-helpers)
   sha256 5facc7d42e425d9190d630deaa64e42d9c9dd3dea4d0644e80c2a8ffb6fcf78a (name+funcs); compiled at -Xr
   cc900-options: -Xr */
#define W(p, o) (*(unsigned int *)((p) + (o)))
extern unsigned char __near ram_148d[];
extern unsigned char __near ram_134d[];
extern unsigned char __near ram_1351[];
void OutputBuf_Flush_A(unsigned char **pp, unsigned char *head, unsigned char key, unsigned char all);
void OutputBuf_Flush_B(unsigned char **pp, unsigned char *head, unsigned char key, unsigned char all);
void NoteOn_RoutePacket(unsigned char *q)
{
    unsigned char **l1;
    unsigned char **l2;
    unsigned char key;
    unsigned char all;
    unsigned char *out;
    unsigned char *v;
    unsigned char i;
    unsigned char ch;
    unsigned int x;

    x = W(q, 3) & 0x7f;
    all = x;
    x = W(q, 1) & 0x7f;
    key = x;
    out = q + 5;
    if (W(q, 3) & 0x1f00) {
        v = ram_148d;
        for (i = 0; i < 0x40; i++) {
            if (!(v[34] & 1)) *out++ = v[36];
            v += 39;
        }
        *out = 0xff;
    } else {
        ch = (W(q, 1) & 0x1f00) >> 8;
        l1 = (unsigned char **)(ram_134d + (int)ch * 12);
        l2 = (unsigned char **)(ram_1351 + (int)ch * 12);
        if (ch < 0x1a) {
            if (q[0] & 0x80) {
                if (W(q, 3) & 0x7f) {
                    if (*l1 != 0) {
                        v = *l1;
                        for (;;) {
                            OutputBuf_Flush_B(&out, *l1, key, all);
                            if (*l1 == 0) break;
                            if (*l1 == v) break;
                        }
                    }
                    *out = 0xff;
                } else OutputBuf_Flush_B(&out, *l1, key, all);
            } else if (q[0] & 0x40) {
                OutputBuf_Flush_A(&out, *l2, key, all);
            } else if (W(q, 3) & 0x80) {
                OutputBuf_Flush_A(&out, *l1, key, all);
                OutputBuf_Flush_A(&out, *l2, key, all);
            } else if (W(q, 1) & 0x80) {
                OutputBuf_Flush_A(&out, *l1, key, all);
            } else {
                OutputBuf_Flush_A(&out, *l2, key, all);
            }
        } else *out = 0xff;
    }
}
