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

extern unsigned char ram_41335;
extern unsigned char ram_41333;
extern int ram_41331;
extern unsigned int ram_4132b;
extern unsigned char ram_4135e[];
extern int ram_451e0;
extern int ram_451e2;
struct vol { char pad[64]; int v; };



















extern unsigned char ram_41352[];
extern int ram_4132f;







extern unsigned int ram_41344;
extern unsigned char ram_41346;
extern unsigned char ram_41347;
extern unsigned int ram_41348;
extern unsigned int ram_4134a;
extern int ram_4134c;
extern unsigned char ram_4135a[];
extern unsigned char ram_4135f[];
extern unsigned char ram_41362[];
extern unsigned char ram_41363[];
extern unsigned char ram_41367[];
extern unsigned char ram_41368[];
extern unsigned char ram_41375[];
extern unsigned char ram_41376[];
extern unsigned int ram_451ce;
extern unsigned int ram_451d0;
extern unsigned int Voice_RhythmMode_ScalePitch_Table[];
struct envseg { char pad[62]; unsigned int a; unsigned int b; };





































extern unsigned char ram_41364[];



extern int ram_41342;
extern unsigned char ram_41366[];
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
