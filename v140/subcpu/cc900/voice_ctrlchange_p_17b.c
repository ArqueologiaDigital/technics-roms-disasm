/* Functions of core/07_voice_ctrlchange.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern int ram_412fd;
unsigned int Pitch_Saturate_15bit(unsigned int a);
int Pitch_Fold_Octaves_Into_Range(int a, int lo, int hi);

void Voice_Slot_ComputePitch(unsigned char *v)
{
    unsigned char *s;
    unsigned char *t23;
    unsigned char *t31;
    int p;
    s = (*(unsigned char **)((v) + (35)));
    t23 = (*(unsigned char **)((v) + (23)));
    t31 = (*(unsigned char **)((v) + (31)));
    p = (int)(v[5] & 0x7f) << 8;
    p += 0x80;
    p += (*(int *)((s) + (274)));
    p += ram_412fd;
    p += (int)(char)s[22] << 8;
    p += (int)(char)s[109] << 8;
    (*(unsigned int *)((v) + (8))) = Pitch_Saturate_15bit(p);
    p -= ((int)t31[11] << 8) + 0x80;
    p += (int)(*(unsigned int *)((t31) + (12)));
    p += (int)(char)t23[3] << 8;
    p += (char)t23[4];
    (*(int *)((v) + (6))) = Pitch_Fold_Octaves_Into_Range(p, t31[9], t31[10]);
}
