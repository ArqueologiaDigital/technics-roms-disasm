/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17b.c (2026-11-16-126-sub-r17)
   sha256 103952cb479afdc1c60db40fc3853c5ae181d89a51e462c0596d12a2a476ff39 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_44fce[];
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
void DSP_SlotParam_Write_From_Cache(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = *(unsigned char **)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[slot];
    q = (&ram_44fce[(int)(long)((int)slot * 5 + 480)]);
    if ((rec[54] & 7) == *q) {
        for (i = 0; i < 4; i++) rec[(unsigned long)i + 77] = q[(unsigned long)i + 1];
        return;
    }
    switch (*q) {
    case 1:
    case 3:
        if ((rec[54] & 7) == 5) {
            rec[77] = 0;
            rec[78] = 1;
            rec[79] = q[1];
            rec[80] = q[2];
        } else {
            for (i = 0; i < 4; i++) rec[(unsigned long)i + 77] = q[(unsigned long)i + 1];
        }
        break;
    case 2:
    case 4:
        if ((rec[54] & 7) == 5) {
            rec[77] = q[1];
            rec[78] = q[2];
            rec[79] = 127;
            rec[80] = 1;
        } else {
            for (i = 0; i < 4; i++) rec[(unsigned long)i + 77] = q[(unsigned long)i + 1];
        }
        break;
    case 5:
        switch (rec[54] & 7) {
        case 1:
        case 3:
            rec[77] = q[3];
            rec[78] = q[4];
            rec[79] = 64;
            rec[80] = 135;
            break;
        case 2:
        case 4:
            rec[77] = q[1];
            rec[78] = q[2];
            rec[79] = 64;
            rec[80] = 7;
            break;
        }
        break;
    }
}
