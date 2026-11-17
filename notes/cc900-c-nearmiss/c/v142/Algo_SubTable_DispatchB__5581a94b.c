/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_W_18a.c (2026-11-17-7-sub-r18)
   sha256 5581a94b8744c554c7810133a024cbd218f46e7ca66812c682e8dd6f7e0a7d38 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char DSP_AlgoDescriptor_Records[];
struct algorec { unsigned char b[40]; };
struct b5 { unsigned char f0; unsigned char f1; unsigned char f2; unsigned char f3; unsigned char f4; };
unsigned char Algo_SubTable_DispatchB(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;
    t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
    r = ((struct b5 *)((unsigned long)&((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)(k) * 5 + 0x13]))->f2;
    switch (t) {
    case 0: case 1: case 2: case 3:
        if (k == 1) {
            part = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[96];
            r = part + part;
        }
        break;
    case 4: case 5:
        if (k == 1) {
            part = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[98];
            r = part + part;
        }
        break;
    case 8:
        if (k == 1) {
            part = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[95];
            r = part + part;
        }
        break;
    }
    return r;
}
