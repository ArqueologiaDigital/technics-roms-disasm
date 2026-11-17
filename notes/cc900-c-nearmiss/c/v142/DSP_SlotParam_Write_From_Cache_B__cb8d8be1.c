/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17c.c (2026-11-16-126-sub-r17)
   sha256 cb8d8be11508728097d9e78ae3bf4fbe5f7b1c76f6a92dd24928a8442d7e7268 (name+funcs); compiled at -Xr */
extern unsigned char ram_44fce[];
extern unsigned char *ram_4531c;
void DSP_SlotParam_Write_From_Cache_B(unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = &((unsigned char *)(unsigned long)(ram_4531c + ((int)ram_4531c[29351] * 80 + (int)slot * 21)))[19127];
    q = (((int)slot * 5 + 500) + ram_44fce);
    if ((rec[15] & 7) == *q) {
        for (i = 0; i < 4; i++) rec[(unsigned long)i + 17] = q[(unsigned long)i + 1];
        return;
    }
    switch (*q) {
    case 1:
    case 3:
        if ((rec[15] & 7) == 5) {
            rec[17] = 0;
            rec[18] = 1;
            rec[19] = q[1];
            rec[20] = q[2];
        } else {
            for (i = 0; i < 4; i++) rec[(unsigned long)i + 17] = q[(unsigned long)i + 1];
        }
        break;
    case 2:
    case 4:
        if ((rec[15] & 7) == 5) {
            rec[17] = q[1];
            rec[18] = q[2];
            rec[19] = 127;
            rec[20] = 1;
        } else {
            for (i = 0; i < 4; i++) rec[(unsigned long)i + 17] = q[(unsigned long)i + 1];
        }
        break;
    case 5:
        switch (rec[15] & 7) {
        case 1:
        case 3:
            rec[17] = q[3];
            rec[18] = q[4];
            rec[19] = 64;
            rec[20] = 135;
            break;
        case 2:
        case 4:
            rec[17] = q[1];
            rec[18] = q[2];
            rec[19] = 64;
            rec[20] = 7;
            break;
        }
        break;
    }
}
