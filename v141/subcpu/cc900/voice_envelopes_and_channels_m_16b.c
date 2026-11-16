/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int ram_451b8;
extern unsigned char Voice_OutputLevel_Table[];
extern int ram_41348;
extern int ram_4134a;
extern int ram_4134c;
extern unsigned char ram_43076[][0x47];
extern unsigned int ram_451b6;
extern unsigned int ram_451ba;
extern unsigned int ram_451bc;
extern unsigned int ram_451be;
extern unsigned int ram_451c0;
extern unsigned int ram_451c2;
extern unsigned int ram_451c4;
extern unsigned int ram_451c6;
extern unsigned int ram_451c8;
extern unsigned int ram_451ca;
extern unsigned int ram_451cc;
extern unsigned int ram_451ce;
extern unsigned int ram_451d0;
extern unsigned int ram_451d2;
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
extern unsigned int ram_451d8;
extern unsigned int ram_451da;
extern unsigned int ram_451dc;
extern unsigned int ram_451de;

void Voice_InitVoiceState(unsigned char slot)
{
    unsigned int t;
    ram_451b6 = 0;
    ram_451c2 = ram_41348;
    ram_451d4 = 0;
    ram_451d6 = 0;
    ram_451d8 = 0;
    ram_451bc = 0x17f;
    ram_451be = 0x7f7f;
    ram_451da = 0;
    ram_451dc = 0;
    ram_451de = 0;
    ram_451ca = 0;
    ram_451d2 = 0;
    ram_451c4 = 0;
    ram_451c6 = 0;
    ram_451c0 = 0x40;
    ram_451c8 = 0;
    ram_451ba = 0;
    ram_451cc = 0xff7f;
    ram_451ce = ram_4134a;
    ram_451d0 = ram_4134a;
    t = *(unsigned int *)&Voice_OutputLevel_Table[(int)((unsigned int)ram_4134c << 1)];
    t += t;
    ram_451b8 = t;
    *(unsigned int *)&ram_43076[slot][0x2d] = 0xf000;
}
