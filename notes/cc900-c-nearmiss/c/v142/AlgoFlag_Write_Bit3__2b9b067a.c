/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_W_18b.c (2026-11-17-7-sub-r18)
   sha256 2b9b067aa3f5d6c5692fafb23e49ef5089f738ea67d405a1f19b2166fe4e7881 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
#define PATCH(p) (*(unsigned char **)&ram_4136e[(p) * 0x11f])
#define PREC(p) ((struct partrec *)(ram_41368 + (p) * 0x11f))
void AlgoFlag_Write_Bit3(unsigned char part, unsigned char c, unsigned char e)
{
    unsigned char *q;
    unsigned char *p;
    unsigned char w;
    unsigned char b;

    q = (unsigned char *)((unsigned long)&((unsigned char *)PREC(part))[(int)c * 16 + (int)e * 4] + 39);
    p = PATCH(part);
    *q &= 0xf3;
    if (q[2] != 0 && (q[1] & 0x55)) {
        *q |= 8;
    } else {
        for (w = 0; w < 4; w++) {
            switch (c) {
            case 0:
                b = (*(unsigned char **)PREC(part)->partial[w])[6];
                break;
            case 1:
                b = (*(unsigned char **)PREC(part)->partial[w])[38];
                break;
            case 2:
                b = (*(unsigned char **)PREC(part)->partial[w])[56];
                break;
            }
            if ((b & 0x20) && ((b & 0xc0) >> 6) == e)
                *q |= 4;
        }
    }
}
