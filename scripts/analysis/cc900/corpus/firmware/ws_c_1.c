/* lane_ws probe round 1: small leaf functions of the SX-WSA1R prom_c (CPU 2, wsa1/prom_c).  Names are the tree's
   labels; ram_<hex> is a RAM cell the tree has not named.  The ROM reads every argument from the stack, so the
   functions are plain (cdecl). */

struct queue { char pad[20]; unsigned int free; };
struct part { char pad[4]; unsigned int w4; char rest[294]; };
extern unsigned char __near ram_150a;
extern unsigned int ram_8678;
extern unsigned char ram_8677;
extern struct part __near ram_1523[];

unsigned int Queue_FreeSlots(struct queue *q) { return q->free; }
void GlobalScale_StoreMode(unsigned char v) { ram_150a = v; }
void MidiIn_StoreRingBacklog(unsigned int v) { ram_8678 = v; }
void MidiNote_StoreStatusBit3(unsigned char v) { ram_8677 = v; }

unsigned char Rec0E3E_GroupOfIndex(unsigned char i)
{
    if (i >= 0x40) {
        if (i < 0x80) return 4;
        if (i < 0xc0) return 8;
    }
    return 0;
}

unsigned char Rec0E3E_IndexWithinGroup(unsigned char i, unsigned char sel)
{
    switch (sel & 3) {
    case 0:
    case 1:
        return i & 0x3f;
    case 2:
        return (i - 0x40) & 0x7f;
    case 3:
        return i & 0x7f;
    }
}

void Dev10C_SetChanReg_0100_0140_b(unsigned int ch, unsigned int *p)
{
    unsigned int *d = (unsigned int *)0x10c000;
    *d = ch + 0x100;
    d[1] = p[4];
    *d = ch + 0x140;
    d[1] = p[5];
}

void PartRec_Word0004_ClearStagedSetBit2(unsigned int part)
{
    ram_1523[part].w4 &= 0xfffc;
    ram_1523[part].w4 |= 4;
}
