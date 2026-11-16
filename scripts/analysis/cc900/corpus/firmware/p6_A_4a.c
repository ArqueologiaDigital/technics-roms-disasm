/* Phase 6, lane_p6 helper A, round 4, form a: new leaf functions of v10 sequencer/accompaniment_engine.s under their
   firmware names.  One declaration per __near name. */
extern unsigned char __near ACC_PART_BIT;
extern unsigned char __near ram_333f;
extern unsigned char __near ram_3340;
extern unsigned char __near ram_33de;
extern unsigned char __near ACC_LANES_INTRO1;
extern unsigned char __near ACC_LANES_COUNTIN;
extern unsigned char __near ACC_LANES_INTRO2;
extern unsigned char __near ACC_LANES_ENDING1;
extern unsigned char __near ACC_LANES_ENDING2;
extern unsigned char __near ram_37c8;
extern unsigned char __near ram_37c7;
extern unsigned char __near STYLE_SECTION;
extern unsigned char __near CMPNCP_FROM_ITEM;

/* The ROM's routine is a bare ret (the bytes after it are not reached from here).
   cc900-name: AccPatch_CmplxDataBlk_Helper2=AccPatch_ComplexDataBlock_Helper2 */
void AccPatch_CmplxDataBlk_Helper2(void)
{
}

/* The ROM ANDs the same register with each mask in turn, so after the first test fails A is 0: kept as written. */
void AccMidi_SelectVelocitySource(void)
{
    unsigned char a, w;
    a = ACC_PART_BIT;
    w = ram_333f;
    if ((a &= ACC_LANES_INTRO1) != 0 || (a &= ACC_LANES_COUNTIN) != 0 || (a &= ACC_LANES_INTRO2) != 0
        || (a &= ACC_LANES_ENDING1) != 0 || (a &= ACC_LANES_ENDING2) != 0)
        w = ram_3340;
    ram_33de = w;
}

void DrumParam_BuildActiveMask(void)
{
    unsigned char w, b;
    int i;
    unsigned char *p, *q;
    w = 0;
    ram_37c8 = w;
    i = 0;
    w = 1;
    p = (unsigned char *)0x37ab;
    q = (unsigned char *)0x37b9;
    do {
        if (*p++ != *q++)
            ram_37c8 |= w;
        w <<= 1;
        i++;
    } while (i < 7);
    i = 0;
    w = 1;
    p = (unsigned char *)0x37b2;
    q = (unsigned char *)0x37c0;
    do {
        if (*p++ != *q++)
            ram_37c8 |= w;
        w <<= 1;
        i++;
    } while (i < 7);
    if (STYLE_SECTION != ram_37c7) {
        b = 0x7f;
        ram_37c8 = b;
    }
}

/* Probe: an int argument in WA tested by bit 7 of W, and branches to a shared ret (non -O shape in the ROM). */
void CmpNcp_StepItemA(int d)
{
    unsigned char v;
    v = CMPNCP_FROM_ITEM;
    if (d < 0) {
        if (v == 2)
            return;
        v++;
    } else {
        if (v == 0)
            return;
        v--;
    }
    CMPNCP_FROM_ITEM = v;
}
