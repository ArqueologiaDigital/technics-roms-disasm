/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_2b.c (2026-11-16-33-p6-r2)
   sha256 b9efa2757706d71e6e9c9e909054c7167cfc9ddaea6d230749048ed7913a21f6 (tar-sha256); compiled at -O3 -Xr */
struct f45 { unsigned char h : 2; unsigned char f : 2; unsigned char l : 4; };
struct ent { unsigned char h0 : 1; unsigned char v0 : 7; unsigned char h1 : 1; unsigned char v1 : 7;
             unsigned char b2; unsigned char h3 : 1; unsigned char v3 : 7; unsigned char rest[22]; };
void DataBuf_TransferSlotBitfields(unsigned char *s, unsigned char *d)
{
    struct ent *p, *q, *e;
    ((struct f45 *)(d + 737))->f = ((struct f45 *)(s + 737))->f;
    p = (struct ent *)(s + 62);
    q = (struct ent *)(d + 62);
    e = p + 16;
    do {
        q->v0 = p->v0 & 0x7f;
        q->v3 = p->v3 & 0x7f;
        q->v1 = p->v1 & 0x7f;
        q->b2 = p->b2;
        q++;
        p++;
    } while (p < e);
    ((struct ent *)(d + 1047))->v0 = *(s + 1047);
}
