/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17b.c (2026-11-16-126-sub-r17)
   sha256 103952cb479afdc1c60db40fc3853c5ae181d89a51e462c0596d12a2a476ff39 (name+funcs); compiled at -Xr
   cc900-name: SubSlot_Apply_Catalog64=VoiceParam_SubSlot_Apply_Catalog64 */
extern unsigned char ram_41368[];
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
struct slotrec { unsigned char *p0; unsigned char *vel; };
struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };
extern void WaveSel_Cache_SetDescPtr();
void SubSlot_Apply_Catalog64(unsigned char part, unsigned int idx, unsigned char sel)
{
    struct e16 *tbl;
    unsigned char lo;
    unsigned char hi;
    tbl = (struct e16 *)(ToneDB_RelBase + ToneDB_RootPtr[25]);
    lo = sel;
    lo &= 15;
    hi = (sel & 0xf0) >> 4;
    ((struct slotrec *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[lo])->vel[(int)hi * 2 + 3] = tbl[idx].a;
    (&((struct slotrec *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[lo])->vel[(int)hi * 2 + 3])[1] = tbl[idx].b;
    WaveSel_Cache_SetDescPtr(part, lo, hi);
}
