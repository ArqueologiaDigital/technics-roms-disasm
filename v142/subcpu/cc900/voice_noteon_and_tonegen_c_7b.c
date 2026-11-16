/* Functions of core/08_voice_noteon_and_tonegen.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern void RingBuf_SetOffsetLo(unsigned char v);
extern void Voice_SetVelocity(unsigned char a, unsigned char b, unsigned char c, unsigned int d);
extern void Voice_SetPitch(unsigned char a, unsigned char b, unsigned char c, unsigned int d);
extern void Voice_NoteOff(unsigned char a, unsigned char b, unsigned char c, unsigned int d);
extern unsigned char *Voice_Allocate(unsigned char a, unsigned char b);
extern void Voice_ParamInit(unsigned char *v);

/* cc900-module: Voice_Allocate Voice_NoteOff Voice_ParamInit Voice_SetPitch Voice_SetVelocity */
void Voice_NoteOn(char *m)
{
    unsigned char ch;
    if (m[1] >= 26) return;
    ch = m[0] & 7;
    if ((m[3] & 0x7f) != 0) {
        RingBuf_SetOffsetLo(m[0] & 8);
        Voice_SetVelocity(m[1], m[2], m[3], ch);
        Voice_SetPitch(m[1], m[2], m[3], ch);
    } else {
        Voice_ParamInit(Voice_Allocate(m[1], m[2]));
        Voice_NoteOff(m[1], m[2], m[3], ch);
    }
}
