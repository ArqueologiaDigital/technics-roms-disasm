/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_9c.c (2026-11-16-86-sub-r9)
   sha256 2a4900afbac103e1bce68754d3180b961a895008e589f9e30977258ab92379cc (name+funcs); compiled at -Xr
   cc900-name: SubSlot_Apply_Catalog64=VoiceParam_SubSlot_Apply_Catalog64 */
extern unsigned char ram_41368[];
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_RelBase;
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };
extern void WaveSel_Cache_SetDescPtr();
void SubSlot_Apply_Catalog64(unsigned char part, unsigned int idx, unsigned char sel)
{
    struct e16 *tbl;
    unsigned char lo;
    unsigned char hi;
    tbl = (struct e16 *)((unsigned long)ToneDB_RelBase + *(long *)(ToneDB_RootPtr + 100));
    lo = sel;
    lo &= 15;
    hi = (sel & 0xf0) >> 4;
    (*(unsigned char **)&((unsigned char *)(unsigned long)((struct partrec *)(ram_41368 + part * 0x11f))->partial[lo])[4])
        [(int)hi * 2 + 3] = tbl[idx].a;
    ((unsigned char *)(unsigned long)(*(unsigned char **)&((unsigned char *)(unsigned long)
        ((struct partrec *)(ram_41368 + part * 0x11f))->partial[lo])[4] + ((int)hi * 2 + 3)))[1] = tbl[idx].b;
    WaveSel_Cache_SetDescPtr(part, lo, hi);
}
