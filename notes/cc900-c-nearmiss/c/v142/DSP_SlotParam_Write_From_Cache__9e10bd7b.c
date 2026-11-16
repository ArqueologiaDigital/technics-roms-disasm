/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_9a.c (2026-11-16-86-sub-r9)
   sha256 9e10bd7bedff2a73ff847ad14ce649a21986182a96e80f8e7b4788049a6affb6 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_44fce[];
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
void DSP_SlotParam_Write_From_Cache(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    int o;
    rec = *(unsigned char **)((struct partrec *)(ram_41368 + part * 0x11f))->partial[slot];
    o = (int)slot * 5 + 480;
    q = ram_44fce + o;
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
