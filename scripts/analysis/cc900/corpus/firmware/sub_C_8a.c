/* lane_sub probe round 8, helper C, form a: functions of core/08_voice_noteon_and_tonegen.s, KN5000 sub-CPU payload
   v1.42.  Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address) the tree has not named.

   The 5-byte slot cache rows at 0x44fce + 480 (and + 500 for the B copy): round 4's DSP_SlotParam_Read_To_Cache
   differed from the ROM only where V4.23 folded the 480 into the symbol (`lda xbc,_ram_44fce+0x1e0`), where the ROM
   keeps it in the index (`muls wa,5; add wa,480; lda xbc,(sym); lda xhl,(xbc+wa)`).  V4.23 keeps a 2D array's whole
   offset in one integer index (round 2's ram_44fce.t[k][j]), so the rows are addressed here as `&ram_44fce[slot][480]`
   of a [][5] array. */

extern unsigned char ram_41368[];               /* Part_Record_Base */
extern unsigned char ram_41382[];
extern unsigned char ram_44fce[][5];
extern unsigned char *ram_4531c;
extern unsigned int ram_41360;
extern unsigned char ram_4308e[][71];

struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };

extern void Voice_Allocate_Nodes(unsigned char *v);
extern void DSP_FlushAllSlots_ForPart();

void DSP_SlotParam_Read_To_Cache(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = *(unsigned char **)((struct partrec *)(ram_41368 + part * 0x11f))->partial[slot];
    q = &ram_44fce[slot][480];
    if ((rec[54] & 7) != *q) return;
    for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 77];
}

void DSP_SlotParam_Read_To_Cache_B(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = &((unsigned char *)(unsigned long)(ram_4531c + ((int)ram_4531c[29351] * 80 + (int)slot * 21)))[19127];
    q = &ram_44fce[slot][500];
    if ((rec[15] & 7) != *q) return;
    for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 17];
}

void DSP_SlotParam_Write_From_Cache(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = *(unsigned char **)((struct partrec *)(ram_41368 + part * 0x11f))->partial[slot];
    q = &ram_44fce[slot][480];
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

void DSP_SlotParam_Write_From_Cache_B(unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = &((unsigned char *)(unsigned long)(ram_4531c + ((int)ram_4531c[29351] * 80 + (int)slot * 21)))[19127];
    q = &ram_44fce[slot][500];
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

void Voice_SetPanning(unsigned char *v)
{
    unsigned char *r;
    *(unsigned int *)v = (ram_41360 >> 8) | 0x1480;
    v[2] = 0x80;
    v[6] = 0;
    v[3] = 0;
    v[4] = 0;
    v[5] = 0;
    Voice_Allocate_Nodes(v);
    if (v[10] >= 0x40) return;
    r = ram_4308e[v[10]];
    *(unsigned int *)(r + 8) = ram_41360;
    *(unsigned int *)(r + 6) = ram_41360;
    *(unsigned int *)(r + 1) = 1;
    *(long *)(r + 19) = 0;
    *(long *)(r + 23) = 0;
    *(long *)(r + 27) = 0;
    *(long *)(r + 31) = 0;
    *(long *)(r + 39) = 0;
    r[12] = 0;
    r[4] = 0x14;
    r[5] = ram_41360 >> 8;
    r[0] = v[10];
    r[3] = 0;
    *(unsigned int *)(r + 47) = 0;
    *(unsigned int *)(r + 49) = 0xff;
    r[53] = 0;
    *(unsigned int *)(r + 54) = 0;
    *(unsigned int *)(r + 58) = 0;
    *(unsigned int *)(r + 56) = 0;
}

void VoiceAlloc_CheckAndInit_FromRecord(unsigned char *m)
{
    unsigned char e;
    unsigned char t;
    e = m[1];
    if (e <= 2 || (*(unsigned int *)(ram_41368 + e * 0x11f) & 3) == 3) {
        if (*(unsigned int *)(ram_41368 + e * 0x11f) & 1) {
            *(unsigned int *)(ram_41368 + e * 0x11f) |= 1;
        } else {
            *(unsigned int *)(ram_41368 + e * 0x11f) |= 1;
            t = ram_41382[e * 0x11f];
            if (t >= 64 && t < 80) DSP_FlushAllSlots_ForPart(e);
        }
    }
}
