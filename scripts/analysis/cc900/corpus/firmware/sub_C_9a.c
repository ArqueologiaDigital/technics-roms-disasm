/* lane_sub probe round 9, helper C, form a: core/08_voice_noteon_and_tonegen.s, KN5000 sub-CPU payload v1.42.
   Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address) the tree has not named.

   Round 8 showed that V4.23 folds a constant column into the symbol even for a 2D array
   (`&ram_44fce[slot][480]` gave `lda xbc,_ram_44fce+0x1e0`), where the ROM keeps the offset in the index register
   (`muls wa,5; add wa,480; lda xbc,(sym); lda xhl,(xbc+wa)`).  Here the offset goes through an int local first.
   VoiceSubSlot_Init / the DSPGlobal row use the integer address with the int first (`int + (unsigned long)sym`), after
   round 7's spelling came within a register choice of the ROM.

   cc900-module: BlockCopy_Words_BC_to_HL CustomTone_CopySubUnitRecord */

extern unsigned char ram_41368[];               /* Part_Record_Base */
extern unsigned char ram_44fce[];
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_RelBase;

struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };

extern unsigned char *WaveSel_StageA1_FromPatchBlock();
extern void CustomTone_CopySubUnitRecord();
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n);

void DSP_SlotParam_Read_To_Cache(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    int o;
    rec = *(unsigned char **)((struct partrec *)(ram_41368 + part * 0x11f))->partial[slot];
    o = (int)slot * 5 + 480;
    q = ram_44fce + o;
    if ((rec[54] & 7) != *q) return;
    for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 77];
}

void DSP_SlotParam_Read_To_Cache_B(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    int o;
    rec = &((unsigned char *)(unsigned long)(ram_4531c + ((int)ram_4531c[29351] * 80 + (int)slot * 21)))[19127];
    o = (int)slot * 5 + 500;
    q = ram_44fce + o;
    if ((rec[15] & 7) != *q) return;
    for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 17];
}

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

void DSP_SlotParam_Write_From_Cache_B(unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    int o;
    rec = &((unsigned char *)(unsigned long)(ram_4531c + ((int)ram_4531c[29351] * 80 + (int)slot * 21)))[19127];
    o = (int)slot * 5 + 500;
    q = ram_44fce + o;
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

void VoiceSubSlot_Init(unsigned char a, unsigned char c)
{
    BlockCopy_Words_BC_to_HL(WaveSel_StageA1_FromPatchBlock(a, c),
                             (unsigned char *)((long)((int)c * 11 + 426) + (unsigned long)ram_44fce),
                             *(unsigned int *)(ToneDB_RootPtr + 234));
}

void Audio_Cmd_DSPGlobal_Param_Store(unsigned char *m)
{
    ((unsigned char *)((long)((int)((m[2] & 0xc0) >> 6) * 11 + 426) + (unsigned long)ram_44fce))[m[2] & 0x3f] = m[4];
    if ((m[2] & 0x7f) <= 10) __ASM("");
}

/* cc900-name: CustomTone_Apply_Catalog8C=VoiceParam_CustomTone_Apply_Catalog8C */
void CustomTone_Apply_Catalog8C(unsigned int idx, unsigned char c)
{
    unsigned char e;
    struct e16 *tbl;
    unsigned char lo;
    unsigned char *rec;
    e = ram_4531c[29351];
    tbl = (struct e16 *)((unsigned long)ToneDB_RelBase + *(long *)(ToneDB_RootPtr + 140));
    lo = c & 15;
    rec = ram_4531c + ((int)e * 80 + (int)lo * 21);
    rec += 19127;
    CustomTone_CopySubUnitRecord(lo, tbl[idx].a, tbl[idx].b, e);
    rec[1] = tbl[idx].a;
    rec[2] = (tbl[idx].b & 15) | 80;
}
