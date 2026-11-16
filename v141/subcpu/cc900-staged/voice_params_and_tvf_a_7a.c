/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern int __near ram_293e;
extern int ram_451b6;
extern unsigned long ram_452f8;
extern unsigned int Voice_GlobalFlags;
struct z6 { int w0; char pad[2]; int w4; };
unsigned int Voice_KeyIndex_Pack3Nibbles(unsigned int a);
unsigned int Voice_Slot_CalcAmpNibble(int part, int n, int e);
unsigned int Voice_Slot_FindOctaveOffset(int part, int n, int e);

/* cc900-name: WaveSel_StageB_Reg040_Footage=WaveSel_StageB_Build_Reg040_Footage */
int Voice_Clamp_Byte_WA(int a)
{
    if (a > 0xff) a = 0xff;
    else if (a < 0) a = 0;
    return a;
}

void WaveSel_StageB_Reg040_Footage(unsigned char *v)
{
    struct z6 *t;
    unsigned int k, w;
    int x;
    t = (struct z6 *)(*(unsigned long *)((*(unsigned char **)((v) + (31))) + 5) + ram_452f8);
    if (v[3] == 0) {
        k = Voice_KeyIndex_Pack3Nibbles(Voice_Slot_CalcAmpNibble(v[4], v[0], v[3]));
        t += k;
    } else if (v[3] < 3) {
        k = Voice_KeyIndex_Pack3Nibbles(Voice_Slot_FindOctaveOffset(v[4], v[0], v[3]));
        t += k;
    } else {
        k = *(unsigned int *)((*(unsigned char **)((v) + (35))) + ((int)v[3] * 2 + 0x102));
        t += k;
    }
    (*(unsigned char **)((v) + (15))) = (unsigned char *)t;
    (*(unsigned int *)((v) + (1))) |= 0x4000;
    ram_451b6 = t->w0;
    x = t->w4;
    ram_293e = x;
    if (Voice_GlobalFlags & 4) {
        w = (ram_451b6 & 0xf000) << 1;
        ram_451b6 &= 0xfff;
        ram_451b6 |= w;
    }
}
