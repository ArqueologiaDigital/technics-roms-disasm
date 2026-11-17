/* Functions of core/08_voice_noteon_and_tonegen.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_4131c[];
extern unsigned char ram_44f82[];
extern unsigned char *ram_452d0;
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
void DSP_SlotParam_Read_To_Cache(unsigned char part, unsigned char slot);
void DSP_SlotParam_Write_From_Cache(unsigned char part, unsigned char slot);
void DSP_SlotParam_Write_From_Cache_B(unsigned char slot);

void DSP_SlotParam_Read_To_Cache(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = *(unsigned char **)((struct partrec *)(ram_4131c + (part) * 0x11f))->partial[slot];
    q = (&ram_44f82[(int)(unsigned int)((int)slot * 5 + 480)]);
    if ((rec[54] & 7) != *q) return;
    for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 77];
}

void DSP_SlotParam_Write_From_Cache(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = *(unsigned char **)((struct partrec *)(ram_4131c + (part) * 0x11f))->partial[slot];
    q = (&ram_44f82[(int)(unsigned int)((int)slot * 5 + 480)]);
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
    rec = &((unsigned char *)(unsigned long)(ram_452d0 + ((int)ram_452d0[29351] * 80 + (int)slot * 21)))[19127];
    q = (&ram_44f82[(int)(unsigned int)((int)slot * 5 + 500)]);
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
