/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w5b.c (2026-11-19-10-sub-r23w-asm)
   sha256 c4f58930b3bd612ce04c6acbf4749489c7f80f911867c569244db57c32d4251f (name+funcs); compiled at -Xr
   cc900-options: -Xr
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
    unsigned int w;
    t = (struct z6 *)(*(unsigned char **)(P(v, 31) + 5) + ram_45310);
    if (v[3] == 0) t += Voice_KeyIndex_Pack3Nibbles(CalcAmpNibble_i(v[4], v[0], v[3]));
    else if (v[3] < 3) t += Voice_KeyIndex_Pack3Nibbles(FindOctaveOffset_i(v[4], v[0], v[3]));
    else t += ((unsigned int *)(P(v, 35) + 0x102))[v[3]];
    P(v, 15) = (unsigned char *)t;
    W(v, 1) |= 0x4000;
    ram_451ce = t->w0;
    ram_293e = t->w4;
    if (Voice_GlobalFlags & 4) {
        w = (ram_451ce & 0xf000) << 1;
        ram_451ce &= 0xfff;
        ram_451ce |= w;
    }
}
