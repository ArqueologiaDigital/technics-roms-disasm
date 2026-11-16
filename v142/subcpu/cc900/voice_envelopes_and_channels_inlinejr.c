/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
   Held back from subcpu/cc900/ (2026-11-16): their inline assembly writes `jr $+2`, whose $ the build's translation does not map to llvm-mc's . yet.
*/

extern unsigned char ram_4134d;
extern unsigned char ram_4134b;
extern int ram_41349;
extern unsigned int ram_41343;
extern unsigned char ram_41376[];
extern int ram_451f8;
extern int ram_451fa;
struct vol { char pad[64]; int v; };



















extern unsigned char ram_4136a[];
extern int ram_41347;







extern unsigned int ram_4135c;
extern unsigned char ram_4135e;
extern unsigned char ram_4135f;
extern unsigned int ram_41360;
extern unsigned int ram_41362;
extern int ram_41364;
extern unsigned char ram_41372[];
extern unsigned char ram_41377[];
extern unsigned char ram_4137a[];
extern unsigned char ram_4137b[];
extern unsigned char ram_4137f[];
extern unsigned char ram_41380[];
extern unsigned char ram_4138d[];
extern unsigned char ram_4138e[];
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern unsigned int Voice_RhythmMode_ScalePitch_Table[];
struct envseg { char pad[62]; unsigned int a; unsigned int b; };





































extern unsigned char ram_4137c[];



extern int ram_4135a;
extern unsigned char ram_4137e[];
extern char Voice_KeyShiftRamp_Steps[];





extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;

void ToneGen_WriteVoice_Direct(unsigned int a, unsigned int d)
{
    __IZ = d;
    ram_18 &= ~0x80;
    ram_100000 = a;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = __IZ;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}
