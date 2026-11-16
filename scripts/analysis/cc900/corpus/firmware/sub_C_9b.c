/* lane_sub probe round 9, helper C, form b: core/08_voice_noteon_and_tonegen.s, KN5000 sub-CPU payload v1.42.
   The slot cache rows at 0x44fce + 480 / + 500 written as rows 96.. / 100.. of a [][5] array, so that the constant is
   part of the row index (`(int)slot + 96`) rather than a column V4.23 folds into the symbol; the DSPGlobal row through
   an int local and a pointer local; VoiceParam_SubSlot_Apply_Catalog50 (new), which reaches VoiceSubSlot_Init with
   calr and a zero-extended byte (no prototype in scope, so VoiceSubSlot_Init is not defined in this file).

   cc900-module: VoiceSubSlot_Init */

extern unsigned char ram_41368[];               /* Part_Record_Base */
extern unsigned char ram_44fce[][5];
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_RelBase;

struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };

extern void VoiceSubSlot_Init();
extern void WaveSel_Cache_SetDescPtr();

void DSP_SlotParam_Read_To_Cache(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = *(unsigned char **)((struct partrec *)(ram_41368 + part * 0x11f))->partial[slot];
    q = ram_44fce[(int)slot + 96];
    if ((rec[54] & 7) != *q) return;
    for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 77];
}

void DSP_SlotParam_Read_To_Cache_B(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = &((unsigned char *)(unsigned long)(ram_4531c + ((int)ram_4531c[29351] * 80 + (int)slot * 21)))[19127];
    q = ram_44fce[(int)slot + 100];
    if ((rec[15] & 7) != *q) return;
    for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 17];
}

void DSP_SlotParam_Write_From_Cache(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = *(unsigned char **)((struct partrec *)(ram_41368 + part * 0x11f))->partial[slot];
    q = ram_44fce[(int)slot + 96];
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
    q = ram_44fce[(int)slot + 100];
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

void Audio_Cmd_DSPGlobal_Param_Store(unsigned char *m)
{
    int o;
    unsigned char *p;
    o = (int)((m[2] & 0xc0) >> 6) * 11 + 426;
    p = (unsigned char *)ram_44fce + o;
    p[m[2] & 0x3f] = m[4];
    if ((m[2] & 0x7f) <= 10) __ASM("");
}

/* cc900-name: SubSlot_Apply_Catalog50=VoiceParam_SubSlot_Apply_Catalog50 */
void SubSlot_Apply_Catalog50(unsigned char part, unsigned int idx, unsigned char sel)
{
    struct e16 *tbl;
    unsigned char k;
    unsigned char j;
    tbl = (struct e16 *)((unsigned long)ToneDB_RelBase + *(long *)(ToneDB_RootPtr + 80));
    k = sel;
    k &= 15;
    (*(unsigned char **)((struct partrec *)(ram_41368 + part * 0x11f))->partial[k])[2] = tbl[idx].a;
    (*(unsigned char **)((struct partrec *)(ram_41368 + part * 0x11f))->partial[k])[3] = tbl[idx].b;
    VoiceSubSlot_Init(part, k);
    for (j = 0; j < 4; j++) WaveSel_Cache_SetDescPtr(part, k, j);
}
