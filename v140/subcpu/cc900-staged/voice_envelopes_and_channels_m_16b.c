/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int ram_45184;
extern unsigned char Voice_OutputLevel_Table[];
extern int ram_41314;
extern int ram_41316;
extern int ram_41318;
extern unsigned char ram_43042[][0x47];
extern unsigned int ram_45182;
extern unsigned int ram_45186;
extern unsigned int ram_45188;
extern unsigned int ram_4518a;
extern unsigned int ram_4518c;
extern unsigned int ram_4518e;
extern unsigned int ram_45190;
extern unsigned int ram_45192;
extern unsigned int ram_45194;
extern unsigned int ram_45196;
extern unsigned int ram_45198;
extern unsigned int ram_4519a;
extern unsigned int ram_4519c;
extern unsigned int ram_4519e;
extern unsigned int ram_451a0;
extern unsigned int ram_451a2;
extern unsigned int ram_451a4;
extern unsigned int ram_451a6;
extern unsigned int ram_451a8;
extern unsigned int ram_451aa;

void Voice_InitVoiceState(unsigned char slot)
{
    unsigned int t;
    ram_45182 = 0;
    ram_4518e = ram_41314;
    ram_451a0 = 0;
    ram_451a2 = 0;
    ram_451a4 = 0;
    ram_45188 = 0x17f;
    ram_4518a = 0x7f7f;
    ram_451a6 = 0;
    ram_451a8 = 0;
    ram_451aa = 0;
    ram_45196 = 0;
    ram_4519e = 0;
    ram_45190 = 0;
    ram_45192 = 0;
    ram_4518c = 0x40;
    ram_45194 = 0;
    ram_45186 = 0;
    ram_45198 = 0xff7f;
    ram_4519a = ram_41316;
    ram_4519c = ram_41316;
    t = *(unsigned int *)&Voice_OutputLevel_Table[(int)((unsigned int)ram_41318 << 1)];
    t += t;
    ram_45184 = t;
    *(unsigned int *)&ram_43042[slot][0x2d] = 0xf000;
}
