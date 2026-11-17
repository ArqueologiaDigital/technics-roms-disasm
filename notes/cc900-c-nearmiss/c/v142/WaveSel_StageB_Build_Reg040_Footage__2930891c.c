/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_4b.c (2026-11-16-62-sub-r4)
   sha256 2930891c0f4cc37037eb6f8318034f85e7213280edee0124175fee577eb1783d (name+funcs); compiled at -Xr
   cc900-name: CalcAmpNibble_i=Voice_Slot_CalcAmpNibble
   cc900-name: FindOctaveOffset_i=Voice_Slot_FindOctaveOffset
   cc900-name: WaveSel_StageB_Reg040_Footage=WaveSel_StageB_Build_Reg040_Footage */
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern int __near ram_293e;
extern int ram_451ce;
extern unsigned long ram_45310;
extern unsigned int Voice_GlobalFlags;
struct z6 { int w0; char pad[2]; int w4; };
unsigned int Voice_KeyIndex_Pack3Nibbles(unsigned int a);
unsigned int CalcAmpNibble_i(int part, int n, int e);
unsigned int FindOctaveOffset_i(int part, int n, int e);
void WaveSel_StageB_Reg040_Footage(unsigned char *v)
{
    struct z6 *t;
    t = (struct z6 *)(*(unsigned long *)(P(v, 31) + 5) + ram_45310);
    if (v[3] == 0) t += Voice_KeyIndex_Pack3Nibbles(CalcAmpNibble_i(v[4], v[0], v[3]));
    else if (v[3] < 3) t += Voice_KeyIndex_Pack3Nibbles(FindOctaveOffset_i(v[4], v[0], v[3]));
    else t += ((unsigned int *)(P(v, 35) + 0x102))[v[3]];
    P(v, 15) = (unsigned char *)t;
    W(v, 1) |= 0x4000;
    ram_451ce = t->w0;
    ram_293e = t->w4;
    if (Voice_GlobalFlags & 4) {
        ram_451ce = (ram_451ce & 0xfff) | ((ram_451ce & 0xf000) << 1);
    }
}
