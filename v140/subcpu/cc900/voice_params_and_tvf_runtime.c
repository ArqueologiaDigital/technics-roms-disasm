/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
   Held back from subcpu/cc900/ (2026-11-16): these call the C runtime (C9H_mulls / C9H_divls ...), whose
   names the build does not map to the payload's Math_Multiply32 / Long_SignedDiv yet.
*/

extern int __near ram_293e;
struct tvf { char pad[66]; int a; int b; };
struct zone { char pad[6]; int base; char pad2[2]; int out; };
struct dl { struct dl *next; struct dl *prev; };



















extern unsigned char Detune_Scale_Curve[];



#define B(p, o) (*(unsigned char *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern unsigned char __near RingBuf_OffsetLo;
extern unsigned int __near MIDI_BacklogCount;
extern unsigned char Voice_StealPoolOrder[];
extern unsigned char Instrument_OctaveShift_Semitones[];
extern unsigned char ram_41322[];
extern unsigned char ram_41342[];
extern unsigned char ram_41389[];
extern unsigned char __near ram_210b[];
extern int ram_4518c;
extern int ram_45190;
extern int ram_45192;
extern int ram_45194;
extern int ram_45196;
extern int ram_4519e;
extern int ram_451a0;
extern int ram_451a2;
extern int ram_451a4;
extern int ram_451a6;
extern int ram_451a8;
extern int ram_451aa;
void Voice_Level_ClearAllOutputRegs(unsigned char *v);
struct dl8 { char pad[8]; struct dl8 *next; struct dl8 *prev; };
struct dl16 { char pad[16]; struct dl16 *next; struct dl16 *prev; };
struct dl0 { struct dl0 *next; struct dl0 *prev; };













































extern unsigned char __near ram_112d[];
extern long __near ram_1345;



#define W(p, o) (*(unsigned int *)((p) + (o)))
extern unsigned char __tiny ram_18;
extern volatile unsigned int ram_100000;
extern unsigned long __near ram_1040;
extern int ram_45182;
extern unsigned char Voice_Colour_RowOffset_Table[];
extern unsigned char Voice_Colour_TransferCurves[];
extern unsigned char ram_41435[];
extern unsigned char ram_41439[];
extern unsigned char ram_4143a[];
extern unsigned char ram_43043[];
extern unsigned char __near ram_2126[];
extern unsigned char __near ram_2127[];































extern unsigned char ram_44202[][27];
void Pitch_Apply_Partial_Detune(unsigned char *v);





extern int ram_45186;
extern int ram_4131a;
extern unsigned char ram_41300;

unsigned long EnvDepth_Cap(unsigned long a, unsigned char c, unsigned char e)
{
    unsigned long t, r;
    t = (unsigned long)e * (0x7fUL - c);
    r = (t * a) >> 12;
    if (r > a) r = a;
    return r;
}







void Voice_Vol_ScaleVelocityWord(void)
{
    unsigned long t;
    t = ram_1040;
    ram_4131a = (int)(char)((t * t >> 2) & 0xff) * 13 >> 7;
}




